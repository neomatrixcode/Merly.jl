
|(x::String, y::String)="$x|$y"

GET="GET"
POST="POST"
PUT="PUT"
DELETE="DELETE"
HEAD = "HEAD"
OPTIONS = "OPTIONS"
PATCH = "PATCH"

function NotFound(q,req,res)
  #global nfmessage
  res.status = 404
  res.data = q.notfound_message
end

routes=Dict()
routes_patterns=Dict()
routes["notfound"] = NotFound

function  createurl(text::String,funtion::Function)
  if contains(text, ":")||contains(text, "(")
    try
      text_ = "^"*text*"\$"
      text_ = replace(text_,"/:","/(?<")
      text_ = replace(text_,">",">[a-z]+)")
      routes_patterns[Regex(text_)] = funtion
    catch
     warn("Error in the format of the route $text, verify it\n \"VERB/get/:data>\" \n \"VERB/get/([0-9])\"")
    end
  else
    routes[text] = funtion
  end
end

macro page(exp1,exp2)
  quote
    createurl("GET"*$exp1,(q,req,r)->$exp2)
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      createurl(i*$exp2,(q,req,r)->$exp3)
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