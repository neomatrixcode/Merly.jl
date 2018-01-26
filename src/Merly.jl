module Merly
import HttpServer.mimetypes
import Base.|

using HttpServer,
      HttpCommon,
      JSON,
      XMLDict

include("routes.jl")
include("allformats.jl")

export app, @page, @route, GET,POST,PUT,DELETE,HEAD,OPTIONS,PATCH,Get,Post,Put,Delete
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
        r.data= File(roop[2:end])
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



function File(file::String)
  try
    path = normpath(root, file)
    return readstring(path)
  catch
    return file
  end
end


function resolveroute(ruta::String)
  for key in keys(routes_patterns)
    params= match(key,ruta)
    if params!= nothing
      return params, getindex(routes_patterns,key)
    end
  end
end

function processroute_pattern(searchroute::String,request::HttpCommon.Request,response::HttpCommon.Response)
  q.params, _function  = resolveroute(searchroute)
  respond = _function(q,request,response)
  sal = matchall(Regex("{{([a-z])+}}"),respond)
  for i in sal
    respond = replace(respond,Regex(i),q.params["$(i[3:end-2])"])
  end
  return respond
end

function handler(request::HttpCommon.Request,response::HttpCommon.Response)

  data = split(request.resource,"?")
  url=data[1]

  searchroute = request.method*url

  try
    q.query= parsequerystring(data[2]);
  end

  try
    q.body = _body(request.data,request.headers["Content-Type"])
  catch
    q.body = _body(request.data,"*/*")
  end

  if cors
   response.headers["Access-Control-Allow-Origin"]="*"
   response.headers["Access-Control-Allow-Methods"]="POST,GET,OPTIONS"
  end


  info("METODO : ",request.method,"    URL : ",url)


  try
    response.data = getindex(routes, searchroute)(q,request,response)
  catch
    try
      response.data = processroute_pattern(searchroute,request,response)
    catch
      response.data = getindex(routes, "notfound")(q,request,response)
    end
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
      q.notfound_message= File(text)
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
