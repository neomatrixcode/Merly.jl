
# Merly v0.2.1

## New features
- The file upload of the webserserver function is improved
- the verbose parameter is added in the start function
  server.start(config=Dict("host" => "$(ip)","port" => port),verbose=false)

## Bug fixes
- Fix the error when starting a server with the HTTP.jl update

# Merly v0.2.0

## New features
- Julia version 1.0 syntax update
- Elimination of try and global variables
- Add headeralways function
- Documentation update
- Refactor urls regex and add test regular expression

# Merly v0.1.0

## New features
- Compatibility with julia version 0.7
- Documentation update

# v0.0.3

## New features
- adding the debug option
- config start
- add methods http
- add routes_patterns
- optimizing routes
- refactor notfount, cors, body
- optimizing the search and execution of routes
- modularized data formats accepted

# Merly v0.0.2

## Bug fixes
- Bug fixed

## New features
- New features

# Merly v0.0.1
## New features
- Micro framework for web programming in Julia