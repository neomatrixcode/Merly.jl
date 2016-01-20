module Merly

using HttpServer,
      HttpCommon,
      JSON,
      XMLDict

export app, @route


b=[]
params=Dict()
query=Dict()
NotFound = Response(404)


type Pag
	method
    route
    state
end

type Fram
	start::Function
end

function pag(url,res)
    Pag("Get",url,res)
end


macro route(exp1,exp2)
	quote
		push!(b,pag($exp1,$exp2))
	end
end

function _url(ruta, resource)
  resource = split(resource,"?")
  try
    if length(resource[2])>=1
      global query
      query=parsequerystring(resource[2])
    end
  end

  resource = split(resource[1],"/")
  resource =resource[2:length(resource)]

  ruta = split(ruta,"/")
  ruta =ruta[2:length(ruta)]

  lruta=length(ruta)
  lresource=length(resource)
  if ruta[end]==""
    lruta=lruta-1
  end

  if resource[end]==""
    lresource=lresource-1
  end

  s=true

  if(lruta==lresource)
    for i=1:lruta
      if length(ruta[i])>=1
        if !(ruta[i][1]==':')
          println("ruta:  ",Regex(ruta[i]))
          println("entrada:  ",resource[i])
          println((ismatch(Regex(ruta[i]),resource[i])))
          s=s && (ismatch(Regex(ruta[i]),resource[i]))
        else
          r=ruta[i][2:length(ruta[i])]
          params[r]=resource[i]
        end
      end
    end
    return s
  end
  return false
end

function _body(data,ty)
  bo="{}"
  if(length(data)>=1)
    bo=""
    for i=1:length(data)
      bo*="$(Char(data[i]))"
    end
  end

  if ismatch(Regex("application/json"),ty)
    body= JSON.parse(bo)
    return body
  end
  if ismatch(Regex("application/xml"),ty)
    body= xml_dict(bo)
    return body
  end

  return bo
end

function handler(b,req,res)
  println("datos del request:")
  println(req.resource)
  println(req.method)
  println(req.headers)
  println(req.headers["Content-Type"])
  println("")

  tam= length(b)

  if tam>0
    h = HttpCommon.headers()
    for s=1:tam
    	if _url(b[s].route,req.resource)
        body= _body(req.data,req.headers["Accept"])
    		h["Content-Type"]="text/plain"
        global params
        global query
        println(params)
        println(query)
        println("interpetando los Bytes de req.data como caracteres: ")
        println(body)
        res.headers=h
    		res.status = 200
    		res.data=b[s].state # manipulas cada parametro
        params=Dict()
        query=Dict()
    		return res#Response(200,h,b[s].state)
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



#_url("/home/[A-Z]{1,3}/","/home/AZR/")
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
