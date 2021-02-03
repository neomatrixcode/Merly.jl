using Merly
using Test
using HTTP
using JSON

ip = "127.0.0.1"
port = 8086


@test File("index.html") == read( open(joinpath(pwd(),"index.html")), String)

useCORS()

headersalways(["X-PINGOTHER" => "pingpong"])

notfound("""<!DOCTYPE html>
              <html>
              <head><title>Not found</title></head>
              <body><h1>404, Not found</h1></body>
              </html>""")
notfound("website/notfound.html")

@test webserverpath("website") == joinpath(pwd(),"website")
webserverfiles("*")

u = "hello"

@page "/" HTTP.Response(200,"Hello World!")

@page "/hola/:usr>" HTTP.Response(200,"<b>Hello usr!</b>")

@page "/mifile" HTTP.Response(200, File("index.html"))

@route GET "/get/:data1>" begin
  HTTP.Response(200,"get this back: data1")
end

@route GET "/regex/(\\w+\\d+)" begin
  return HTTP.Response(200, string("datos ",req.params["2"]))# $(req.params[1])"
end

@route POST "/post" begin
  HTTP.Response(200,"I did something!")
end

@route POST|PUT|DELETE "/" begin
  println("query: ",req.query)
  println("body: ",req.body)

  HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => "text/plain"])
          , body="I did something!")
end

Get("/data", (req,HTTP)->begin

  println("params: ",req.params)
  println("query: ",req.query)

  HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => "text/plain"])
          , body=u*"data")

end)

Post("/data", (req,HTTP)-> begin
  println("params: ",req.params)
  println("query: ",req.query)
  println("body: ",req.body)

  global u="bye"

  HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => "text/plain"])
          , body="I did something!")

end)


 @async start(host = ip, port = port, verbose = true)
 sleep(2)

myjson = Dict("query"=>"data")

my_headers = HTTP.mkheaders(["Content-Type" => "application/json"])

global r = HTTP.post("http://$(ip):$(port)/post",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

global r = HTTP.get("http://$(ip):$(port)/")
 @test r.status == 200
 @test String(r.body) == "Hello World!"

r= HTTP.get("http://$(ip):$(port)/regex/test1")
@test String(r.body) == "datos test1"

global r = HTTP.get("http://$(ip):$(port)/data?hola=1")
@test r.status == 200
@test String(r.body) == "hellodata"

global r= HTTP.get("http://$(ip):$(port)/mifile")
@test r.status == 200
@test String(r.body) == "<!DOCTYPE html>\r\n<html lang=\"en\">\r\n<head>\r\n\t<meta charset=\"UTF-8\">\r\n\t<title>Document</title>\r\n</head>\r\n<body>\r\n<h1>hola</h1>\r\n</body>\r\n</html>"

global r= HTTP.get("http://$(ip):$(port)/testfolder/testfile.txt")
@test String(r.body) == "test text"