# Merly.jl

<p align="center">
<strong>Micro framework for web programming in Julia..</strong>
<br><br>
<a href="https://travis-ci.org/codeneomatrix/Merly.jl"><img src="https://travis-ci.org/codeneomatrix/Merly.jl.svg?branch=master"></a>
<a href="https://codecov.io/gh/codeneomatrix/Merly.jl">
  <img src="https://codecov.io/gh/codeneomatrix/Merly.jl/branch/master/graph/badge.svg" />
</a>
&nbsp;&nbsp
<a href="https://pkg.julialang.org/detail/Merly"><img src="https://pkg.julialang.org/badges/Merly_0.4.svg"></a>
 &nbsp;&nbsp;
<a href="https://raw.githubusercontent.com/codeneomatrix/Merly.jl/master/LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a>

## About
Merly is a micro framework for declaring routes and handling requests.
Quickly creating web applications in Julia with minimal effort.

Roadmap
-----
#### Version 0.0.3
- [x] adding the debug option
- [x] optimizing routes
- [x] refactor notfount, cors, body

Below are some of the features that are planned to be added in future versions of Merly.jl once version 0.7 of the language is released.

### All contributions and suggestions are welcome !!!!

#### Version 0.1.0
- [x] Julia version 0.7 syntax update

#### Version 0.1.1
- [x] Julia version 1.0 syntax update
- [x] Update and refactor

#### Version 0.1.2
- [ ] Implementation of a websocket module

#### Version 0.1.3
- [ ] Performance improvement


Installing
----------
```julia
```julia
Pkg> add Diana                                             #Release
pkg> add Diana#master                                      #Development
```

## Example

```julia
using Merly

u="hello"

server = Merly.app()

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


server.start(Dict("host" => "127.0.0.1","port" => 8000))

```

Features available in the current release
------------------
### Parameters dictionary
```julia
@route GET "/get/:data>" begin
  # matches "GET /get/foo" and "GET /get/bar"
  # q.params["data"] is 'foo' or 'bar'
  "get this back: "*q.params["data"]
end
```
### url query dictionary

```julia
@route POST|PUT|DELETE "/" begin
  res.headers["Content-Type"]= "text/plain"
  # matches "POST /?title=foo&author=bar"
  title = q.query["title"]
  author = q.query["author"]
  "I did something!"
end
```
### Dictionary of body
Payload
```ruby
{"data1":"Hello"}
```
```julia
@route POST|PUT|DELETE "/" begin
  res.headers["Content-Type"]= "text/plain"
  res.body = "Payload data "*q.body["data1"]
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
  res.headers["Content-Type"]= "text/plain"
  "Payload data "*q.body["Data"]["Data1"]
end
```

### Reply JSON

```julia
@route POST|PUT|DELETE "/" begin
  res.headers["Content-Type"]="application/json"
  res.status = 200 #optional
  "{\"data1\":2,\"data2\":\"t\"}"
end

```
or
```julia
@route POST|PUT|DELETE "/" begin
  res.headers["Content-Type"]="application/json"
  info=Dict()
  info["data1"]=2
  info["data2"]="t"
  res.status = 200 #optional
  res.body = JSON.json(info)
end

```

### Reply XML

```julia
@route POST|PUT|DELETE "/" begin
  res.headers["Content-Type"]="application/xml"

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
@page "/" File("Index.html")
```

### Web server

```julia
# By default, the location where to look for the files that will
# be exposed will be the same where the script is, if the files are
# not found in that site, the location of the files can be established
# with the following instruction.
server.webserverpath("C:\\path")  # example in windows

```
```clojure
Possible values of webserverfiles

server.webserverfiles("*") #
 "*"               Load all the files located in the path, except what started with "."
 "jl","clj|jl|py"  Extension in files that will not be exposed
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
### CORS
```julia
server.useCORS(true)
```

### Bonus
If you forgot the MIME type of a file you can use the next instruction
```julia
res.headers["Content-Type"]= mimetypes["file extension"]
```
the file mimetypes.jl was taken from https://github.com/JuliaWeb/HttpServer.jl  guys are great