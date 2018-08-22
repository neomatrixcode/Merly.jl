
function files(arch::Array{Any,1})
  roop=""
  for i=1:length(arch)
    roop=replace(replace(arch[i],root => ""),"\\" => "/")
    extension="text/plain"
    ext= split(roop,".")
    if(length(ext)>1) extension=mimetypes[ext[2]] end
    data = File(roop[2:end])
    createurl("GET"*roop,(req,res)->(begin
      res.headers["Content-Type"]= extension
      res.status = 200
      res.body= data
    end))
  end
end

function WebServer(rootte::String)
  cd(rootte)
  ls= readdir()
  arrfile=[]
  arrdir=[]
  for i=1:length(ls)
    if isfile(ls[i])
        if (occursin(Regex("((.)*\\.(?!($exten)))"),ls[i])) && !occursin(r"^(\.)",ls[i])
          push!(arrfile,normpath(rootte,ls[i]))
        end
    end
    if isdir(ls[i])
      push!(arrdir,normpath(rootte,ls[i]))
    end
  end
  files(arrfile)
  for i=1:length(arrdir)
    WebServer(arrdir[i])
  end
end