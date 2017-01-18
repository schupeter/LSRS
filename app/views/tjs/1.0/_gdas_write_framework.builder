    xml.FrameworkURI(@framework.FrameworkURI)
    xml.Organization(@framework.send "Organization#{@lang_extension}")
    xml.Title(@framework.send "Title#{@lang_extension}")
    xml.Abstract(@framework.send "Abstract#{@lang_extension}")
		if @framework.StartDate == "" then
			xml.ReferenceDate(@framework.ReferenceDate)
		else
			xml.ReferenceDate(@framework.ReferenceDate, "startDate".to_sym => @framework.StartDate)
		end
		xml.Version(@framework.Version)
    xml.Documentation(@framework.send "Documentation#{@lang_extension}")
    xml.FrameworkKey(@framework.FrameworkKey)
    xml.BoundingBox do
      xml.Minimum do
        xml.Latitude(@framework.MinLat)
        xml.Longitude(@framework.MinLong)
      end
      xml.Maximum do
        xml.Latitude(@framework.MaxLat)
        xml.Longitude(@framework.MaxLong)
      end
    end
