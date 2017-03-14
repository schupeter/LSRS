class Polygon

	def Polygon.get_data(polygon, climate, errors)
    # component table
		polygon.cmpTableName = polygon.frameworkName.capitalize.delete("~") + "_cmp"
    polygon.cmpTableMetadata = LsrsCmp.where("WarehouseName"=>polygon.cmpTableName).first
		errors.push "FrameworkName = #{polygon.cmpTableName}" if polygon.cmpTableMetadata ==  nil
    polygon.databaseTitle = polygon.cmpTableMetadata.Title_en
    polygon.cmpData = eval(polygon.cmpTableName).where(:poly_id=>polygon.poly_id)
		errors.push "PolyId = #{polygon.poly_id}" if polygon.cmpData ==  nil
    # climate table
    climate.tableMetadata = LsrsClimate.where("WarehouseName" => climate.tableName).first
		errors.push "ClimateTable = #{climate.tableName}" if climate.tableMetadata ==  nil
    # locate climate data for a polygon
    # if component table or climate table are based on the SLC, then use the appropriate SLC poly_id
    if polygon.cmpTableMetadata.FrameworkURI[0..35] == "http://sis.agr.gc.ca/cansis/nsdb/slc" then #cmp is from the SLC
      polygon.cmpType = "SLC"
      polygon.landscape_id = polygon.poly_id
      climate.poly_id = polygon.poly_id
    elsif climate.tableMetadata.FrameworkURI[0..35] == "http://sis.agr.gc.ca/cansis/nsdb/slc" then #cmp is not based on SLC, but climatetable is based on SLC
      polygon.prtRecord = eval(polygon.cmpTableMetadata.PolygonRatingTable.capitalize).where(:poly_id => polygon.poly_id).first
      if polygon.prtRecord == nil then
				errors.push "PolyId = #{polygon.poly_id}"
      else
        polygon.landscape_id = polygon.prtRecord.slc_v3r2.to_s
        climate.poly_id = polygon.landscape_id
      end
    else # cmp and climate data not SLC, must use CMP poly_id to obtain climatetable data
      polygon.prtRecord = eval(polygon.cmpTableMetadata.PolygonRatingTable.capitalize).where(:poly_id => polygon.poly_id).first
      if polygon.prtRecord == nil then
				errors.push "PolyId = #{polygon.poly_id}"
      else
        polygon.landscape_id = prtRecord.poly_id
        climate.poly_id = polygon.landscape_id
      end
    end
		climate.data = eval(climate.tableName).where(:poly_id=>climate.poly_id).first
		errors.push "Climate data not found" if climate.data ==  nil
		if polygon.prtRecord == nil then
			errors.push "Polygon data not found"
		else
			# erosivity_region
			if polygon.cmpType == "SLC" then slc_v3r2 = polygon.poly_id else slc_v3r2 = polygon.prtRecord.slc_v3r2 end
			eco_id = Slc_v3r2_canada_pat.where(:poly_id=>slc_v3r2).first.eco_id
			ecoprovince = Slc_v3r2_canada_eft.where(:eco_id=>eco_id).first.ecoprovinc
			polygon.erosivity_region = Climate_erosivity.identify_erosivityregion(ecoprovince).to_s
		end
	end

	def Polygon.get_ratings(crop, polygon, climateData, climateRating, errors)
		case crop
		when "alfalfa", "brome"
			params = {:ppe=>climateData.ppe.round, :gdd=>climateData.gdd.round, :gsl=>climateData.gsl.round, :esm=>climateData.esm.round, :efm=>climateData.efm.round}
		when "canola"
			params = {:ppe=>climateData.ppe.round, :egdd=>climateData.egdd.round, :canhm=>climateData.canhm.round, :esm=>climateData.esm.round, :efm=>climateData.efm.round}
		when "sssgrain"
			params = {:ppe=>climateData.ppe.round, :egdd=>climateData.egdd.round, :esm=>climateData.esm.round, :efm=>climateData.efm.round}
		when "corn", "soybean"
			params = {:ppe=>climateData.ppe.round, :chu=>climateData.egdd.round, :esm=>climateData.esm.round, :efm=>climateData.efm.round}
		end
		Validate.climate_params(params, climateRating, errors)
		eval(crop.capitalize).rate_climate(params, climateRating)
		for cmp in polygon.cmpData do
			site = AccessorsSite.new		
			if polygon.cmpType == "SLC" then
				site.slope = cmp.slope
				site.length = cmp.locsf
				site.stoniness = cmp.stone
			else #DSS
				site.slope = cmp.slope_p
				site.length = cmp.slope_len
				site.stoniness = cmp.stoniness
			end
			params = {:crop=>crop, :soil_id=>cmp.soil_id, :region=>polygon.erosivity_region, :slope=>site.slope, :length=>site.length, :stoniness=>site.stoniness, :ppe=>climateData.ppe, :egdd=>climateData.egdd}
			Validate.site_params(params, site, site.climate, site.soil, site.landscape, site.errors)
			site.percent = cmp.percent
			site.cmp_id = cmp.cmp_id
			site.soil = Soildata.get(params[:soil_id])
			Fieldcrop1.rate_soil(params, site)
			Fieldcrop1.rate_landscape(params, site)
			polygon.components.push(site)
		end
	end

	def Polygon.aggregate_ratings(components, climate, aggregate)
    # Create aggregate rating
    # STEP 1: Assign Components to Categories
    category = Aggregate5.Categorize(components)
    # STEP 2: Summarize the special Not Rated category
    percentNotRated = Aggregate5.NotRated(category.NotRated)
    # STEP 3: Summarize the normal categories:
    drainageFactorHash = Aggregate5.Soil(category.Drainage)
    dominantFactorHash = Aggregate5.Soil(category.Dominant)
    dissimilarFactorHash = Aggregate5.Soil(category.Dissimilar)
    
    # STEP 4: Determine the class number 
    # assign climate factor rating
    drainageFactorHash['ClimateRating'] = climate.final_rating.round
    dominantFactorHash['ClimateRating'] = climate.final_rating.round
    dissimilarFactorHash['ClimateRating'] = climate.final_rating.round
    # determine most limiting factor and calculate class
    drainageFactorHash = Aggregate5.MostLimitingFactor(drainageFactorHash)
    dominantFactorHash = Aggregate5.MostLimitingFactor(dominantFactorHash)
    dissimilarFactorHash = Aggregate5.MostLimitingFactor(dissimilarFactorHash)
    
    # STEP 5: Aggregate5 the subclass values (do this before step 4 to initialize *SubfactorHash easily)
    # Step 5.1: Calculate weighted average for soil and landscape factors
    drainageSubfactorHash = Aggregate5.SummarizeSubfactors(category.Drainage, drainageFactorHash['Percent'])
    dominantSubfactorHash = Aggregate5.SummarizeSubfactors(category.Dominant, dominantFactorHash['Percent'])
    dissimilarSubfactorHash = Aggregate5.SummarizeSubfactors(category.Dissimilar, dissimilarFactorHash['Percent'])
    # introduce climate subfactors A/H
    drainageSubfactorHash['H'] = climate.heat.H
    drainageSubfactorHash['A'] = climate.aridity.A
    dominantSubfactorHash['H'] = climate.heat.H
    dominantSubfactorHash['A'] = climate.aridity.A
    dissimilarSubfactorHash['H'] = climate.heat.H
    dissimilarSubfactorHash['A'] = climate.aridity.A
    # STEP 5.2: sort subclasses in order of importance
    drainageSubfactorHash.sort { |l, r| l[1]<=>r[1] }
    dominantSubfactorHash.sort { |l, r| l[1]<=>r[1] }
    dissimilarSubfactorHash.sort { |l, r| -1*(l[1]<=>r[1]) }
    
    # STEP 6: Drop the less important subclasses
    # Step 6.1 drop subfactor values less than or equal to 20
    drainageSubfactorHash = Aggregate5.DropBelow20(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate5.DropBelow20(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate5.DropBelow20(dissimilarSubfactorHash)
    # Step 6.2 drop A and H if climate is not the most limiting factor
    drainageSubfactorHash = Aggregate5.DropAH(drainageSubfactorHash, drainageFactorHash)
    dominantSubfactorHash = Aggregate5.DropAH(dominantSubfactorHash, dominantFactorHash)
    dissimilarSubfactorHash = Aggregate5.DropAH(dissimilarSubfactorHash, dissimilarFactorHash)
    # Step 6.3  drop A or M if both are present
    drainageSubfactorHash = Aggregate5.DropAM(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate5.DropAM(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate5.DropAM(dissimilarSubfactorHash)
    # Step 6.4  drop less significant subclasses
    # Step 6.4.1  within factor comparison
    drainageSubfactorHash = Aggregate5.DropWithinFactor(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate5.DropWithinFactor(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate5.DropWithinFactor(dissimilarSubfactorHash)
    # Step 6.4.2  between factor comparison
    drainageSubfactorHash = Aggregate5.DropOtherFactors(drainageSubfactorHash, drainageFactorHash)
    dominantSubfactorHash = Aggregate5.DropOtherFactors(dominantSubfactorHash, dominantFactorHash)
    dissimilarSubfactorHash = Aggregate5.DropOtherFactors(dissimilarSubfactorHash, dissimilarFactorHash)
    # Step 6.5 determine primary subclass
    drainageFactorHash = Aggregate5.PrimarySubclass(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate5.PrimarySubclass(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate5.PrimarySubclass(dissimilarSubfactorHash, dissimilarFactorHash)
    # determine remaining subclasses
    drainageFactorHash = Aggregate5.AdditionalSubclasses(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate5.AdditionalSubclasses(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate5.AdditionalSubclasses(dissimilarSubfactorHash, dissimilarFactorHash)

    # STEP 7: Create Category Ratings
    drainageFactorHash = Aggregate5.FinalClass(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate5.FinalClass(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate5.FinalClass(dissimilarSubfactorHash, dissimilarFactorHash)
    
    # STEP 8: Create a Composite Rating
    # calculate deciles
    decileArray = Calculate.perdecim([drainageFactorHash['Percent'], dominantFactorHash['Percent'], dissimilarFactorHash['Percent'], percentNotRated])
    drainageFactorHash['PerDecim']  = decileArray[0]
    dominantFactorHash['PerDecim'] = decileArray[1]
    dissimilarFactorHash['PerDecim'] = decileArray[2]
    perdecimNotRated = decileArray[3]
    # create rating
    aggregate.replace(Aggregate5.rating(drainageFactorHash,dominantFactorHash,dissimilarFactorHash,perdecimNotRated))
	end

end	
