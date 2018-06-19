
function files(arch::Array{Any,1})
  roop=""
  for i=1:length(arch)
    roop=replace(replace(arch[i],root,""),"\\","/")
    extencion="text/plain"
    try
      extencion=mimetypes[split(roop,".")[end]]
    catch
    end
    data = File(roop[2:end])
    #try
      createurl("GET"*roop,(q,req,res)->(begin
        res.headers["Content-Type"]= extencion
        res.data= data
      end))
    #end
  end
end

function WebServer(rootte::String)
  cd(rootte)
  ls= readdir()
  arrfile=[]
  arrdir=[]
  for i=1:length(ls)
    if isfile(ls[i])
        if (ismatch(Regex("((.)*\\.(?!($exten)))"),ls[i])) && !ismatch(r"^(\.)",ls[i])
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