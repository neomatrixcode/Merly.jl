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
As will be
```julia
using Merly

server = Merly.app()

@route "/" "Hello World!"

@route GET "/hello/:name" (req, res)->
"<b>Hello {{name}}</b>!"

@route POST | PUT  "/" (req, res)->
'I did something!'

server.start("localhost", 8080)

```
