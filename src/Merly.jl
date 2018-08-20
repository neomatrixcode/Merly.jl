module Merly
import Base.|

using Sockets,
JSON,
HTTP#,
#XMLDict

include("mimetypes.jl")
include("routes.jl")
include("allformats.jl")
include("webserver.jl")

export app, @page, @route, GET,POST,PUT,DELETE,HEAD,OPTIONS,PATCH,Get,Post,Put,Delete

mutable struct myresponse
  status::Int
  headers::Dict
  body::String
end

cors=false::Bool
root=pwd()
if root[end]=='/'
  root=root[1:end-1]
elseif Sys.iswindows() && root[end]=='\\'
  root=root[1:end-1]
end

exten="\"\""::AbstractString

mutable struct Data
  query::Dict
  params::Any
  body::Any
end
global notfound_message = "NotFound"::String
global q=Data(Dict(),"","")

mutable struct Fram
  notfound::Function
  start::Function
  useCORS::Function
  webserverfiles::Function
  webserverpath::Function
end

function _body(data::Array{UInt8,1},format::SubString{String})
  return getindex(formats, format)(String(data))
end

function File(file::String)
  try
    path = normpath(root, file)
    return String(read(path))
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

function processroute_pattern(searchroute::String,request,response)
  q.params, _function  = resolveroute(searchroute)
  respond = _function(q,request,response)
  sal = collect((m.match for m = eachmatch(Regex("{{([a-z])+}}"), respond)))
  for i in sal
    respond = replace(respond,Regex(i) => q.params["$(i[3:end-2])"])
  end
  response.status = 200
  return respond
end

function handler(request::HTTP.Messages.Request)
  data = split(request.target,"?")
  url=data[1]
  searchroute = request.method*url
  try
    q.query= HTTP.queryparams(data[2]);
  catch
  end

  response = myresponse(200,Dict(),"")

  header_content_type = HTTP.header(request, "Content-Type")
  if(length(header_content_type)>0)
    q.body= _body(request.body,header_content_type)
  else
    q.body = _body(request.body,SubString("*/*"))
  end

  if (haskey(routes, searchroute))
    response.body = getindex(routes, searchroute)(q,request,response)
  else
    try
      response.body = processroute_pattern(searchroute,request,response)
    catch
     response.body = getindex(routes, "notfound")(q,request,response)
    end
  end

  responsefinal = HTTP.Response(response.status,response.body)
  if cors
   HTTP.setheader(responsefinal,"Access-Control-Allow-Origin" => "*")
   HTTP.setheader(responsefinal,"Access-Control-Allow-Methods" => "POST,GET,OPTIONS")
  end
  HTTP.setheader(responsefinal,"Content-Type" => "text/plain" )
  for (key, value) in response.headers
    HTTP.setheader(responsefinal,key => value )
  end

  return responsefinal
end


function app()
  global root
  global exten
  global cors

  function useCORS(activate::Bool)
    cors=activate
  end

  function notfound(text::AbstractString)
    notfound_message= File(text)
  end

  function webserverfiles(load::AbstractString)
    if load=="*"
      WebServer(root)
    else
      exten=load::AbstractString
      WebServer(root)
    end
  end

  function webserverpath(path::AbstractString)
    root= path
  end

  function start(config=Dict("host" => "127.0.0.1","port" => 8000)::Dict)
    host= Sockets.IPv4("127.0.0.1")
    port= 8000

    try
      host=Sockets.IPv4(get(config, "host", "127.0.0.1")::AbstractString)
    catch
      try
        host=Sockets.IPv6(get(config, "host", "127.0.0.1")::AbstractString)
      catch
      end
    end

    try
      port=get(config, "port", 8000)::Int
    catch
      @info("Port 8000 ")
    end

    http = (req)-> handler(req)

    myserver= HTTP.Servers.Server(http, stdout)

    try
      #@async run(server, host=IPv4(host), port=port)
      return HTTP.Servers.serve(myserver, host, port)
    catch
      try
      return HTTP.Servers.serve(myserver, host, port)
      catch
        @warn("Address not valid, check it")
      end
    end
  end
  @info("App created")
  return Fram(notfound,start,useCORS,webserverfiles,webserverpath)
end
end # module
#HSTS     HTTP.setheader(response,"Strict-Transport-Security" => "max-age=10886400; includeSubDomains; preload"
