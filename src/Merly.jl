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
CONNECT	= "CONNECT"
TRACE = "TRACE"


tonumber = Dict{String,Char}(
 "CONNECT" => '1'
,"TRACE"   => '2'
,"HEAD"    => '3'
,"DELETE"  => '4'
,"PUT"     => '5'
,"OPTIONS" => '6'
,"POST"    => '7'
,"GET"     => '8'
,"PATCH"   => '9'
)

# Dict("g" => (g(x::Int) = x + 5)) #mas rapido
# Dict("g" => function g(x::Int); x + 5; end)

myendpoints = Dict{Int64,Array{NamedTuple{(:route, :toexec, :urlparams),Tuple{Union{String,Regex},Function,Union{Nothing,Dict{Int64,String}}}},1}}(

0 => [(route= "", toexec= function nf(req,res); res.status = 404; end , urlparams= nothing)]

)
include("tools.jl")
include("files.jl")
include("core.jl")
include("mimetypes.jl")
include("routes.jl")
include("allformats.jl")

addnotfound("NotFound",myendpoints)

export webserverfiles, webserverpath, notfound, headersalways, useCORS, File, @page, @route, GET,POST,PUT,DELETE,HEAD,OPTIONS,PATCH,Get,Post,Put,Delete, start

end # module