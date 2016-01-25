# Merly.jl

[![Build Status](https://travis-ci.org/codeneomatrix/Merly.jl.svg?branch=master)](https://travis-ci.org/codeneomatrix/Merly.jl)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/codeneomatrix/Merly.jl/master/LICENSE.md)

Merly is a micro framework for declaring routes and handling requests.
Quickly creating web applications in Julia with minimal effort.

Installing
----------
```julia
Pkg.add("Merly")                                           #Release
Pkg.clone("git://github.com/codeneomatrix/Merly.jl.git")   #Development
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

  "I did something!"
end

server.start("localhost", 8080)

```

###Parameters dictionary
```julia
@route GET "/get/:data" begin
  "get this back: "*params["data"]
end
```
###url query dictionary
```julia
@route POST|PUT|DELETE "/" begin
  h["Content-Type"]="text/plain"

  "I did something! "*query["value1name"]
end
```
###Dictionary of body
Payload
```ruby
{"data1":"Hello"}  
```
```julia
@route POST|PUT|DELETE "/" begin
  h["Content-Type"]="text/plain"

  "Payload data "*body["data1"]
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
  h["Content-Type"]="text/plain"

  "Payload data "*body["Data"]["Data1"]
end
```

### Reply JSON

```julia
@route POST|PUT|DELETE "/" begin
  h["Content-Type"]="application/json"
  res.status = 200 #optional
  "{\"data1\":2,\"data2\":\"t\"}"
end

```
or
```julia
@route POST|PUT|DELETE "/" begin
  h["Content-Type"]="application/json"
  info=Dict()
  info["data1"]=2
  info["data2"]="t"
  res.status = 200 #optional
  JSON.json(info)
end

```

### Reply XML

```julia
@route POST|PUT|DELETE "/" begin
  h["Content-Type"]="application/xml"

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
@page "/" File("Index.html", res)

```
```clojure
Possible values of load
 "*"              Load all the files located in the path, except what started with "."
 "jl","clj|jl|py"  Extension in files that will not be exposed
 ""               Any file, Default
```

### Bonus
If you forgot the MIME type of a file you can use the next instruction
```julia
h["Content-Type"]=mimetypes["file extension"]
```

##The contributions are welcome!
