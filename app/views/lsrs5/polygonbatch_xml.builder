xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
#if !(@xsl == "") then xml.instruct! 'xml-stylesheet', :type=>"text/xsl", :href=>"#{@xsl}" end
xml.tag!("GDAS", 
"service".to_sym => "TJS", 
"version".to_sym => "1.0", 
"xml:lang".to_sym => "#{@lang}", 
"xmlns".to_sym => "http://www.opengis.net/tjs/1.0", 
"xmlns:ows".to_sym => "http://www.opengis.net/ows/1.1", 
"xmlns:xsi".to_sym => "http://www.w3.org/2001/XMLSchema-instance", 
"xsi:schemaLocation".to_sym => "http://www.opengis.net/tjs/1.0  ../schemas/tjs/1.0/tjsGetData_response.xsd") do
  xml.Framework do
#    xml << render (:partial => '/tjs/1.0/gdas_write_framework')
    xml.Dataset do
#      xml << render (:partial => '/tjs/1.0/gdas_write_dataset')
#      xml << render (:partial => '/tjs/1.0/gdas_write_attribute_array')
      xml.Rowset do
#        xml << render (:partial => '/tjs/1.0/gdas_write_rowset_array')
      end # Rowset
    end # Dataset
  end # Framework
end #GDAS
