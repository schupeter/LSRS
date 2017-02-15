class Fieldcrop1

 	def Fieldcrop1.rate_soil(params, site)
		console
		
		if site.soil.name == nil   # missing name data - process as non-soil
			site.soil.SuitabilityClass = "NotRated"
			site.soil.NotRatedReason = "Missing soil name data"
		else # name data exists
			if site.soil.layers == []   # missing layer data - process as non-soil
				site.soil.SuitabilityClass = "NotRated"
				site.soil.NotRatedReason = "Missing soil layer data"
			else # name and layer data exists
				if site.soil.name.order3 == "OR" then  # organic soil
					if site.soil.name.g_group3 == "FO" and site.soil.name.s_group3 == "HU" then # folic humisol - process as pseudo mineral (not rated) 
						site.soil.SuitabilityClass = "NotRated"
						site.soil.NotRatedReason = "Folic Humisol"
					else # normal organic
						#cmp = Organic.inputsSLC(cmp, @nameRecords[0])
						OrganicPrep.inputs(site.soil)
						#cmp = Organic.horizonsSLC(cmp, @layerRecords)
						OrganicPrep.generalize_layers(site.soil)
						#if @management == "improved" then cmp = Organic.management(cmp, manageBySoil, manageByCrop) end# deleted 20151027
						#if @management == "improved" then cmp = Organic.management(cmp) end
						
						#cmp = Organic.calc(cmp, @climatePoly, @organicCoeff)
						OrganicFormulas.calc(site.soil, site.climate, Organic.params(LsrsOrganicparam.where(:crop=>site.crop)) )
					end
				elsif site.soil.name.order3 == "-" then  # unclassified soil  - process as pseudo mineral component (not rated)
						site.soil.SuitabilityClass = "NotRated"
						site.soil.NotRatedReason = "Unclassified soil (i.e. placeholder)"
				else 	# mineral soil
					MineralPrep.inputs(site.soil)
					MineralPrep.generalize_layers(site.soil, site.climate.PPE)
					MineralPrep.validate_values(site.soil)
					MineralFormulas.mineral(site.soil, site.climate.PPE, Mineral.params(LsrsMineralparam.where(:crop=>site.crop)), site.crop.capitalize)
				end
			end
		end
	end

	def Fieldcrop1.rate_landscape(params, site)
		Landscape.model_v5(site.crop, site.landscape)
		Landscape.slopeFactor(site.crop, site.landscape)
		Landscape.fragmentsFactor(site.crop, site.soil, site.landscape)
		Landscape.otherFactors(site.crop, site.landscape)
	end

end
