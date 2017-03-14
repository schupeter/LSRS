# return results 
#xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
xml.Row do
  xml.K(@rating.polygon.poly_id)
  xml.V(@rating.aggregate)
end
