
mutable struct myresponse
  status::Int
  headers::Dict
  body::String
  function myresponse(code)
      new(code,Dict(),"")
  end
end


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

function createrequest(request::HTTP.Request)

	data = split(request.target,"?")
    body = getindex(formats, HTTP.header(request,"Content-Type"))(String(request.body))

    return (
		 query = (length(data)>1 ? HTTP.queryparams(data[2]) : Dict())
		,body = body
		,headers = request.headers
		,searchroute = request.method*data[1]
    )

end

function my_handler(routes::Dict{String, Function}, routes_patterns::Dict{Regex, Function})

	my_headers= HTTP.mkheaders(["Content-Type" => "text/plain"])

	function handler(request::HTTP.Request)

		my_request = createrequest(request)

		result = get(routes, my_request.searchroute, -1)


		#if (typeof(result)== Int64)
		#	return HTTP.Response(404, getindex(routes, "notfound")(my_request,""))
		#end

		return HTTP.Response(200, "")
#=

		#response = myresponse(200)



	  if (typeof(result)!= Int64)
	    return HTTP.Response(200, result(my_request,""))
	  else
	   #= pattern = searchroute_regex(my_request.searchroute,routes_patterns)
	    if (typeof(pattern) <:Regex)
	      params = match(pattern,my_request.searchroute)
	      _function = getindex(routes_patterns,pattern)
	      response.body = _function(my_request,response)
	      sal = collect((m.match for m = eachmatch(Regex("{{(\\w\\d*)+}}"), response.body)))
	      for i in sal
	        response.body = replace(response.body,Regex(i) => params[ string(i[3:end-2])])
	      end
	    else=#
	      return HTTP.Response(404, getindex(routes, "notfound")(my_request,""))
	    #end
	  end
	 # responsefinal = HTTP.Response(response.status,my_headers, body=response.body)
	 # for (key, value) in response.headers
	  #  HTTP.setheader(responsefinal,key => value )
	  #end
	  return HTTP.Response(200, response.body)=#
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



	function start( ;host::String = "127.0.0.1", port::Int64 = 8086, verbose::Bool = false)
	  Handler = my_handler(routes,routes_patterns)
	  if ':' in host
	    HTTP.serve(Handler.handler, Sockets.IPv6(host), port, verbose=verbose)
	  end
	  HTTP.serve(Handler.handler, Sockets.IPv4(host), port, verbose=verbose)
	end