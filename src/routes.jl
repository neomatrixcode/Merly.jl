
|(x::String, y::String)="$x|$y"

GET="GET"
POST="POST"
PUT="PUT"
DELETE="DELETE"
HEAD = "HEAD"
OPTIONS = "OPTIONS"
PATCH = "PATCH"

function NotFound(q,req,res)
  res.status = 404
  return notfound_message
end

routes=Dict()
routes_array=[]
routes_patterns=Dict()
routes_patterns_array=[]
routes["notfound"] = NotFound

function createurl(url::String,funtion::Function)
  if occursin(":",url)||occursin("(",url)
      url_ = "^"*url*"\$"
      url_ = replace(url_,":" => "(?<")
      url_ = replace(url_,">" => ">\\w+)")
      routes_patterns[Regex(url_)] = funtion
      push!(routes_patterns_array,Regex(url_))
      @info("Url added",Regex(url_))
  else
    routes[url] = funtion
    push!(routes_array,url)
    @info("Url added",url)
  end
end

macro page(exp1,exp2)
  quote
    createurl("GET"*$exp1,(q,req,res)->$exp2)
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      createurl(i*$exp2,(q,req,res)->$exp3)
    end
  end
end

function Get(URL::String, fun::Function)
  createurl("GET"*URL,fun)
end

function Post(URL::String, fun::Function)
  createurl("POST"*URL,fun)
end

function Put(URL::String, fun::Function)
  createurl("PUT"*URL,fun)
end

function Delete(URL::String, fun::Function)
  createurl("DELETE"*URL,fun)
end