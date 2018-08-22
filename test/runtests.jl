using Merly
using Test
using HTTP
using JSON
#using Pkg
#Pkg.add("BenchmarkTools")
#using BenchmarkTools

ip = "127.0.0.1" #127.0.0.1
port = 8086
# write your own tests here
server = Merly.app()

@test server.useCORS(true) == true

@test server.notfound("<!DOCTYPE html>
              <html>
              <head><title>Not found</title></head>
              <body><h1>404, Not found</h1></body>
              </html>") == "<!DOCTYPE html>
              <html>
              <head><title>Not found</title></head>
              <body><h1>404, Not found</h1></body>
              </html>"

u="hello"

@page "/" "Hello World!"
@page "/hola/:usr>" "<b>Hello {{usr}}!</b>"

@route GET "/get/:data>" begin
  "get this back: {{data}}"
end

@route GET "/regex/(\\w+\\d+)" begin

  println("req.version ",req.version)
  println("req.headers ",req.headers)

   "datos $(req.params[1])"
end

@route POST "/post" begin
  res.body = "I did something!"
end

@route POST|PUT|DELETE "/" begin
  println("params: ",req.params)
  println("query: ",req.query)
  println("body: ",req.body)

  res.headers["Content-Type"]= "text/plain"

  "I did something!"
end

Get("/data", (req,res)->(begin
  res.headers["Content-Type"]= "text/plain"
  println("params: ",req.params)
  println("query: ",req.query)
  u*"data"
end))

Post("/data", (req,res)->(begin
  println("params: ",req.params)
  println("query: ",req.query)
  println("body: ",req.body)
  res.headers["Content-Type"]= "text/plain"
  global u="bye"
  "I did something!"
end))

server.webserverfiles("jl")

@async server.start(Dict("host" => "$(ip)","port" => port))

sleep(2)

r = HTTP.get("http://$(ip):$(port)/")
@test r.status == 200
@test String(r.body) == "Hello World!"

r = HTTP.get("http://$(ip):$(port)/hola/usuario")
@test r.status == 200
@test String(r.body) == "<b>Hello usuario!</b>"

r = HTTP.get("http://$(ip):$(port)/get/testdata")
@test r.status == 200
@test String(r.body) == "get this back: testdata"

r = HTTP.get("http://$(ip):$(port)/data?hola=1")
@test r.status == 200
@test String(r.body) == "hellodata"

myjson = Dict("query"=>"data")
my_headers = HTTP.mkheaders(["Accept" => "application/json","Content-Type" => "application/json"])
r = HTTP.post("http://$(ip):$(port)/data",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.get("http://$(ip):$(port)/data")
@test r.status == 200
@test String(r.body) == "byedata"



r = HTTP.post("http://$(ip):$(port)/post",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.post("http://$(ip):$(port)/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.put("http://$(ip):$(port)/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.delete("http://$(ip):$(port)/")
@test r.status == 200
@test String(r.body) == "I did something!"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type"=>"text/plain", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Methods"=>"POST,GET,OPTIONS", "Transfer-Encoding"=>"chunked"]

try
r = HTTP.get("http://$(ip):$(port)/nada")
catch e
  @test e.status == 404
  @test String(e.response.body) == "NotFound"
end

r = HTTP.get("http://$(ip):$(port)/prueba.txt")
@test r.status == 200
@test String(r.body) == "probando webserver"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type"=>"text/plain", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Methods"=>"POST,GET,OPTIONS", "Transfer-Encoding"=>"chunked"]

r = HTTP.get("http://$(ip):$(port)/index.html")
@test r.status == 200
if Sys.iswindows()
  @test String(r.body) == "<!DOCTYPE html>\r\n<html lang=\"en\">\r\n<head>\r\n\t<meta charset=\"UTF-8\">\r\n\t<title>Document</title>\r\n</head>\r\n<body>\r\n<h1>hola</h1>\r\n</body>\r\n</html>"
else
  @test String(r.body) == "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n\t<meta charset=\"UTF-8\">\n\t<title>Document</title>\n</head>\n<body>\n<h1>hola</h1>\n</body>\n</html>"
end

@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type"=>"text/html", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Methods"=>"POST,GET,OPTIONS", "Transfer-Encoding"=>"chunked"]


r= HTTP.get("http://$(ip):$(port)/regex/test1")
@test String(r.body) == "datos test1"
#@btime HTTP.get("http://$(ip):$(port)/?hola=5") # 3.864 ms (8304 allocations: 381.20 KiB)
#@btime HTTP.get("http://$(ip):$(port)/hola/usuario") # 4.211 ms (7685 allocations: 353.44 KiB)
#@btime r= HTTP.get("http://$(ip):$(port)/get/testdata") # 3.906 ms (7693 allocations: 353.78 KiB)