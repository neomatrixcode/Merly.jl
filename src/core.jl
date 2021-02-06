
function my_handler(myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}},tonumber::Dict{String,Char},formats::Dict{String,Function},cleanurl::Function,constantheaders::Array{Pair{String,String},1})

	function myqueryparams(input::SubString{String})::Dict{String,String}
		salida = Dict{String,String}()
        for e in split(input,"&")
        	items = split(e,"=")
        	if (length(items)==2)
        		salida[items[1]]=items[2]
            end
        end
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

	function processrequest(request::HTTP.Request)

		data = split(request.target,"?")
		nvalues= 0
	    body = ""
	    myquery= Dict()

	    mycleanurl= cleanurl(data[1])
	    if(length(data[1])>1)
		  nvalues = length(split(mycleanurl,"/"))
		end

	    if(!eof(IOBuffer(HTTP.payload(request))))
	    	body = get(formats, HTTP.header(request,"Content-Type"), formats["*/*"] )(String(request.body))
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

	function service(myrequest)
		myresponse = HTTP

		myparams = Dict{String,String}()
		result = get(myendpoints, myrequest.searchroute, 1)

		if (typeof(result)!== Int64)
			f = iterate(Iterators.filter(search(myrequest.url).run, result))

			if f !== nothing

				if f[1].urlparams !== nothing
					myparams = urlparams(myrequest.url, f[1].urlparams)
				end


				return f[1].toexec(
			   	(
			   		 query = myrequest.query
			   		,body = myrequest.body
			   		,headers = myrequest.headers
			   		,params= myparams
			   	)
				,myresponse
			    )

		   end
		end

		return myendpoints[0][1].toexec(myrequest,myresponse)
	end


	function handler(request::HTTP.Request)
              myresponse = service(processrequest(request))
              map( x -> HTTP.setheader(myresponse,x ), constantheaders)
              return myresponse
	end

    ()->(handler)
end

	function useCORS(;AllowOrigins::String = "*", AllowHeaders::String = "Origin, Content-Type, Accept", AllowMethods::String = "GET,POST,PUT,DELETE", MaxAge::String = "178000")
		headersalways(["Access-Control-Allow-Origin" => AllowOrigins])
		CORSenabled[1] = (request, HTTP) -> begin

        return HTTP.Response(200
        	, HTTP.mkheaders(["Content-Type" => "text/plain"
			,"Access-Control-Allow-Methods" => AllowMethods
        	,"Access-Control-Allow-Headers" => AllowHeaders
        	,"Access-Control-Max-Age" => MaxAge])
        	, body="")
        end

	end


	function headersalways(values::Array{Pair{String,String},1})
	  map( x -> push!(constantheaders, x), values)
	  @info(values)
	end

	function notfound(text::String)
	  if occursin(".html", text)
	    notfound_message= File(text)
	    addnotfound(notfound_message,myendpoints)
	  else
	    addnotfound(text,myendpoints)
	  end
	end

	function start( ;host::String = "127.0.0.1", port::Int64 = 8086, verbose::Bool = false, sslconfig::Union{MbedTLS.SSLConfig, Nothing}=nothing)
		Handler = my_handler(myendpoints,tonumber,formats,cleanurl,constantheaders)
		if ':' in host
			HTTP.serve(Handler.handler, Sockets.IPv6(host), port, verbose=verbose, sslconfig=sslconfig)
		end

		HTTP.serve(Handler.handler, Sockets.IPv4(host), port, verbose=verbose, sslconfig=sslconfig)
	end