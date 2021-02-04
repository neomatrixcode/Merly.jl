using Merly
using HTTP
using BenchmarkTools

ip = "127.0.0.1"
port = 8086


function authenticate(request, HTTP)
  isAuthenticated = false

  if (request.params["status"] === "authenticated")
    isAuthenticated = true
  end

  return request, HTTP, isAuthenticated
end



Get("/verify/:status",

  (result(;middleware=authenticate) = (request, HTTP)-> begin

      myfunction = (request, HTTP, isAuthenticated)-> begin

      if (isAuthenticated == false )
          return  HTTP.Response(403,string("Unauthenticated. Please signup!"))
      end
                return  HTTP.Response(200,string("<b>verify !</b>"))
      end

      return myfunction(middleware(request,HTTP)...)

  end)()

)

@page "/" HTTP.Response(200,"Hello World!")

@page "/url1" HTTP.Response(200,"test1")
@page "/url2" HTTP.Response(200,"test2")
@page "/hola/:usr" HTTP.Response(200,"<b>Hello {{usr}}!</b>")

@page "/hola2/:usr" begin
	HTTP.Response(200,string("<b>Hello2",request.params["usr"],"!</b>"))
	end

@route GET "/get/:data1" begin
HTTP.Response(200,string("get this back:",request.params["data1"],"!</b>"))
end

@async start()

#------------------04/02/2021-------------------------------
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/verify/authenticated"))
# 136.400 μs (535 allocations: 30.41 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/"))
# 134.800 μs (527 allocations: 29.41 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/?hola=5"))
# 137.600 μs (540 allocations: 30.63 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/url2"))
# 135.500 μs (533 allocations: 29.78 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/url1"))
# 135.900 μs (530 allocations: 29.61 KiB)
# @btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 137.199 μs (536 allocations: 30.41 KiB)
# @btime r= HTTP.get("http://$(ip):$(port)/get/testdata")
# 137.999 μs (539 allocations: 30.56 KiB)
#------------------02/02/2021-------------------------------
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/verify"))
# 118.799 μs (259 allocations: 15.50 KiB)
#------------------01/02/2021-------------------------------
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/verify"))
# 120.400 μs (259 allocations: 15.50 KiB)
#------------------12/01/2021-------------------------------
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/"))
# 119.701 μs (263 allocations: 15.20 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/?hola=5"))
# 122.900 μs (251 allocations: 15.02 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/urll2"))
# 118.100 μs (251 allocations: 15.00 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/url2"))
# 120.199 μs (264 allocations: 15.27 KiB)
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/url2/"))
# 123.999 μs (251 allocations: 14.98 KiB)
# @btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 120.900 μs (264 allocations: 15.27 KiB)
# @btime r= HTTP.get("http://$(ip):$(port)/get/testdata")
# 122.500 μs (251 allocations: 15.05 KiB)

#------------------11/01/2021-------------------------------
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/"))
# 118.700 μs (250 allocations: 14.97 KiB) -- 11/01/2021
# 119.499 μs (251 allocations: 15.00 KiB) -- 11/01/2021 08:14 [ejecutando la funcion]
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/?hola=5"))
# 132.400 μs (251 allocations: 15.00 KiB) -- 11/01/2021 08:14 [ejecutando la funcion]
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/urll2"))
# 123.900 μs (251 allocations: 15.00 KiB) [ejecutando la funcion]
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/url2"))
# 122.100 μs (251 allocations: 14.98 KiB) [ejecutando la funcion]


#------------------02/01/2021-------------------------------
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/"))
# 80.100 μs (247 allocations: 14.84 KiB) [minimo]
# 82.400 μs (247 allocations: 14.84 KiB) [sin la ejecucion de la funcion]
# 83.600 μs (247 allocations: 14.84 KiB) -- 09/01/2021 [sin la ejecucion de la funcion]
# 114.199 μs (250 allocations: 14.97 KiB) [ejecutando la funcion]
# @btime r=HTTP.request("GET", string("http://",ip,":",port,"/?hola=5"))
# 91.600 μs (247 allocations: 14.86 KiB)
# 93.900 μs (247 allocations: 14.86 KiB)[sin la ejecucion de la funcion]

#------------------01/01/2021-------------------------------
# @btime r= HTTP.get(string("http://",ip,":",port,"/"))
# 115.700 μs (272 allocations: 15.70 KiB)
# @btime HTTP.get(string("http://",ip,":",port,"/?hola=5"))
# 125.200 μs (273 allocations: 15.77 KiB)
# @btime HTTP.get(string("http://",ip,":",port,"/hola/usuario"))
# 150.600 μs (259 allocations: 15.50 KiB)
# @btime r= HTTP.get(string("http://",ip,":",port,"/get/testdata"))
# 144.700 μs (259 allocations: 15.50 KiB)

#------------------31/12/2020-------------------------------
# @btime r= HTTP.get("http://$(ip):$(port)/")
# 131.100 μs (539 allocations: 30.03 KiB)
# @btime HTTP.get("http://$(ip):$(port)/?hola=5")
# 140.601 μs (574 allocations: 32.75 KiB)
# @btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 165.399 μs (568 allocations: 31.61 KiB)
# @btime r= HTTP.get("http://$(ip):$(port)/get/testdata")
# 165.300 μs (564 allocations: 31.50 KiB)

#------------------29/12/2020-------------------------------
# @btime r= HTTP.get("http://$(ip):$(port)/")
# 125.899 μs (510 allocations: 29.94 KiB)
# @btime HTTP.get("http://$(ip):$(port)/?hola=5")
# 144.100 μs (575 allocations: 32.80 KiB)
# @btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 171.801 μs (569 allocations: 31.66 KiB)
# @btime r= HTTP.get("http://$(ip):$(port)/get/testdata")
#  164.800 μs (565 allocations: 31.55 KiB)

#------------------27/12/2020-------------------------------
# @btime r= HTTP.get("http://$(ip):$(port)/")
# 132.400 μs (540 allocations: 30.08 KiB)
# @btime HTTP.get("http://$(ip):$(port)/?hola=5")
# 141.000 μs (575 allocations: 32.80 KiB)
# @btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 164.300 μs (563 allocations: 31.50 KiB)
# @btime r= HTTP.get("http://$(ip):$(port)/get/testdata")
# 165.600 μs (564 allocations: 31.53 KiB)

#------------------26/12/2020-------------------------------
# @btime HTTP.get("http://$(ip):$(port)/?hola=5")
# 140.401 μs (575 allocations: 32.80 KiB)
# @btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 163.801 μs (563 allocations: 31.50 KiB)
# @btime r= HTTP.get("http://$(ip):$(port)/get/testdata")
# 163.799 μs (522 allocations: 31.17 KiB)

#-------------------------------------------------
#@btime HTTP.get("http://$(ip):$(port)/?hola=5")
# 3.864 ms (8304 allocations: 381.20 KiB)
# 453.803 μs (748 allocations: 30.92 KiB)
#@btime HTTP.get("http://$(ip):$(port)/hola/usuario")
# 4.211 ms (7685 allocations: 353.44 KiB)
# 483.861 μs (743 allocations: 30.41 KiB)
#@benchmark r= HTTP.get("http://$(ip):$(port)/get/testdata")
# 3.906 ms (7693 allocations: 353.78 KiB)
# 484.960 μs (744 allocations: 30.44 KiB)
#=
 minimum time:     740.087 μs (0.00% GC)
  median time:      843.457 μs (0.00% GC)
  mean time:        1.099 ms (1.45% GC)
  maximum time:     367.611 ms (0.00% GC)
=#
