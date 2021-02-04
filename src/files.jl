
	rootbase = pwd()

	function webserverpath(folder::AbstractString)
	  global rootbase = joinpath(pwd(),folder)
	end

	"""
	File(file::String)

	Return a file content located in "rootbase"
	"""
	function File(file::String)
	    return File("", file)
	end

	"""
	File(folder::String, file::String)

	Return a file content located in "joinpath(rootbase, folder)"
	"""
	function File(folder::String, file::String)
	  path = joinpath(rootbase, folder, file)
	  f = open(path)
	  return read(f, String)
	end

	"""
	files(roop::String, file::String)

	Create a GET route to file
	"""
	function files(folder::String, file::String)
	    extension="text/plain"
	    ext= split(file,".")
	    if(length(ext)>1)
	      my_extension = ext[end]
	      if (haskey(mimetypes, my_extension))
	        extension = mimetypes[my_extension]
	      end
	    end
	    data = File(folder, file)
	    routefile = replace(joinpath(folder,file),"\\" => "/")
	    Get( string("/",routefile) , (request,HTTP)->(begin
	      HTTP.Response(200
          , HTTP.mkheaders(["Content-Type" => extension])
          , body=data)
	    end) )
	end

	"""
	Create routes to files inside "rootbase"
	"""
	function WebServer(folder::String, exten::String)
	  path = joinpath(rootbase, folder)
	  ls= readdir(path)
	  for i = 1:length(ls)
	    if isfile( joinpath(path, ls[i]) )
	      ext = split(ls[i], ".")
	      if length(ext) > 1 && ext[1] != "" && occursin(exten, ext[end] )
	        files(folder,ls[i])
	      end
	    elseif isdir( joinpath(path, ls[i]) )
	      WebServer(joinpath(folder, ls[i]) ,exten)
	    end
	  end
	end

	function webserverfiles(load::AbstractString)
	  if load == "*"
	    WebServer("", "")
	  else
	    WebServer("", load)
	  end
	end