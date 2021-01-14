
function addnotfound(message::String,myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}})
  myendpoints[0] = [(route= "", toexec= function nf(req,res); res.status = 404; return message; end, urlparams= nothing)]
end


function createurlparams(url::String)
	params = Dict{Int64,String}()

    for (index, value) in enumerate(split(url,"/"))
    	if(length(value)>2 )
    		if (value[1] ==':')
               params[index] = value[2:end-1]
    		end
    		if (value[1] =='(')
    			params[index] = string(index)
    		end
    	end
    end

    url = replace(url, r":(.+)>" => s"\\w+")

  return (Regex(string("^"*url*"\$")), params)
end


function createurl(method::String,url::String,functiontoexec::Function,myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}},tonumber::Dict{String,Char},cleanurl::Function,createurlparams::Function)

	nvalues = 0
	myurlparams = nothing
	mycleanurl= cleanurl(url)

	if(length(url)>1)
		nvalues = length(split(mycleanurl,"/"))
	end


    if occursin(":",mycleanurl) || occursin("(",mycleanurl)
      mycleanurl, myurlparams = createurlparams(mycleanurl)
    end

	myroute = (route= mycleanurl, toexec= functiontoexec,  urlparams = myurlparams )


	indexsearch = parse(Int64, string(tonumber[method] , nvalues) )
    if haskey(myendpoints, indexsearch)
    	push!(myendpoints[indexsearch], myroute )
    else
        myendpoints[indexsearch] = [myroute]
    end

    @info("Url added",url)

end

macro page(exp1,exp2)
  quote
    createurl("GET",$exp1,(req,res)->$exp2,myendpoints,tonumber,cleanurl,createurlparams)
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      createurl(String(i),$exp2,$exp3,myendpoints,tonumber,cleanurl,createurlparams)
    end
  end
end

function Get(URL::String, fun::Function)
  createurl("GET",URL,fun,myendpoints,tonumber,cleanurl,createurlparams)
end

function Post(URL::String, fun::Function)
  createurl("POST",URL,fun,myendpoints,tonumber,cleanurl,createurlparams)
end

function Put(URL::String, fun::Function)
  createurl("PUT",URL,fun,myendpoints,tonumber,cleanurl,createurlparams)
end

function Delete(URL::String, fun::Function)
  createurl("DELETE",URL,fun,myendpoints,tonumber,cleanurl,createurlparams)
end