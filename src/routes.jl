
|(x::String, y::String)="$x|$y"

POST="POST"
PUT="PUT"
DELETE="DELETE"
GET="GET"

routes=Dict()

macro page(exp1,exp2)
  quote
    routes["GET"*$exp1] = (q,req,r)->$exp2
    println(routes)
  end
end

macro route(exp1,exp2,exp3)
  quote
    routes[$exp1*$exp2] = (q,req,r)->$exp
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