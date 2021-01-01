module Merly
import Base.|

using Sockets
using JSON
using HTTP
#XMLDict


|(x::String, y::String)= string(x,"|",y)

GET="GET"
POST="POST"
PUT="PUT"
DELETE="DELETE"
HEAD = "HEAD"
OPTIONS = "OPTIONS"
PATCH = "PATCH"

# Dict("g" => (g(x::Int) = x + 5))
# Dict("g" => function g(x::Int); x + 5; end)

routes=Dict{String, Function}()
routes_patterns=Dict{Regex, Function}()

include("core.jl")
include("mimetypes.jl")
include("routes.jl")
include("allformats.jl")

export App, @page, @route, GET,POST,PUT,DELETE,HEAD,OPTIONS,PATCH,Get,Post,Put,Delete

end # module