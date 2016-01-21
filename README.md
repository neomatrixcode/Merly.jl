# Merly.jl

[![Build Status](https://travis-ci.org/codeneomatrix/Merly.jl.svg?branch=master)](https://travis-ci.org/codeneomatrix/Merly.jl)


Merly is a micro framework for declaring routes and handling requests.

### Construction package.  This implementation is changing daily...


Installing
----------
```julia
Pkg.clone("git://github.com/codeneomatrix/Merly.jl.git")
```

## Example

```julia
using Merly

server = Merly.app()

@page "/" "Hello World!"
@page "/hola/:usr" "<b>Hello {{usr}}!</b>"

@route GET "/get/:data" begin
  "get this back: {{data}}"
end

@route POST "/post" begin
  "I did something!"
end

@route POST|PUT|DELETE "/" begin
  println("params: ",params)
  println("query: ",query)
  println("body: ",body)
  h["Content-Type"]="text/plain"
  res.status = 200
  "I did something!"
end

server.start("localhost", 8080)

```
