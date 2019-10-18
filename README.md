# Merly.jl
<p align="center"><img src="merly.png" width="25%" ></p>
<p align="center">
<strong>Micro framework for web programming in Julia.</strong>
<br><br>
<a href="https://travis-ci.org/codeneomatrix/Merly.jl"><img src="https://travis-ci.org/codeneomatrix/Merly.jl.svg?branch=master"></a>
<a href="https://codecov.io/gh/codeneomatrix/Merly.jl">
  <img src="https://codecov.io/gh/codeneomatrix/Merly.jl/branch/master/graph/badge.svg" />
</a>
<a href="https://codeneomatrix.github.io/Merly.jl/stable"><img src="https://img.shields.io/badge/docs-stable-blue.svg"></a>
<a href="https://codeneomatrix.github.io/Merly.jl/dev"><img src="https://img.shields.io/badge/docs-dev-blue.svg"></a>
<a href="https://www.repostatus.org/#active"><img src="https://www.repostatus.org/badges/latest/active.svg"></a>
<a href="https://raw.githubusercontent.com/codeneomatrix/Merly.jl/master/LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-blue.svg"></a>
</p>

## About
Merly is a micro framework for declaring routes and handling requests.
Quickly creating web applications in Julia with minimal effort.

Roadmap
-----
### All contributions and suggestions are welcome !!!!

#### Version 0.3
- [ ] Websocket module implementation

#### Version 0.3.1
- [ ] Performance improvement


Installing
----------
```julia
Pkg> add Merly
```

## Example

```julia
using Merly

u="hello"

server = Merly.app()

@page "/" "Hello World!"
@page "/hello/:usr>" "<b>Hello {{usr}}!</b>"

@route GET "/get/:data>" begin
  "get this back: {{data}}"
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


server.start(config=Dict("host" => "127.0.0.1","port" => 8000),verbose=false)

```
