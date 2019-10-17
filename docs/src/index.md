# Home

## Merly.jl
Merly is a micro framework for declaring routes and handling requests.
Quickly creating web applications in Julia with minimal effort.

## Installation

```julia
Pkg> add Merly
#Release
```

## An example in Diana

```julia
using Merly

u="hello"

server = Merly.app()

@page "/" "Hello World!"
@page "/hola/:usr1>" "<b>Hello {{usr1}}!</b>"

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

### Data stored on request (req)
```
  query   # data from the query url
  params  # data from the regular expresion
  body    # body of the request in dict or plane text
  version # the protocol version
  headers # the headers sent by the client
```
### Data stored on response (req)
```
  status
  headers
  body
```

### Parameters dictionary
```julia
@route GET "/get/:data>" begin
  # matches "GET /get/foo" and "GET /get/bar"
  # not accept special symbols (!,#,$,etc)
  # req.params["data"] is 'foo' or 'bar'
  "get this back: "*req.params["data"]
end

# it is possible to use regular expressions, enclosing them always between '(' ')'
@route GET "/regex/(\\w+\\d+)" begin
  # matches "GET /regex/test1" and "GET /regex/test125"
  # req.params[1] is 'test1' or 'test125'
   "datos $(req.params[1])"
end
```
### url query dictionary

```julia
@route POST|PUT|DELETE "/" begin
  res.headers["Content-Type"]= "text/plain"
  # matches "POST /?title=foo&author=bar"
  title = req.query["title"]
  author = req.query["author"]
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
  res.body = "Payload data "*req.body["data1"]
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
  "Payload data "*req.body["Data"]["Data1"]
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
### Headers always
You can add headers that will always be returned in each request
```julia
server.headersalways("Strict-Transport-Security","max-age=10886400; includeSubDomains; preload")
```

### Bonus
If you forgot the MIME type of a file you can use the next instruction
```julia
res.headers["Content-Type"]= mimetypes["file extension"]
```
the file mimetypes.jl was taken from https://github.com/JuliaWeb/HttpServer.jl  guys are great


## Index
```@index
```