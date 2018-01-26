
|(x::String, y::String)="$x|$y"

POST="POST"
PUT="PUT"
DELETE="DELETE"
GET="GET"

function  processtext(text::String)
    text = "^"*text*"\$"
  try
    text = replace(text,"/:","/(?<")
    text = replace(text,">",">[a-z]+)")
    return Regex(text)
  catch
    warn("Error in the format of the route, verify it")
    return Regex(text)
  end
end

function NotFound(q,req,res)
  #global nfmessage
  res.status = 404
  res.data = q.notfound_message
end

routes=Dict()
routes["notfound"] = NotFound

macro page(exp1,exp2)
  quote
    text= processtext("GET"*$exp1)
    routes[text] = (q,req,r)->$exp2
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      text= processtext(i*$exp2)
      routes[text] = (q,req,r)->$exp3
    end
  end
end

function Get(URL::String, fun::Function)
  text= processtext("GET"*URL)
  routes[text] = fun
end

function Post(URL::String, fun::Function)
  text= processtext("POST"*URL)
  routes[text] = fun
end

function Put(URL::String, fun::Function)
  text= processtext("PUT"*URL)
  routes[text] = fun
end

function Delete(URL::String, fun::Function)
  text= processtext("DELETE"*URL)
  routes[text] = fun
end