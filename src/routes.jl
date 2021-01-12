
function addnotfound(message::String,myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec),Tuple{Union{Regex, String},Function}},1}})
  myendpoints[0] = [(route= "", toexec= function nf(req,res); res.status = 404; return message; end)]
end


function cleanurl(url::Union{SubString{String},String})::String

  indexinit::Int64 = 1
  indexend::Int64 = length(url)

  if url[1] == '/'
  	indexinit=2
  end

  if url[indexend] == '/'
    indexend = indexend-1
  end

  return url[indexinit:indexend]

end



function toregex(url::String)
 if occursin(":",url)||occursin("(",url)
      url_ = "^"*url*"\$"
      url_ = replace(url_,":" => "")
      url_ = replace(url_,">" => "\\w+)")
  end
end


function createurl(method::String,url::String,functiontoexec::Function,myendpoints::Dict{Int64,Array{NamedTuple{(:route, :toexec),Tuple{Union{Regex, String},Function}},1}},tonumber::Dict{String,Char},cleanurl::Function)

	nvalues= 0

    if(length(url)>1)
		mycleanurl= cleanurl(url)
		nvalues = length(split(mycleanurl,"/"))
	end

  indexsearch = parse(Int64, string(tonumber[method] , nvalues) )

  myroute = (route= url, toexec= functiontoexec )

    if haskey(myendpoints, indexsearch)
    	push!(myendpoints[indexsearch], myroute )
    else
        myendpoints[indexsearch] = [myroute]
    end

  @info("Url added",url)

end

macro page(exp1,exp2)
  quote
    createurl("GET",$exp1,(req,res)->$exp2,myendpoints,tonumber,cleanurl)
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      createurl(i,$exp2,$exp3,myendpoints,tonumber,cleanurl)
    end
  end
end

function Get(URL::String, fun::Function)
  createurl("GET",URL,fun,myendpoints,tonumber,cleanurl)
end

function Post(URL::String, fun::Function)
  createurl("POST",URL,fun,myendpoints,tonumber,cleanurl)
end

function Put(URL::String, fun::Function)
  createurl("PUT",URL,fun,myendpoints,tonumber,cleanurl)
end

function Delete(URL::String, fun::Function)
  createurl("DELETE",URL,fun,myendpoints,tonumber,cleanurl)
end