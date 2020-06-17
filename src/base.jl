mutable struct myresponse
  status::Int
  headers::Dict
  body::String
  function myresponse(code)
      new(code,Dict(),"")
  end
end

mutable struct myrequest
  query::Dict
  params::RegexMatch
  body::Any
  version::VersionNumber
  headers::Array
  function myrequest()
    new(Dict(),match(r"\s"," "),"",VersionNumber(1),[])
  end
end

my_headers= HTTP.mkheaders(["Content-Type" => "text/plain"])

function searchroute_regex(ruta::String)
  for i in 1:length(routes_patterns_array)
    if(occursin(routes_patterns_array[i],ruta))
      return routes_patterns_array[i]
    end
 end
 return ""
end

function handler(request::HTTP.Request)
  data = split(request.target,"?")
  url=data[1]
  searchroute = request.method*url

  my_request=myrequest()
  my_request.version=request.version
  my_request.headers=request.headers
  if (length(data)>1) my_request.query= HTTP.queryparams(data[2]) end

  response = myresponse(200)

  if ((request.method=="POST"  )||(request.method=="PUT"  )||(request.method=="PATCH"))
    header_content_type = HTTP.header(request, "Content-Type")
    if((length(header_content_type)>0) && (haskey(formats,header_content_type)))
      my_request.body= getindex(formats, header_content_type)(String(request.body))
    else
      my_request.body = getindex(formats, "*/*")(String(request.body))
    end
  end

  if (searchroute in routes_array)
    response.body = getindex(routes, searchroute)(my_request,response)
  else
    pattern = searchroute_regex(searchroute)
    if (typeof(pattern) <:Regex)
      my_request.params = match(pattern,searchroute)
      _function = getindex(routes_patterns,pattern)
      response.body = _function(my_request,response)
      sal = collect((m.match for m = eachmatch(Regex("{{(\\w\\d*)+}}"), response.body)))
      for i in sal
        response.body = replace(response.body,Regex(i) => my_request.params["$(i[3:end-2])"])
      end
    else
      response.body = getindex(routes, "notfound")(my_request,response)
    end
  end
  responsefinal = HTTP.Response(response.status,my_headers, body=response.body)
  for (key, value) in response.headers
    HTTP.setheader(responsefinal,key => value )
  end
  return responsefinal
end

"""
Contains server configuration
"""
rootbase = pwd()


export webserverpath
function webserverpath(folder::AbstractString)
  global rootbase = joinpath(pwd(),folder)
end


export File
"""
File(file::String)

Return a file content located in "rootbase"
"""
function File(file::String)
    return File("", file)
end

"""
File(folder::String, file::String)

Return a file content located in "joinpath(rootbase, folder)"
"""
function File(folder::String, file::String)
  path = joinpath(rootbase, folder, file)
  f = open(path)
  return read(f, String)
end

"""
files(roop::String, file::String)

Create a GET route to file
"""
function files(folder::String, file::String)
    extension="text/plain"
    ext= split(file,".")
    if(length(ext)>1)
      my_extension = ext[end]
      if (haskey(mimetypes, my_extension))
        extension = mimetypes[my_extension]
      end
    end
    data = File(folder, file)
    folder = replace(folder,"\\" => "/")
    createurl("GET/"*joinpath(folder,file), (req,res)->(begin
      res.headers["Content-Type"]= extension
      res.status = 200
      res.body = data
    end))
end

"""
Create routes to files inside "rootbase"
"""
function WebServer(folder::String, exten::String)
  path = joinpath(rootbase, folder)
  ls= readdir(path)
  for i = 1:length(ls)
    if isfile( joinpath(path, ls[i]) )
      ext = split(ls[i], ".")
      if length(ext) > 1 && ext[1] != "" && occursin(exten, ext[end] )
        files(folder,ls[i])
      end
    elseif isdir( joinpath(path, ls[i]) )
      WebServer(joinpath(folder, ls[i]) ,exten)
    end
  end
end

export useCORS
function useCORS(activate::Bool)
  HTTP.setheader(my_headers,"Access-Control-Allow-Origin" => "*")
  HTTP.setheader(my_headers,"Access-Control-Allow-Methods" => "POST,GET,OPTIONS")
  return true
end

export headersalways
function headersalways(head::AbstractString,value::AbstractString)
  HTTP.setheader(my_headers,head => value)
end

export notfound
function notfound(text::String)
  if occursin(".html", text)
    notfound_message= File(text)
    addnotfound(notfound_message)
  else
    addnotfound(text)
  end
end

export webserverfiles
function webserverfiles(load::AbstractString)
  if load == "*"
    WebServer("", "")
  else
    WebServer("", load)
  end
end

export start
function start( ;host = "127.0.0.1", port = "8080", verbose = false)
  my_host = host
  if '.' in my_host 
    my_host = Sockets.IPv4(my_host) 
  elseif ':' in my_host 
    my_host = Sockets.IPv6(my_host) 
  end
  HTTP.serve(handler, my_host, port, verbose=verbose)
end
