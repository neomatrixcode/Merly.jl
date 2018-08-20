using Merly
using Test
using HTTP
using JSON
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

t = @async server.start(Dict("host" => "127.0.0.1","port" => 8000))


r = HTTP.get("http://127.0.0.1:8000/")
@test r.status == 200
@test String(r.body) == "Hello World!"

r = HTTP.get("http://127.0.0.1:8000/hola/usuario")
@test r.status == 200
@test String(r.body) == "<b>Hello usuario!</b>"

r = HTTP.get("http://127.0.0.1:8000/get/testdata")
@test r.status == 200
@test String(r.body) == "get this back: testdata"

r = HTTP.get("http://127.0.0.1:8000/data")
@test r.status == 200
@test String(r.body) == "hellodata"

myjson = Dict("query"=>"data")
my_headers = HTTP.mkheaders(["Accept" => "application/json","Content-Type" => "application/json"])
r = HTTP.post("http://127.0.0.1:8000/data",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.get("http://127.0.0.1:8000/data")
@test r.status == 200
@test String(r.body) == "byedata"



r = HTTP.post("http://127.0.0.1:8000/post",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.post("http://127.0.0.1:8000/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.put("http://127.0.0.1:8000/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

r = HTTP.delete("http://127.0.0.1:8000/")
@test r.status == 200
@test String(r.body) == "I did something!"