

function cleanurl(url::Union{SubString{String},String})::String

  indexinit::Int64 = 1
  indexend::Int64 = length(url)

  if url[1] == '/'
  	indexinit=2
  end

  if url[indexend] == '/'
    indexend = indexend-1
  end

  return url[indexinit:indexend]

end