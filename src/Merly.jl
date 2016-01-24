module Merly
import HttpServer.mimetypes
import Base.|

using HttpServer,
      HttpCommon,
      JSON,
      XMLDict

export app, @page, @route, GET,POST,PUT,DELETE
|(x::ASCIIString, y::ASCIIString)="$x|$y"

POST="POST"
PUT="PUT"
DELETE="DELETE"
GET="GET"
b=[]
root=pwd()
NotFound = Response(404)
#metodof=1
exten="\"\""

type Pag
	method
    route
    code
end

type Fram
	start::Function
end


function pag(url,code)
    Pag(Regex("GET"),url,code)
end

function pag(met,url,cod)
    Pag(Regex(met),url,cod)
end


macro page(exp1,exp2)
	quote
		push!(b,pag($exp1,(params,query,res,h,body)->$exp2))
    nothing
	end
end

macro route(exp1,exp2,exp3)
	quote
		push!(b,pag($exp1,$exp2,(params,query,res,h,body)->$exp3 ))
    nothing
	end
end

function _url(ruta, resource)
  params=Dict()
  query=Dict()

  resource = split(resource,"?")
  try
    if length(resource[2])>=1
      query=parsequerystring(resource[2])
    end
  end

  resource = split(resource[1],"/")
  resource =resource[2:length(resource)]

  ruta = split(ruta,"/")
  ruta =ruta[2:length(ruta)]

  lruta=length(ruta)
  lresource=length(resource)

  println("ruta: ",ruta)
  println("resource: ",resource)

  if ruta[end]==""
    lruta=lruta-1
  end

  if resource[end]==""
    lresource=lresource-1
  end

  s=true

  if(lruta==lresource)
    for i=1:lruta
      if length(ruta[i])>=1
        if !(ruta[i][1]==':')
          #println("ruta:  ",Regex(ruta[i]))
          #println("entrada:  ",resource[i])
          #println((ismatch(Regex(ruta[i]),resource[i])))
          s=s && (ismatch(Regex(ruta[i]),resource[i]))
        else
          r=ruta[i][2:length(ruta[i])]
          params[r]=resource[i]
        end
      end
    end
    return s,params,query
  end
  return false,params,query
end

function _body(data,ty)
  bo="{}"
  if(length(data)>=1)
    bo=""
    for i=1:length(data)
      bo*="$(Char(data[i]))"
    end
  end

  if ismatch(Regex("application/json"),ty)
    body= JSON.parse(bo)
    return body
  end
  if ismatch(Regex("application/xml"),ty)
    body= xml_dict(bo)
    return body
  end

  return bo
end


function files(arch)
  global root
  for i=1:length(arch)
    roop=replace(replace(arch[i],root,""),"\\","/")
    extencion=split(roop,".")[end]
    @page roop begin
    h["Content-Type"]=mimetypes[extencion]
    File(roop[2:end], res)
    end
  end
end

function WebServer(rootte)
  cd(rootte)
  ls= readdir()
  arrfile=[]
  arrdir=[]
  for i=1:length(ls)
    if isfile(ls[i])
        if (ismatch(Regex("((.)*\\.(?!($exten)))"),ls[i]))
          push!(arrfile,normpath(rootte,ls[i]))
        end
    end
    if isdir(ls[i])
      #println("cambiando directorio:",normpath(rootte,ls[i]))
      push!(arrdir,normpath(rootte,ls[i]))
    end
  end
  files(arrfile)
  for i=1:length(arrdir)
    WebServer(arrdir[i])
  end
end

function File(file, res)
  global root
  #global metodof
  #if metodof==2
  #  file=replace(file,"/","",1)
  #end
  path = normpath(root, file)
  if isfile(path)
    res.data = readall(path)
  else
    res.status = 404
  end
end

function process(element,params,query,res,req)
  #=println("datos del request:")
  println("resource: ",req.resource)
  println("method: ",req.method)
  println("headers: ",req.headers)
  println("")
  =#

  body=""
  h= HttpCommon.headers()

  if !(ismatch(Regex("GET"),req.method))
    #println("interpetando los Bytes de req.data como caracteres: ")
    body= _body(req.data,req.headers["Accept"])
  end

  #h["Content-Type"]="text/html"
  res.status = 200

  #----------aqui escribe el programador-----------

  respond = element.code(params,query,res,h,body)
  #----------------------------------------------


  sal=[]
  try
    sal = matchall(Regex("{{([A-Z]|[a-z]|[0-9])*}}"),respond)
    d=length(sal)
    if d>0
      for i=1:d
        respond= replace(respond,Regex(sal[i]),params["$(sal[i][3:end-2])"])
      end
    end
  end
  if respond != ""
    res.data= respond
  end
  res.headers=h

  return res
end


function handler(b,req,res)
  #---------------se exponene todos los archivos
  #=global metodof
  if metodof==2
    resource = split(req.resource,"?")[1]
    File(resource, res)
    if length(res.data)>0
      h= HttpCommon.headers()
      extencion=split(req.resource,".")[end]
      h["Content-Type"]="text/css"
      res.headers=h
      return res
    end
  end=#
  ##--------------------------------------
  tam= length(b)
  if tam>0
    for s=1:tam
      pm=ismatch(b[s].method,req.method)
      pasa,params,query=_url(b[s].route,req.resource)
      if pm && pasa
        resp=process(b[s],params,query,res,req)
        return resp
      end
    end
  end
  return NotFound
end



function app(r=pwd()::AbstractString,load="")
global root
global exten
root=r
#global metodof

if length(load)>0
  if load=="*"
    WebServer(root)
  else
    exten=load
    WebServer(root)
  end
end



  function start(host="localhost",port=8000)
    http = HttpHandler((req, res)-> handler(b,req,res))
    http.events["error"]  = (client, error) -> println(error)
    http.events["listen"] = (port)          -> println("Listening on $port...")
    server = Server(http)
    if host=="localhost"
      host="127.0.0.1"
    end
    try
      IPv4(host)
      @async run(server, host=IPv4(host), port=port)
    catch
      "only IPv4 addresses"
    end
  end

  return Fram(start)
end

#_url("/home/[A-Z]{1,3}/","/home/AZR/")
end # module
