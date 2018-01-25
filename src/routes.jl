
|(x::String, y::String)="$x|$y"

POST="POST"
PUT="PUT"
DELETE="DELETE"
GET="GET"

function NotFound(q,req,res)
  #global nfmessage
  res.status = 404
  res.data = q.notfound_message
end

routes=Dict()
routes["notfound"] = NotFound

macro page(exp1,exp2)
  quote
    routes["GET"*$exp1] = (q,req,r)->$exp2
    println(routes)
  end
end

macro route(exp1,exp2,exp3)
  quote
    verbs= split($exp1,"|")
    for i=verbs
      routes[i*$exp2] = (q,req,r)->$exp3
    end
    println(routes)
  end
end

function Get(URL::String, fun::Function)
  routes["GET"*URL] = fun
end

function Post(URL::String, fun::Function)
  routes["POST"*URL] = fun
  println(routes)
end

function Put(URL::String, fun::Function)
  routes["PUT"*URL] = fun
end

function Delete(URL::String, fun::Function)
  routes["DELETE"*URL] = fun
end