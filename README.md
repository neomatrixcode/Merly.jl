# Merly.jl

*Micro framework for web programming in Julia.*

[![Build Status](https://travis-ci.org/codeneomatrix/Merly.jl.svg?branch=master)](https://travis-ci.org/codeneomatrix/Merly.jl)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/codeneomatrix/Merly.jl/master/LICENSE.md)
[![Merly](http://pkg.julialang.org/badges/Merly_0.4.svg)](http://pkg.julialang.org/?pkg=Merly)
[![Merly](http://pkg.julialang.org/badges/Merly_0.5.svg)](http://pkg.julialang.org/?pkg=Merly)

Merly is a micro framework for declaring routes and handling requests.
Quickly creating web applications in Julia with minimal effort.
##The contributions are welcome!

Installing
----------
```julia
Pkg.add("Merly")                                           #Release
Pkg.clone("git://github.com/codeneomatrix/Merly.jl.git")   #Development
```

## Example

```julia
using Merly

global u
u="hello"

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

```

Features available in the current release
------------------
###Parameters dictionary
```julia
@route GET "/get/:data" begin
  "get this back: "*q.params["data"]
end
```
###url query dictionary
```julia
@route POST|PUT|DELETE "/" begin
  r.headers["Content-Type"]="text/plain"

  "I did something! "*q.query["value1name"]
end
```
###Dictionary of body
Payload
```ruby
{"data1":"Hello"}  
```
```julia
@route POST|PUT|DELETE "/" begin
  r.headers["Content-Type"]="text/plain"

  "Payload data "*q.body["data1"]
end
```

Payload
```html
<Data>
  <Data1>Hello World!</Data1>
</Data>
```
```julia
@route POST|PUT|DELETE "/" begin
  r.headers["Content-Type"]="text/plain"

  "Payload data "*q.body["Data"]["Data1"]
end
```

### Reply JSON

```julia
@route POST|PUT|DELETE "/" begin
  r.headers["Content-Type"]="application/json"
  r.status = 200 #optional
  "{\"data1\":2,\"data2\":\"t\"}"
end

```
or
```julia
@route POST|PUT|DELETE "/" begin
  r.headers["Content-Type"]="application/json"
  info=Dict()
  info["data1"]=2
  info["data2"]="t"
  r.status = 200 #optional
  JSON.json(info)
end

```

### Reply XML

```julia
@route POST|PUT|DELETE "/" begin
  r.headers["Content-Type"]="application/xml"

  "<ListAllMyBucketsResult>
    <Buckets>
      <Bucket><Name>quotes</Name><CreationDate>2006-02-03T16:45:09.000Z</CreationDate></Bucket>
      <Bucket><Name>samples</Name><CreationDate>2006-02-03T16:41:58.000Z</CreationDate></Bucket>
    </Buckets>
  </ListAllMyBucketsResult>"
end

```

### Reply File

```julia
server = Merly.app("Path","load") #example: ("D:\\EXAMPLE\\src","*")  defauld: (pwd(),"")
@page "/" File("Index.html", r)

```
```clojure
Possible values of load
 "*"              Load all the files located in the path, except what started with "."
 "jl","clj|jl|py"  Extension in files that will not be exposed
 ""               Any file, Default
```

### Not found message
```julia
server.notfound("<!DOCTYPE html>
<html>
<head><title>Not found</title></head>
<body><h1>404, Not found</h1></body>
</html>")
```
```julia
server.notfound("notfound.html")
```
###CORS
```julia
server.use("CORS")
```

### Bonus
If you forgot the MIME type of a file you can use the next instruction
```julia
r.headers["Content-Type"]=mimetypes["file extension"]
```
