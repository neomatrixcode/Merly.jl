


function addnotfound(message::String,routes)
  routes["notfound"] = (req,res) -> begin
    res.status = 404
    return message
  end
end

addnotfound("NotFound",routes)


function createurl(url::String,funtion::Function,routes_patterns,routes)
  if occursin(":",url)||occursin("(",url)
      url_ = "^"*url*"\$"
      url_ = replace(url_,":" => "(?<")
      url_ = replace(url_,">" => ">\\w+)")
      routes_patterns[Regex(url_)] = funtion
      @info("Url added",Regex(url_))
  else
    routes[url] = funtion
    @info("Url added",url)
  end
end

macro page(exp1,exp2)
  quote
    createurl("GET"*$exp1,(req,res)->$exp2,routes_patterns,routes)
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      createurl(i*$exp2,(req,res)->$exp3,routes_patterns,routes)
    end
  end
end

function Get(URL::String, fun::Function)
  createurl("GET"*URL,fun,routes_patterns,routes)
end

function Post(URL::String, fun::Function)
  createurl("POST"*URL,fun,routes_patterns,routes)
end

function Put(URL::String, fun::Function)
  createurl("PUT"*URL,fun,routes_patterns,routes)
end

function Delete(URL::String, fun::Function)
  createurl("DELETE"*URL,fun,routes_patterns,routes)
end