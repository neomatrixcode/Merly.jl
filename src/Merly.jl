module Merly
import HttpServer.mimetypes
import Base.|

using HttpServer,
      HttpCommon,
      JSON,
      XMLDict

export app, @page, @route, GET,POST,PUT,DELETE,Get,Post,Put,Delete
|(x::ASCIIString, y::ASCIIString)="$x|$y"

r=Dict()
q=Dict()

POST="POST"
PUT="PUT"
DELETE="DELETE"
GET="GET"
b=[]
root=pwd()
nfmessage=""
#metodof=1
exten="\"\""

type Q
  query
  params
  body
end

type Pag
  method::Regex
  route::ASCIIString
  code::Function
end

type Fram
  notfound::Function
  start::Function
end

function pag(url::ASCIIString,code::Function)
    Pag(Regex("GET"),url,code)
end

function pag(met::ASCIIString,url::ASCIIString,cod::Function)
    Pag(Regex(met),url,cod)
end


macro page(exp1,exp2)
  quote
    push!(b,pag($exp1,(q,r)->$exp2))
    #nothing
  end
end

macro route(exp1,exp2,exp3)
  quote
    push!(b,pag($exp1,$exp2,(q,r)->$exp3 ))
    #nothing
  end
end

function Get(URL::ASCIIString, fun::Function)
  push!(b,pag("GET",URL,fun))
end

function Post(URL::ASCIIString, fun::Function)
  push!(b,pag("POST",URL,fun))
end

#function Post(URL::ASCIIString, fun::Function)
#  push!(b,pag("POST",URL,fun))
#end

function Put(URL::ASCIIString, fun::Function)
  push!(b,pag("PUT",URL,fun))
end

function Delete(URL::ASCIIString, fun::Function)
  push!(b,pag("DELETE",URL,fun))
end

function _url(ruta::ASCIIString, resource::UTF8String)
  global q
  q.params=Dict()
  q.query=Dict()

  resource = split(resource,"?")
  try
    if length(resource[2])>=1
      q.query=parsequerystring(resource[2])
    end
  end

  resource = split(resource[1],"/")
  resource =resource[2:end]

  ruta = split(ruta,"/")
  ruta =ruta[2:end]

  lruta=length(ruta)
  lresource=length(resource)

  try
    if ruta[end]==""
      lruta=lruta-1
    end

    if resource[end]==""
      lresource=lresource-1
    end
  end

  s=true
  if(lruta==lresource)
    for i=1:lruta
      if length(ruta[i])>=1
        if !(ruta[i][1]==':')
          s=s && (ismatch(Regex(ruta[i]),resource[i]))
        else
          r=ruta[i][2:end]
          q.params[r]=resource[i]
        end
      end
    end
    return s,q
  end
  return false,q
end

function _body(data::Array{UInt8,1},ty::ASCIIString)
  global q
  bo="{}"
  ld=length(data)
  if(ld>=1)
    bo=""
    for i=1:ld
      bo*="$(Char(data[i]))"
    end
    q.body=bo
  end

  if ismatch(Regex("application/json"),ty)
    q.body= JSON.parse(bo)
    return q
  end
  if ismatch(Regex("application/xml"),ty)
    q.body= xml_dict(bo)
    return q
  end

  return q
end


function files(arch::Array{Any,1})
  global root
  for i=1:length(arch)
    roop=replace(replace(arch[i],root,""),"\\","/")
    extencion=split(roop,".")[end]
    if !ismatch(r"(/\.)",roop)
      @page roop begin
      try
        h["Content-Type"]=mimetypes[extencion]
      end
      File(roop[2:end], res)
      end
    end
  end
end

function WebServer(rootte::ASCIIString)
  cd(rootte)
  ls= readdir()
  arrfile=[]
  arrdir=[]
  for i=1:length(ls)
    if isfile(ls[i])
        if (ismatch(Regex("((.)*\\.(?!($exten)))"),ls[i])) && !ismatch(r"^(\.)",ls[i])
          push!(arrfile,normpath(rootte,ls[i]))
        end
    end
    if isdir(ls[i])
      push!(arrdir,normpath(rootte,ls[i]))
    end
  end
  files(arrfile)
  for i=1:length(arrdir)
    WebServer(arrdir[i])
  end
end

function NotFound(res)
  global nfmessage
  res.data = nfmessage
  res.status = 404
end

function File(file::ASCIIString, res::HttpCommon.Response)
  global root
  path = normpath(root, file)
  if isfile(path)
    res.data = readall(path)
  else
    NotFound(res)
  end
end


function process(element::Merly.Pag,q,res::HttpCommon.Response,req::HttpCommon.Request)
  

  if !(ismatch(Regex("GET"),req.method))
    #println("interpetando los Bytes de req.data como caracteres: ")
    try
    body= _body(req.data,req.headers["Accept"])
    catch
    body= _body(req.data,"")
    end
  end
  #h["Content-Type"]="text/html"
  res.status = 200
  println(element)
  #----------aqui escribe el programador-----------
  respond = element.code(q,res)
  #----------------------------------------------
  sal=[]
  try
    sal = matchall(Regex("{{([A-Z]|[a-z]|[0-9])*}}"),respond)
    d=length(sal)
    if d>0
      for i=1:d
        respond= replace(respond,Regex(sal[i]),q.params["$(sal[i][3:end-2])"])
      end
    end
  end
  if length(respond)>0
    try 
    res.data= respond
    end
  end
  #res.headers=h
  return res
end


function handler(b::Array{Any,1},req::HttpCommon.Request,res::HttpCommon.Response)  
  tam= length(b)
  if tam>0
    for s=1:tam
      pm=ismatch(b[s].method,req.method)
      pasa,q=_url(b[s].route,req.resource)
      if pm && pasa
        resp=process(b[s],q,res,req)
        return resp
      end
    end
  end
  NotFound(res)
  return res
end



function app(r=pwd()::AbstractString,load=""::AbstractString)
global root
global exten
global q
root=r
q=Q("","","")
if root[end]=='/'
  root=root[1:end-1]
end

if OS_NAME==:Windows
  if root[end]=='\\'
    root=root[1:end-1]
  end
end
if length(load)>0
  if load=="*"
    WebServer(root)
  else
    exten=load
    WebServer(root)
  end
end
cd(root)
  
  function notfound(x::AbstractString)
    global nfmessage
    nfmessage=x

    try
      path = normpath(root, x)
      if isfile(path)
          nfmessage = readall(path)
      end
    end

    nothing
  end

  function start(host="localhost"::AbstractString,port=8000::Integer)
    http = HttpHandler((req, res)-> handler(b,req,res))
    http.events["error"]  = (client, error) -> println(error)
    http.events["listen"] = (port)          -> println("Listening on $port...")
    server = Server(http)
    if host=="localhost"
      host="127.0.0.1"
    end
    try
      IPv4(host)
      #@async run(server, host=IPv4(host), port=port)
      run(server, host=IPv4(host), port=port)
    catch
      "only IPv4 addresses"
    end
  end
  return Fram(notfound,start)
end
end # module
