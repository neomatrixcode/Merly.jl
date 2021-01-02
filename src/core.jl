
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

	function searchroute_regex(ruta::String,routes_patterns::Dict{Regex, Function})

	  #@info ("url a filtrar", ruta)
	  #@info("dato del filter",filter(tuple -> occursin(first(tuple),ruta), collect(routes_patterns)))
	  #= ┌ Info: dato del filter
	  └   first(filter((tuple->begin
	                #= C:\Users\josue\.julia\dev\Merly\src\core.jl:27 =#
	                occursin(first(tuple), ruta)
	            end), collect(routes_patterns))) =

	            [Pair{Regex,Function}(r"^GET/hola/(?<usr>\w+)$", var"#3#4"())]
	  =#
	  for (k,v) in routes_patterns
	    if(occursin(k,ruta))
	      return k
	    end
	 end

	 return ""
	end


function my_handler(routes::Dict{String, Function}, routes_patterns::Dict{Regex, Function})

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


	  result = get(routes, searchroute, -1)

	  if (typeof(result)!= Int64)
	    response.body = result(my_request,response)
	  else
	    pattern = searchroute_regex(searchroute,routes_patterns)
	    if (typeof(pattern) <:Regex)
	      my_request.params = match(pattern,searchroute)
	      _function = getindex(routes_patterns,pattern)
	      response.body = _function(my_request,response)
	      sal = collect((m.match for m = eachmatch(Regex("{{(\\w\\d*)+}}"), response.body)))
	      for i in sal
	        response.body = replace(response.body,Regex(i) => my_request.params[ string(i[3:end-2])])
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

    ()->(handler)
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
	    addnotfound(notfound_message,routes)
	  else
	    addnotfound(text,routes)
	  end
	end



	function start( ;host = "127.0.0.1", port = "8080", verbose = false)
	  my_host = host
	  if '.' in my_host
	    my_host = Sockets.IPv4(my_host)
	  elseif ':' in my_host
	    my_host = Sockets.IPv6(my_host)
	  end
      Handler = my_handler(routes,routes_patterns)
	  HTTP.serve(Handler.handler, my_host, port, verbose=verbose)
	end