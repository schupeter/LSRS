xml.tag!("Attribute", "purpose".to_sym => "Data") do
  xml.AttributeName(@attribute.AttributeName)
  xml.Title(@attribute.gattributedescription.Title)
  xml.Abstract(@attribute.gattributedescription.Abstract)
  xml.Documentation(@attribute.gattributedescription.Documentation)
  xml.Values do
    if @attribute.gattributedescription.Kind == "Nominal"
      xml.tag!("Nominal", "type".to_sym => "http://www.w3.org/TR/xmlschema-2/#String", "length".to_sym => @attribute.Length, "decimals".to_sym => "0") do
        if @classesArray.size > 0
          xml.Classes
        end
      end
    elsif @attribute.gattributedescription.Kind == "Ordinal"
      xml.tag!("Ordinal", "type".to_sym => "http://www.w3.org/TR/xmlschema-2/#String", "length".to_sym => @attribute.Length, "decimals".to_sym => "0") do
        exception="false" # assume no exception values exist
        xml.Classes do
          xml.Title("Title")
          xml.Abstract("Abstract")
          xml.Documentation("Documentation")
          for range in @rangesArray
            xml.tag!("Value", "rank".to_sym => range.Rank) do
              xml.Identifier(range.Identifier)
              xml.Title(range.Title)
              xml.Abstract(range.Range)
              if range.Documentation != "" then xml.Documentation end
            end # of Value element 
          end # of for range
        end # of Classes element
        xml.Exceptions do
          for exception in @exceptionsArray
            xml.Null do
              xml.Identifier(exception.Identifier)
              xml.Title(exception.Title)
              xml.Abstract(exception.Abstract)
              xml.Documentation
            end # Value
          end # for value
        end # Exceptions
      end # Ordinal element
    end # if ...Kind
  end # Values
end # Attribute
