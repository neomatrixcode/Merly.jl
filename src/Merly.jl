module Merly

using HttpServer,
      HttpCommon

export app, @route

type Pag
	method
    route::Regex
    state
end

type Fram
	start::Function
end

function pag(url::Regex,res)
    Pag("Get",url,res)
end

NotFound = Response(404)

b=[]

macro route(exp1,exp2)
	quote
		push!(b,pag(Regex($exp1),$exp2))
	end
end


function handler(b,req,res)
println("datos del request:")
println(req.resource)
println(req.method)
println(req.headers)
println(req.headers["Content-Type"])
println(req.data)
println("interpetando los Bytes de req.data como caracteres: ")
 for i=1:length(req.data)
       print(Char(req.data[i]))
       end
println("\n--")
tam= length(b)

if tam>0
h = HttpCommon.headers()
for s=1:tam
	if ismatch(b[s].route,req.resource)
		h["Content-Type"]="text/plain"
		return Response(200,h,b[s].state)
	end
end
end
return NotFound
end



function app()

 function start(host="localhost",port=8000)
 http = HttpHandler((req, res)-> handler(b,req,res))
http.events["error"]  = (client, error) -> println(error)
http.events["listen"] = (port)          -> println("Listening on $port...")
server = Server(http)
run(server, host=IPv4(127,0,0,1), port=8000)
end

return Fram(start)
end






end # module


#=
function route(handler::Function, app::App, methods::Int, path::String)
  
end
route(a::App, m::Int, p::String, h::Function) = route(h, a, m, p)

get(h::Function, a::App, p::String)    = route(h, a, GET, p)
post(h::Function, a::App, p::String)   = route(h, a, POST, p)
put(h::Function, a::App, p::String)    = route(h, a, PUT, p)
update(h::Function, a::App, p::String) = route(h, a, UPDATE, p)
delete(h::Function, a::App, p::String) = route(h, a, DELETE, p)
=#