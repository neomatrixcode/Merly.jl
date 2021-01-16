
function addnotfound(message::String,myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}})
  myendpoints[0] = [(route= "", toexec= function nf(req,res); res.status = 404; return message; end, urlparams= nothing)]
end


function createurlparams(url::String)::Dict{Int64,String}
	params = Dict{Int64,String}()

    for (index, value) in enumerate(split(url,"/"))
    	if(length(value)>1 )
    		if (value[1] ==':')
               params[index] = value[2:end]
    		end
    		if (value[1] =='(')
    			params[index] = string(index)
    		end
    	end
    end

    return params
end

function convertregex(url::String)::Regex

	if occursin(":",url)
		url = replace(url, r":(\w+)" => s"\\w+")
	end

	return Regex(string("^",url,"\$"))
end


function createurl(method::String,url::String,functiontoexec::Function,myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}},tonumber::Dict{String,Char},cleanurl::Function,createurlparams::Function,convertregex::Function)::Nothing

	nvalues::Int64 = 0
	myurlparams::Union{Nothing,Dict{Int64,String}} = nothing
	mycleanurl::Union{String,Regex} = cleanurl(url)

	if(length(url)>1)
		nvalues = length(split(mycleanurl,"/"))
	end

    if occursin(":",mycleanurl) || occursin("(",mycleanurl)
      myurlparams = createurlparams(mycleanurl)
      mycleanurl = convertregex(mycleanurl)
    end

	myroute::NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}} = (route= mycleanurl, toexec= functiontoexec,  urlparams = myurlparams )
	indexsearch::Int64 = parse(Int64, string(tonumber[method] , nvalues))

    if haskey(myendpoints, indexsearch)
    	push!(myendpoints[indexsearch], myroute )
    else
        myendpoints[indexsearch] = [myroute]
    end

    @info(url)

end

macro page(exp1::String,exp2::Union{String,Expr})
	quote
    createurl("GET",$exp1,((req,res)->$exp2 ),myendpoints,tonumber,cleanurl,createurlparams,convertregex)
    end
end

macro page(exp1::String, exp2::Expr ,exp3::Expr)
    parameters = repr(exp2)[3:end-1]
    quote
    createurl("GET",$exp1,( $(Meta.parse(string("myfunction", parameters))) = (req,res)->$exp3 )(),myendpoints,tonumber,cleanurl,createurlparams,convertregex)
    end
end

macro route(exp1,exp2::String,exp3::Expr)
  quote
    for i in split($exp1,"|")
      createurl(String(i),$exp2,((req,res)->$exp3),myendpoints,tonumber,cleanurl,createurlparams,convertregex)
    end
  end
end


macro route(exp1,exp2::String,exp3::Expr, exp4::Expr)
  parameters = repr(exp3)[3:end-1]
  quote
    for i in split($exp1,"|")
      createurl(String(i),$exp2,( $(Meta.parse(string("myfunction", parameters))) = (req,res)->$exp4 )(),myendpoints,tonumber,cleanurl,createurlparams,convertregex)
    end
  end
end

function Get(URL::String, fun::Function)::Nothing
  createurl("GET",URL,fun,myendpoints,tonumber,cleanurl,createurlparams,convertregex)
end

function Post(URL::String, fun::Function)::Nothing
  createurl("POST",URL,fun,myendpoints,tonumber,cleanurl,createurlparams,convertregex)
end

function Put(URL::String, fun::Function)::Nothing
  createurl("PUT",URL,fun,myendpoints,tonumber,cleanurl,createurlparams,convertregex)
end

function Delete(URL::String, fun::Function)::Nothing
  createurl("DELETE",URL,fun,myendpoints,tonumber,cleanurl,createurlparams,convertregex)
end