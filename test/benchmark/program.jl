using Merly
using HTTP
using BenchmarkTools

ip = "127.0.0.1"
port = 8086

u= 1

Static("/", "./public"


#middleware
function authenticate(req, res, next) {
  if (req.params.status === "authenticated") {
    req.isAuthenticated = true
  } else {
    req.isAuthenticated = false
  }
  next();
}



Get('/verify/:status/:role/:userId', authenticate, function (req, res) {
  if(req.isAuthenticated == false){
    res.status(403);
    res.send('Unauthenticated. Please signup!');
    return
  }
  res.send('Redirecting ' + req.redirectRoute);
});



@page "/" "Hello World!"

@page "/url1" "test1"
@page "/url2" "test2"
@page "/hola/:usr" "<b>Hello {{usr}}!</b>"

@page "/hola2/:usr" begin
    u=u+1
	"<b>Hello2 {{usr}}!</b>"
	end

@route GET "/get/:data1" begin
  "get this back: {{data1}}"
end

@async start()

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
