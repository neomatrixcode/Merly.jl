using Merly
using HTTP
using JSON
using BenchmarkTools

ip = "127.0.0.1"
port = 8086

@page "/" "Hello World!"

@page "/hola/:usr>" "<b>Hello {{usr}}!</b>"

@route GET "/get/:data1>" begin
  "get this back: {{data1}}"
end

@async start(host = ip, port = port, verbose = false)


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