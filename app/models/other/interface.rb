class Interface

	def Interface.lsrs5climate(crop, climate)
		case crop
		when "alfalfa", "brome"
			"/lsrs5/crop/#{crop}/climate/#{climate.data[:ppe].round}/#{climate.data[:gdd].round}/#{climate.data[:gsl].round}/#{climate.data[:esm].round}/#{climate.data[:efm].round}"
		when "canola"
			"/lsrs5/crop/#{crop}/climate/#{climate.data[:ppe].round}/#{climate.data[:egdd].round}/#{climate.data[:canhm].round}/#{climate.data[:esm].round}/#{climate.data[:efm].round}"
		when "sssgrain"
			"/lsrs5/crop/#{crop}/climate/#{climate.data[:ppe].round}/#{climate.data[:egdd].round}/#{climate.data[:esm].round}/#{climate.data[:efm].round}"
		when "corn", "soybean"
			"/lsrs5/crop/#{crop}/climate/#{climate.data[:ppe].round}/#{climate.data[:chu].round}/#{climate.data[:esm].round}/#{climate.data[:efm].round}"
		end
	end
	
	def Interface.lsrs5sitefieldcrop(crop, polygon, cmp, climate)
		if polygon.cmpType == "SLC" then
			"/lsrs5/crop/#{crop}/site/#{cmp.soil_id}/#{polygon.erosivity_region}/#{cmp.slope}/#{cmp.locsf}/#{cmp.stone}/#{climate.data[:ppe].round}/#{climate.data[:egdd].round}"
		else #DSS
			"/lsrs5/crop/#{crop}/site/#{cmp.soil_id}/#{polygon.erosivity_region}/#{cmp.slope_p}/#{cmp.slope_len}/#{cmp.stoniness}/#{climate.data[:ppe].round}/#{climate.data[:egdd].round}"
		end
	end

end
