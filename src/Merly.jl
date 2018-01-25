module Merly
import HttpServer.mimetypes
import Base.|

using HttpServer,
      HttpCommon,
      JSON,
      XMLDict

include("routes.jl")
include("allformats.jl")


export app, @page, @route, GET,POST,PUT,DELETE,Get,Post,Put,Delete,routes

q=Dict()

b=[]
root=pwd()

#metodof=1
exten="\"\""::AbstractString

type Q
  query
  params
  body
  notfound_message
end


type Fram
  notfound::Function
  start::Function
  use::Function
end



#function _url(ruta::String, resource::UTF8String)
function _url(ruta::String, resource::String)

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


function _body(data::Array{UInt8,1},format::String)

  content=""
  for i=1:length(data)
   content*="$(Char(data[i]))"
  end

  return getindex(formats, format)(content)
end


function files(arch::Array{Any,1})
  global root
  for i=1:length(arch)
    roop=replace(replace(arch[i],root,""),"\\","/")
    extencion=split(roop,".")[end]
    if !ismatch(r"(/\.)",roop)
      @page roop begin
      try
        r.headers["Content-Type"]=mimetypes[extencion]
      end
      File(roop[2:end], r)
      end
    end
  end
end

function WebServer(rootte::String)
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



function File(file::String, res::HttpCommon.Response)
  global root
  path = normpath(root, file)
  if isfile(path)
    res.data = readall(path)
  else
    NotFound(res)
  end
end


#=function process(element::Merly.Pag,q,res::HttpCommon.Response,req::HttpCommon.Request)

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
end=#


function handler(request::HttpCommon.Request,response::HttpCommon.Response)

  searchroute = request.method*request.resource
  try
    q.body = _body(request.data,request.headers["Content-Type"])
  catch
    q.body = _body(request.data,"*/*")
  end

  if cors
   response.headers["Access-Control-Allow-Origin"]="*"
   response.headers["Access-Control-Allow-Methods"]="POST,GET,OPTIONS"
  end

  #res.status = 200

  try
    info("METODO : ",request.method,"    URL : ",request.resource)
    response.data = getindex(routes, searchroute)(q,request,response)
  catch
    response.data = getindex(routes, "notfound")(q,request,response)
  end
  return response
end


# funcion debug
# ipv 6
# CRTL Z  para matar proceso
function app(r=pwd()::AbstractString,load=""::AbstractString)
global root
global exten
global q
global cors
cors=false::Bool
root=r::AbstractString

q=Q(Dict(),Dict(),"","NotFound")
if root[end]=='/'
  root=root[1:end-1]
end
#OSNAME = is_windows() ? :Windows : Compat.KERNEL
if is_windows()
  if root[end]=='\\'
    root=root[1:end-1]
  end
end
if length(load)>0
  if load=="*"
    WebServer(root)
  else
    exten=load::AbstractString
    WebServer(root)
  end
end
cd(root)

  function use(y::AbstractString)
      cors=y=="CORS"
  end

  function notfound(text::AbstractString)
    try
      path = normpath(root, text)
      q.notfound_message= readall(path)
    catch
      q.notfound_message = text
    end
  end

  function start(host="localhost"::AbstractString,port=8000::Integer)
    http = HttpHandler((req, res)-> handler(req,res))
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
  return Fram(notfound,start,use)
end
end # module
