
function toplanetext(data::String)
   return data
end

function tojson(data::String)
   return JSON.parse(data)
end

function toxml(data::String)
   return parse_xml(content)
end


formats = Dict(
    "application/json" =>  tojson
  #, "application/xml"  =>  toxml
  , "*/*"              =>  toplanetext
  , "text/plain"       =>  toplanetext
)