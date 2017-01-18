    xml.DatasetURI(@dataset.DatasetURI)
    xml.Organization(@dataset.Organization)
    xml.Title(@dataset.Title)
    xml.Abstract(@dataset.Abstract)
		if @dataset.StartDate == "" then
			xml.ReferenceDate(@dataset.ReferenceDate)
		else
			xml.ReferenceDate(@dataset.ReferenceDate, "startDate".to_sym => @dataset.StartDate)
		end
    xml.Version(@dataset.Version)
    xml.Documentation(@dataset.Documentation)
    xml.DatasetKey(@dataset.DatasetKey, "type".to_sym => "http://www.w3.org/TR/xmlschema-2/##{@dataset.KeyType}", "length".to_sym => @dataset.KeyLength, "decimals".to_sym => @dataset.KeyDecimals) 
    xml.KeyRelationship(@dataset.KeyRelationship)
    xml.KeyComplete(@dataset.KeyComplete)
