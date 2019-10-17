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


struct app
  notfound::Function
  start::Function
  useCORS::Function
  webserverfiles::Function
  webserverpath::Function
  headersalways::Function

  function app()
    rootbase=pwd()

    function File(roop::String,file::String)
      path = normpath(rootbase*"/"*roop, file)
      return String(read(path))
    end

    function File(file::String)
      path = normpath(rootbase, file)
      return String(read(path))
    end

    function files(roop::String,file::String)
        extension="text/plain"
        ext= split(file,".")
        if(length(ext)>1)
          my_extension = ext[2]
          if (haskey(mimetypes,my_extension))
            extension=mimetypes[my_extension]
          end
        end
        data = File(roop,file[1:end])
        roop = replace(roop,"\\" => "/")
        createurl("GET"*roop*"/"*file,(req,res)->(begin
          res.headers["Content-Type"]= extension
          res.status = 200
          res.body= data
        end))
    end

    function WebServer(ruta::String,exten::String)
      cd(rootbase*"/"*ruta)
      ls= readdir()
      for i=1:length(ls)
        cd(rootbase*"/"*ruta)
        if isfile(ls[i])
          if ( (occursin(Regex("((.)*\\.(?!($exten)))"),ls[i])) && (!occursin(r"^(\.)",ls[i])))
            files(ruta,ls[i])
          end
        end
        if isdir(ls[i])
            WebServer(ruta*"/"*ls[i],exten)
        end
      end
    end

    function useCORS(activate::Bool)
     HTTP.setheader(my_headers,"Access-Control-Allow-Origin" => "*")
     HTTP.setheader(my_headers,"Access-Control-Allow-Methods" => "POST,GET,OPTIONS")
     return true
    end

    function headersalways(head::AbstractString,value::AbstractString)
      HTTP.setheader(my_headers,head => value)
    end

    function notfound(text::String)
      if occursin(".html", text)
        notfound_message= File(text)
        addnotfound(notfound_message)
      else
        addnotfound(text)
      end
    end

    function webserverfiles(load::AbstractString)
      if load=="*"
        WebServer("","")
      else
        WebServer("",load)
      end
    end

    function webserverpath(path::AbstractString)
      rootbase = path
    end

    function start(;config=Dict("host" => "127.0.0.1","port" => 8000)::Dict,verbose=false::Bool)
      port=get(config, "port", 8000)::Int
      my_host = get(config, "host", "127.0.0.1")::String
      if ('.' in my_host) host=Sockets.IPv4(my_host) end
      if (':' in my_host) host=Sockets.IPv6(my_host) end

      HTTP.serve(handler, host, port,verbose=verbose)
    end

    return new(notfound,start,useCORS,webserverfiles,webserverpath,headersalways)
  end
end