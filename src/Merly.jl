module Merly

using HttpServer,
      HttpCommon,
      JSON,
      XMLDict

export app, @route


b=[]

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
    Pag("GET",url,res)
end


macro route(exp1,exp2)
	quote
		push!(b,pag($exp1,$exp2))
	end
end

function _url(ruta, resource)
  params=Dict()
  query=Dict()

  resource = split(resource,"?")
  try
    if length(resource[2])>=1
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
    return s,params,query
  end
  return false,params,query
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
  println("resource: ",req.resource)
  println("method: ",req.method)
  println("headers: ",req.headers)
  println("")

  tam= length(b)
  if tam>0
    he = HttpCommon.headers()
    for s=1:tam
      pasa,params,query=_url(b[s].route,req.resource)
      if pasa
        if ismatch(Regex(b[s].method),req.method)

      		h=he
          println("params: ",params)
          println("query: ",query)
          respond= try b[s].state catch "" end
          println("b[s].method: ",b[s].method)

          if !(ismatch(Regex("GET"),req.method))
            println("interpetando los Bytes de req.data como caracteres: ")
            body= _body(req.data,req.headers["Accept"])
            println(body)
          end

          #----------aqui escribe el programador-----------

          h["Content-Type"]="text/plain"

      		res.status = 200

          #----------------------------------------------

          sal = matchall(Regex("{{([A-Z]|[a-z]|[0-9])*}}"),respond)
          d=length(sal)
          try
            if d>0
              for i=1:d
                respond = replace(respond,Regex(sal[i]),params["$(sal[i][3:end-2])"])
              end
            end
          end

          res.headers=h
      		res.data=respond # manipulas cada parametro
          println(respond)
          params=Dict()
          query=Dict()
        else
            res.status = 404
        end

    		return res  #Response(200,h,b[s].state)
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
