# Merly.jl
<p align="center"><img src="merly.png" width="25%" ></p>
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

#### Version 0.2.0
- [x] Julia version 1.0 syntax update
- [x] Update and refactor

#### Version 0.2.2
- [ ] Implementation of a websocket module

#### Version 0.2.3
- [ ] Performance improvement


Installing
----------
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


server.start(Dict("host" => "127.0.0.1","port" => 8000))

```

Features available in the current release
------------------
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


### Benchmark
For the test a simple application was created in heroku (https://github.com/codeneomatrix/merly-app) using merly.
The software used for the test was wrk (https://github.com/wg/wrk) and the computer used for the test:
```
Architecture: x86_64
mode(s) of operation of the CPUs: 32-bit, 64-bit
Byte order: Little Endian
CPU (s): 8
List of online CPU (s): 0-7
Processing thread (s) per core: 2
Nucleus (s) by «socket»: 4
«Socket (s)» 1
NUMA mode (s): 1
Manufacturer ID: GenuineIntel
CPU family: 6
Model: 60
Model name: Intel (R) Core (TM) i7-4810MQ CPU @ 2.80GHz
Review: 3
CPU MHz: 798,150
Max. CPU MHz: 3800,0000
CPU MHz min .: 800,0000
BogoMIPS: 5589.64
Virtualization: VT-x
Cache L1d: 32K
Cache L1i: 32K
Cache L2: 256K
Cache L3: 6144K
CPU (s) of the NUMA node 0: 0-7

cat /proc/meminfo
MemTotal:        7761928 kB
MemFree:         2812536 kB
MemAvailable:    4753564 kB
```
The results are the following: (The name of the application was random text)
```
~ $ wrk -t12 -c400 -d30s https://bfghsdg.herokuapp.com/
Running 30s test @ https://bfghsdg.herokuapp.com/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   704.25ms  538.73ms   2.00s    78.01%
    Req/Sec     9.94      8.79    70.00     79.03%
  2428 requests in 30.08s, 1.59MB read
  Socket errors: connect 0, read 2385, write 0, timeout 536
  Non-2xx or 3xx responses: 2293
Requests/sec:     80.72
Transfer/sec:     54.28KB
~ $ wrk -t12 -c800 -d30s https://bfghsdg.herokuapp.com/
Running 30s test @ https://bfghsdg.herokuapp.com/
  12 threads and 800 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.15s   556.37ms   2.00s    54.34%
    Req/Sec     6.94      6.03    50.00     84.73%
  1280 requests in 30.08s, 833.06KB read
  Socket errors: connect 0, read 1202, write 0, timeout 1107
  Non-2xx or 3xx responses: 1146
Requests/sec:     42.55
Transfer/sec:     27.69KB
~ $ wrk -t12 -c200 -d30s https://bfghsdg.herokuapp.com/
Running 30s test @ https://bfghsdg.herokuapp.com/
  12 threads and 200 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.21s   542.82ms   2.00s    54.55%
    Req/Sec     5.62      4.62    30.00     85.10%
  735 requests in 30.09s, 441.25KB read
  Socket errors: connect 0, read 674, write 0, timeout 658
  Non-2xx or 3xx responses: 584
Requests/sec:     24.42
Transfer/sec:     14.66KB
~ $ wrk -t12 -c400 -d30s https://bfghsdg.herokuapp.com/
Running 30s test @ https://bfghsdg.herokuapp.com/
  12 threads and 400 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.11s   495.85ms   1.93s    70.00%
    Req/Sec     4.00      4.42    20.00     77.60%
  414 requests in 30.10s, 217.11KB read
  Socket errors: connect 0, read 291, write 0, timeout 394
  Non-2xx or 3xx responses: 263
