using Merly
using Test
using HTTP
using JSON
#using Pkg
#Pkg.add("BenchmarkTools")
#using BenchmarkTools

ip = "127.0.0.1" #127.0.0.1
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

@route POST "/post" begin
  res.body = "I did something!"
end

@route POST|PUT|DELETE "/" begin
  println("params: ",q.params)
  println("query: ",q.query)
  println("body: ",q.body)

  res.headers["Content-Type"]= "text/plain"

  "I did something!"
end

Get("/data", (q,req,res)->(begin
  res.headers["Content-Type"]= "text/plain"
  println("params: ",q.params)
  println("query: ",q.query)
  u*"data"
end))

Post("/data", (q,req,res)->(begin
  println("params: ",q.params)
  println("query: ",q.query)
  println("body: ",q.body)
  res.headers["Content-Type"]= "text/plain"
  global u="bye"
  "I did something!"
end))

server.webserverfiles("jl")

@async server.start(Dict("host" => "$(ip)","port" => 8000))


r = HTTP.get("http://$(ip):8000/")
@test r.status == 200
@test String(r.body) == "Hello World!"

#=r = HTTP.get("http://$(ip):8000/hola/usuario")
@test r.status == 200
@test String(r.body) == "<b>Hello usuario!</b>"

r = HTTP.get("http://$(ip):8000/get/testdata")
@test r.status == 200
@test String(r.body) == "get this back: testdata"
=#
r = HTTP.get("http://$(ip):8000/data?hola=1")
@test r.status == 200
@test String(r.body) == "hellodata"

myjson = Dict("query"=>"data")
my_headers = HTTP.mkheaders(["Accept" => "application/json","Content-Type" => "application/json"])
r = HTTP.post("http://$(ip):8000/data",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.get("http://$(ip):8000/data")
@test r.status == 200
@test String(r.body) == "byedata"



r = HTTP.post("http://$(ip):8000/post",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.post("http://$(ip):8000/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.put("http://$(ip):8000/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.delete("http://$(ip):8000/")
@test r.status == 200
@test String(r.body) == "I did something!"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type"=>"text/plain", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Methods"=>"POST,GET,OPTIONS", "Transfer-Encoding"=>"chunked"]

try
r = HTTP.get("http://$(ip):8000/nada")
catch e
  @test e.status == 404
  @test String(e.response.body) == "NotFound"
end

r = HTTP.get("http://$(ip):8000/prueba.txt")
@test r.status == 200
@test String(r.body) == "probando webserver"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type"=>"text/plain", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Methods"=>"POST,GET,OPTIONS", "Transfer-Encoding"=>"chunked"]

r = HTTP.get("http://$(ip):8000/index.html")
@test r.status == 200
@test String(r.body) == "<!DOCTYPE html>\r\n<html lang=\"en\">\r\n<head>\r\n\t<meta charset=\"UTF-8\">\r\n\t<title>Document</title>\r\n</head>\r\n<body>\r\n<h1>hola</h1>\r\n</body>\r\n</html>"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type"=>"text/html", "Access-Control-Allow-Origin"=>"*", "Access-Control-Allow-Methods"=>"POST,GET,OPTIONS", "Transfer-Encoding"=>"chunked"]

#@btime HTTP.get("http://$(ip):8000/?hola=5")