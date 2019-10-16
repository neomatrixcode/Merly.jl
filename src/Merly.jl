module Merly
import Base.|

using Sockets
using JSON
using HTTP
#XMLDict

include("base.jl")
include("mimetypes.jl")
include("routes.jl")
include("allformats.jl")

export app, @page, @route, GET,POST,PUT,DELETE,HEAD,OPTIONS,PATCH,Get,Post,Put,Delete

end # module