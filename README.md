# Merly.jl

[![Build Status](https://travis-ci.org/codeneomatrix/Merly.jl.svg?branch=master)](https://travis-ci.org/codeneomatrix/Merly.jl)


Morsel is a micro framework for declaring routes and handling requests.

### Construction package.  This implementation is changing daily...


Installing
----------
```julia
Pkg.clone("git://github.com/codeneomatrix/Faker.jl.git")
```

## Example

```julia
using Merly

server = merly.app();

@route "/", "Hello World!"

@route GET, "/hello/:name", (req, res)->
"<b>Hello {{name}}</b>!"

@route POST | PUT, "/" , (req, res)->
'I did something!'

server.start(host='localhost', port=8080)

```
