mutable struct myresponse
  status::Int
  headers::Dict
  body::String
end

mutable struct Data
  query::Dict
  params::Any
  body::Any
end

struct Fram
  notfound::Function
  start::Function
  useCORS::Function
  webserverfiles::Function
  webserverpath::Function
end

my_headers= HTTP.mkheaders(["Content-Type" => "text/plain"])
root=pwd()
if root[end]=='/'
  root=root[1:end-1]
elseif Sys.iswindows() && root[end]=='\\'
  root=root[1:end-1]
end
exten="\"\""::AbstractString
notfound_message = "NotFound"::String
q=Data(Dict(),"","")

function File(file::String)
    path = normpath(root, file)
    return String(read(path))
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
  if (length(data)>1) q.query= HTTP.queryparams(data[2]) end
  response = myresponse(200,Dict(),"")

  if ((request.method=="POST"  )||(request.method=="PUT"  )||(request.method=="PATCH"))
    header_content_type = HTTP.header(request, "Content-Type")
    if(length(header_content_type)>0)
      q.body= getindex(formats, header_content_type)(String(request.body))
    else
      q.body = getindex(formats, "*/*")(String(request.body))
    end
  end

  if (searchroute in routes_array)
    response.body = getindex(routes, searchroute)(q,request,response)
  else
    #try
    #  response.body = processroute_pattern(searchroute,request,response)
    #catch
     response.body = getindex(routes, "notfound")(q,request,response)
    #end
  end
  responsefinal = HTTP.Response(response.status,my_headers, body=response.body)
  for (key, value) in response.headers
    HTTP.setheader(responsefinal,key => value )
  end
  return responsefinal
end


function app()
  global exten

  function useCORS(activate::Bool)
   HTTP.setheader(my_headers,"Access-Control-Allow-Origin" => "*")
   HTTP.setheader(my_headers,"Access-Control-Allow-Methods" => "POST,GET,OPTIONS")
   return true
  end

  function notfound(text::String)
    if occursin(".html", text)
    notfound_message= File(text)
    else
      notfound_message= text
    end
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
    port=get(config, "port", 8000)::Int
    my_host = get(config, "host", "127.0.0.1")::String
    if ('.' in my_host) host=Sockets.IPv4(my_host) end
    if (':' in my_host) host=Sockets.IPv6(my_host) end
    http = (req)-> handler(req)
    myserver= HTTP.Servers.Server(http, stdout)
    @info("Listening on: $(host) : $(port)")
    return HTTP.Servers.serve(myserver, host, port)
  end

  @info("App created")
  return Fram(notfound,start,useCORS,webserverfiles,webserverpath)
end

#HSTS     HTTP.setheader(response,"Strict-Transport-Security" => "max-age=10886400; includeSubDomains; preload"