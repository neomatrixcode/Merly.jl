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

@page "/" "Hello World!"
@page "/hola/:usr" "<b>Hello {{usr}}!</b>"
@route POST|PUT|DELETE "/" begin
res.data="I did something!"
end

server.start("localhost", 8080)

```
