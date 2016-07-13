using Merly

global u
u="hello"

server = Merly.app()
server.use("CORS")

@page "/" "Hello World!"
@page "/hola/:usr" "<b>Hello {{usr}}!</b>"

@route GET "/get/:data" begin
  "get this back: {{data}}"
end

@route POST "/post" begin
  "I did something!"
end

@route POST|PUT|DELETE "/" begin
  println("params: ",q.params)
  println("query: ",q.query)
  println("body: ",q.body)

  r.headers["Content-Type"]="text/plain"

  "I did something!"
end

Get("/data", (q,r)->(begin
  r.headers["Content-Type"]="text/plain"
  "$u data"
end))


Post("/data", (q,r)->(begin
  println("params: ",q.params)
  println("query: ",q.query)
  println("body: ",q.body)
  r.headers["Content-Type"]="text/plain"
  global u="bye"
  "I did something!"
end))


server.start("localhost", 8080)