Requests/sec:     13.75
Transfer/sec:      7.21KB
```
which is because the application blocked traffic to the application when exceeding a certain threshold
```
2018-08-25T04:22:11.140279+00:00 app[web.1]: ┌ Warning: discarding connection from 172.16.126.38 due to rate limiting
2018-08-25T04:22:11.140291+00:00 app[web.1]: └ @ HTTP.Servers ~/.julia/packages/HTTP/nUK4f/src/Servers.jl:132
2018-08-25T04:22:11.168493+00:00 app[web.1]: [ Info: Accept-Reject:  Sockets.TCPSocket(RawFD(0x00000011) open, 0 bytes waiting)
2018-08-25T04:22:11.196006+00:00 app[web.1]: ┌ Info: HTTP.Messages.Request:
2018-08-25T04:22:11.196010+00:00 app[web.1]: │ """
2018-08-25T04:22:11.196012+00:00 app[web.1]: │ GET / HTTP/1.1
2018-08-25T04:22:11.196013+00:00 app[web.1]: │ Host: bfghsdg.herokuapp.com
2018-08-25T04:22:11.196015+00:00 app[web.1]: │ Connection: close
2018-08-25T04:22:11.196017+00:00 app[web.1]: │ X-Request-Id: 546c7c39-039a-4487-b120-c46017e501b2
2018-08-25T04:22:11.196018+00:00 app[web.1]: │ X-Forwarded-For: 189.215.153.244
2018-08-25T04:22:11.196020+00:00 app[web.1]: │ X-Forwarded-Proto: https
2018-08-25T04:22:11.196022+00:00 app[web.1]: │ X-Forwarded-Port: 443
2018-08-25T04:22:11.196023+00:00 app[web.1]: │ Via: 1.1 vegur
2018-08-25T04:22:11.196025+00:00 app[web.1]: │ Connect-Time: 1
2018-08-25T04:22:11.196027+00:00 app[web.1]: │ X-Request-Start: 1535170902285
2018-08-25T04:22:11.196029+00:00 app[web.1]: │ Total-Route-Time: 0
2018-08-25T04:22:11.196030+00:00 app[web.1]: │ 
2018-08-25T04:22:11.196032+00:00 app[web.1]: └ """
2018-08-25T04:22:11.214470+00:00 app[web.1]: ┌ Warning: discarding connection from 172.16.126.38 due to rate limiting
2018-08-25T04:22:11.214473+00:00 app[web.1]: └ @ HTTP.Servers ~/.julia/packages/HTTP/nUK4f/src/Servers.jl:132
2018-08-25T04:22:11.236232+00:00 app[web.1]: ┌ Warning: Base.IOError("write: broken pipe (EPIPE)", -32)
2018-08-25T04:22:11.236236+00:00 app[web.1]: └ @ HTTP.Servers ~/.julia/packages/HTTP/nUK4f/src/Servers.jl:479
2018-08-25T04:22:11.260500+00:00 app[web.1]: [ Info: Accept-Reject:  Sockets.TCPSocket(RawFD(0x00000012) open, 0 bytes waiting)
2018-08-25T04:22:11.281784+00:00 app[web.1]: ┌ Warning: discarding connection from 172.16.126.38 due to rate limiting
2018-08-25T04:22:11.281788+00:00 app[web.1]: └ @ HTTP.Servers ~/.julia/packages/HTTP/nUK4f/src/Servers.jl:132
2018-08-25T04:22:11.306090+00:00 app[web.1]: [ Info: Closed:  💀    1↑     1↓🔒   0s 0.0.0.0:28758:28758 ≣16
2018-08-25T04:22:11.330233+00:00 app[web.1]: [ Info: Accept-Reject:  Sockets.TCPSocket(RawFD(0x00000011) open, 0 bytes waiting)
2018-08-25T04:22:11.354170+00:00 app[web.1]: [ Info: Closed:  💀    1↑     1↓🔒   0s 0.0.0.0:28758:28758 ≣16
2018-08-25T04:22:11.197444+00:00 heroku[router]: at=error code=H13 desc="Connection closed without response" method=GET path="/" host=bfghsdg.herokuapp.com request_id=b07a280a-64dd-4363-bd26-69e80ada801f fwd="189.215.153.244" dyno=web.1 connect=0ms service=28860ms status=503 bytes=0 protocol=https
2018-08-25T04:22:11.331371+00:00 heroku[router]: sock=client at=warning code=H27 desc="Client Request Interrupted" method=GET path="/" host=bfghsdg.herokuapp.com request_id=546c7c39-039a-4487-b120-c46017e501b2 fwd="189.215.153.244" dyno=web.1 connect=1ms service=29043ms status=499 bytes= protocol=https
2018-08-25T04:22:11.427289+00:00 heroku[router]: at=error code=H13 desc="Connection closed without response" method=GET path="/" host=bfghsdg.herokuapp.com request_id=33c2612e-2ca6-46c0-9d78-94967e5b3083 fwd="189.215.153.244" dyno=web.1 connect=1ms service=16202ms status=503 bytes=0 protocol=https
```
