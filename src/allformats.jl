
function toplanetext(data::String)
   return data
end


formats = Dict{String,Function}(
  "*/*"              =>  toplanetext
  , "text/plain"       =>  toplanetext
  , ""       =>  toplanetext
)