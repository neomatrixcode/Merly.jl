# Merly.jl
<p align="center"><img src="merly.png" width="25%" ></p>
<p align="center">
<strong>Micro framework for web programming in Julia.</strong>
<br><br>
<a href="https://travis-ci.org/github/neomatrixcode/Merly.jl"><img src="https://travis-ci.org/neomatrixcode/Merly.jl.svg?branch=master"></a>
<a href="https://codecov.io/gh/neomatrixcode/Merly.jl">
  <img src="https://codecov.io/gh/neomatrixcode/Merly.jl/branch/master/graph/badge.svg" />
</a>
<a href="https://neomatrixcode.gitbook.io/merly/"><img src="https://img.shields.io/badge/docs-stable-blue.svg"></a>
<a href="https://juliahub.com/ui/Packages/Merly/a9bHk?t=2"><img src="https://juliahub.com/docs/Merly/deps.svg"></a>
<a href="https://juliahub.com/ui/Packages/Merly/a9bHk"><img src="https://juliahub.com/docs/Merly/version.svg"></a>
<a href="https://juliahub.com/ui/Packages/Merly/a9bHk"><img src="https://juliahub.com/docs/Merly/pkgeval.svg"></a>
<a href="https://raw.githubusercontent.com/neomatrixcode/Merly.jl/master/LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
</p>

## About
Merly is a micro framework for declaring routes and handling requests.
Quickly creating web applications in Julia with minimal effort.

### All contributions and suggestions are welcome !!!!

Installing
----------
```julia
(@v1.5) pkg> add Merly
```

## Example

```julia
using Merly
using JSON

u = 1

function tojson(data::String)
   return JSON.parse(data)
end

formats["application/json"] = tojson

@page "/" HTTP.Response(200,"Hello World!")
@page "/hola/:usr" (;u=u) HTTP.Response(200,string("<b>Hello ",request.params["usr"],u,"!</b>"))

@route GET "/get/:data1" (;u=u) begin
  u = u +1
  HTTP.Response(200, string(u ,request.params["data1"]))
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


start(host = "127.0.0.1", port = 8086, verbose = true)

```
