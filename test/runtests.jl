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

u = 1

function tojson(data::String)
   return JSON.parse(data)
end

formats["application/json"] = tojson

@page "/" HTTP.Response(200,"Hello World!")

@page "/hola/:usr" HTTP.Response(200,string("<b>Hello ",request.params["usr"],"!</b>"))

@page "/mifile" HTTP.Response(200, File("index.html"))

@page "/get1" (;u=u) HTTP.Response(200,string("<b>Get1 ",u," !</b>"))

@route GET "/get/:data1" (;u=u) begin
  u = u +1
  HTTP.Response(200, string(u ,request.params["data1"]))
end

@route GET "/get/data/hola" begin
  HTTP.Response(200,"get this back: data")
end

@route GET "/regex/(\\w+\\d+)" begin
  return HTTP.Response(200, string("datos ",request.params["2"]))# $(request.params[1])"
end

@route POST "/post" begin
  HTTP.Response(200,"I did something!")
end

@route POST|PUT|DELETE "/" begin
  println("query: ",request.query)
  println("body: ",request.body)

  HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => "text/plain"])
          , body="I did something2!")
end


Get("/data", (request,HTTP)->begin

  println("params: ",request.params)
  println("query: ",request.query)

  HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => "text/plain"])
          , body=string(u,"data ", get(request.query,"hola","")))

end)

Post("/data", (request,HTTP)-> begin
  println("params: ",request.params)
  println("query: ",request.query)
  println("body: ",request.body)

  global u="bye"

  HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => "text/plain"])
          , body=string("I did something! ", request.body["query"]))

end)

 Put("/data", (request,HTTP) -> begin
     HTTP.response(200, "test text put")
 end)
 Delete("/data", (request,HTTP) -> begin
     HTTP.response(200, "test text delete")
 end)
 Connect("/data", (request,HTTP) -> begin
     HTTP.response(200, "test text Connect")
 end)
 Trace("/data", (request,HTTP) -> begin
     HTTP.response(200, "test text Trace")
 end)
 Head("/data", (request,HTTP) -> begin
     HTTP.response(200, "test text head")
 end)
 Patch("/data", (request,HTTP) -> begin
     HTTP.response(200, "test text Patch")
 end)

Get("/test1/:usr",
  (request, HTTP) -> begin
        HTTP.Response(200,string("<b>test1 ",request.params["usr"],"!</b>"))
    end
)


Get("/test2/:usr",
    (result(;u=u) = (request, HTTP)-> begin
          u= u+1
          HTTP.Response(200,string("<b>test2 ",u,request.params["usr"]," !</b>"))
        end)()
)


@route GET "/test3/" (;u=u) begin
  u= u+1
  HTTP.Response(200,string("get this back:", u))
end


function authenticate(request, HTTP)

  return request, HTTP, 300
end


Get("/verify",

  (result(;middleware=authenticate) = (request, HTTP)-> begin

      myfunction = (request, HTTP, data)-> begin
                return  HTTP.Response(200,string("<b>verify ", data ," !</b>"))
      end

      return myfunction(middleware(request,HTTP)...)

  end)()

)

 @async start(host = ip, port = port)
 sleep(2)

myjson = Dict("query"=>"data")

my_headers = HTTP.mkheaders(["Content-Type" => "application/json"])

  global r = HTTP.get("http://$(ip):$(port)/")
 @test r.status == 200
 @test String(r.body) == "Hello World!"

 global r = HTTP.get("http://$(ip):$(port)/hola/usuario")
@test r.status == 200
@test String(r.body) == "<b>Hello usuario!</b>"

 global r = HTTP.get("http://$(ip):$(port)/get/testdata")
@test r.status == 200
@test String(r.body) == "2testdata"

 global r = HTTP.get("http://$(ip):$(port)/get/data")
@test r.status == 200
@test String(r.body) == "3data"

 global r = HTTP.get("http://$(ip):$(port)/get/data/hola")
@test r.status == 200
@test String(r.body) == "get this back: data"

r= HTTP.get("http://$(ip):$(port)/regex/test1")
@test String(r.body) == "datos test1"


 global r = HTTP.get("http://$(ip):$(port)/data?hola=1")
@test r.status == 200
@test String(r.body) == "1data 1"

myjson = Dict("query"=>"data")
my_headers = HTTP.mkheaders(["Accept" => "application/json","Content-Type" => "application/json"])
 global r = HTTP.post("http://$(ip):$(port)/data",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something! data"

 global r = HTTP.get("http://$(ip):$(port)/data")
@test r.status == 200
@test String(r.body) == "byedata "


 global r = HTTP.get("http://$(ip):$(port)/test1/neomatrix")
@test r.status == 200
@test String(r.body) == "<b>test1 neomatrix!</b>"

 global r = HTTP.get("http://$(ip):$(port)/test2/neomatrixcode")
@test r.status == 200
@test String(r.body) == "<b>test2 2neomatrixcode !</b>"


 global r = HTTP.get("http://$(ip):$(port)/get1")
@test r.status == 200
@test String(r.body) == "<b>Get1 1 !</b>"

 global r = HTTP.get("http://$(ip):$(port)/test3")
@test r.status == 200
@test String(r.body) == "get this back:2"

my_headers = HTTP.mkheaders(["Accept" => "application/json"])
 global r = HTTP.post("http://$(ip):$(port)/post",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something!"

my_headers = HTTP.mkheaders(["Accept" => "application/json","Content-Type" => "application/json"])
 global r = HTTP.post("http://$(ip):$(port)/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something2!"

 global r = HTTP.put("http://$(ip):$(port)/",my_headers,JSON.json(myjson))
@test r.status == 200
@test String(r.body) == "I did something2!"

 global r = HTTP.delete("http://$(ip):$(port)/")
@test r.status == 200
@test String(r.body) == "I did something2!"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type" => "text/plain", "Access-Control-Allow-Origin" => "*", "X-PINGOTHER" => "pingpong", "Transfer-Encoding" => "chunked"]

try
   global r = HTTP.get("http://$(ip):$(port)/nada")
catch e
  @test String(e.response.body) == File("notfound.html")
end

 global r = HTTP.get("http://$(ip):$(port)/prueba.txt")
@test r.status == 200
@test String(r.body) == "probando webserver"
@test r.headers == Pair{SubString{String},SubString{String}}["Content-Type" => "text/plain", "Access-Control-Allow-Origin" => "*", "X-PINGOTHER" => "pingpong", "Transfer-Encoding" => "chunked"]

global r= HTTP.get("http://$(ip):$(port)/testfolder/testfile.txt")
@test String(r.body) == "test text"

global r= HTTP.get("http://$(ip):$(port)/mifile")
@test r.status == 200

if Sys.iswindows()
    @test String(r.body) ==  "<!DOCTYPE html>\r\n<html lang=\"en\">\r\n<head>\r\n\t<meta charset=\"UTF-8\">\r\n\t<title>Document</title>\r\n</head>\r\n<body>\r\n<h1>hola</h1>\r\n</body>\r\n</html>"
else
   @test String(r.body) ==  "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n\t<meta charset=\"UTF-8\">\n\t<title>Document</title>\n</head>\n<body>\n<h1>hola</h1>\n</body>\n</html>"
end


global r= HTTP.get("http://$(ip):$(port)/verify")
@test r.status == 200
@test String(r.body) == "<b>verify 300 !</b>"
