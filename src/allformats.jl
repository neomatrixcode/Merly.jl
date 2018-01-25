
function toplanetext(data)
   return data
end

function tojson(data)
  try
   return JSON.parse(data)
 catch
   warn("The format JSON does not match the data received")
   return data
 end
end

function toxml(data)
  try
   return parse_xml(content)
 catch
   warn("The format XML does not match the data received")
   return data
 end
end


formats = Dict(
    "application/json" =>  tojson
  , "application/xml"  =>  toxml
  , "*/*"              =>  toplanetext
  , "text/plain"       =>  toplanetext
)