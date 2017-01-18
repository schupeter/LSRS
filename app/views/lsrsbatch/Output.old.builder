# return results 
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
xml.instruct! :'xml-stylesheet', :type=>"text/xsl", :href=>"/stylesheets/lsrs/1.0/lsrsBatchOutput.xsl" 
xml.LSRS do
  xml.Crop(@crop)
  for record in @ratingArray do
    xml.Polygon do
      xml.Id(record[0])
      xml.Rating(record[1])
    end
  end
end
