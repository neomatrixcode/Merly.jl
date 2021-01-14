
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


function my_handler(myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}},tonumber::Dict{String,Char},formats::Dict{String,Function},cleanurl::Function)

	my_headers= HTTP.mkheaders(["Content-Type" => "text/plain"])

	function myqueryparams(input::SubString{String})::Dict{String,String}
		salida = Dict{String,String}()
        for e in split(input,"&")
        	items = split(e,"=")
        	if (length(items)==2)
        		salida[items[1]]=items[2]
            end
        end   #1.030 μs (17 allocations: 992 bytes)
        return salida
	end

	function urlparams(input::String,params::Dict{Int64,String})::Dict{String,String}
		salida = Dict{String,String}()

        for (index, value) in enumerate(split(input,"/"))
        	if haskey(params, index)
        		salida[params[index]]=value
            end
        end #845.574 ns (16 allocations: 768 bytes)

        return salida
	end

	function createrequest(request::HTTP.Request)

		data = split(request.target,"?")
		nvalues= 0
	    body = ""
	    myquery= Dict()

	    mycleanurl= cleanurl(data[1])
	    if(length(data[1])>1)
		  nvalues = length(split(mycleanurl,"/"))
		end

	    if(!eof(IOBuffer(HTTP.payload(request))))
	    	body = getindex(formats, HTTP.header(request,"Content-Type"))(String(request.body))
        end

        if (length(data)>1)
            myquery = myqueryparams(data[2])
        end

	    return (
			 query = myquery
			,body = body
			,headers = request.headers
			,searchroute = parse(Int64, string(tonumber[request.method] , nvalues) )
			,url = mycleanurl
	    )

    end

	function search(value)
	    function run(item)
			return occursin(item.route,value)
		end
		()-> (run)
	end

	function handler(request::HTTP.Request)

		my_request = createrequest(request)
		result = get(myendpoints, my_request.searchroute, 1)
		params = Dict{String,String}()
        response = myresponse(200)

		if (typeof(result)!== Int64)

		   f = iterate(Iterators.filter(search(my_request.url).run, result))
		   if f !== nothing
		   	 if f[1].urlparams !== nothing
		   	 	params = urlparams(my_request.url, f[1].urlparams)
		   	 end
		   	 return f[1].toexec(my_request,response)
		   end

           return myendpoints[0][1].toexec(my_request,response)
		end

		return myendpoints[0][1].toexec(my_request,response)

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
	  Handler = my_handler(myendpoints,tonumber,formats,cleanurl)
	  if ':' in host
	    HTTP.serve(Handler.handler, Sockets.IPv6(host), port, verbose=verbose)
	  end
	  HTTP.serve(Handler.handler, Sockets.IPv4(host), port, verbose=verbose)
	end