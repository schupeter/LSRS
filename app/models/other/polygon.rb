class Polygon

	def Polygon.get_data(polygon, climate, errors)
    # component table
		polygon.cmpTableName = polygon.frameworkName.capitalize.delete("~") + "_cmp"
    polygon.cmpTableMetadata = LsrsCmp.where("WarehouseName"=>polygon.cmpTableName).first
		errors.push "FrameworkName = #{polygon.cmpTableName}" if polygon.cmpTableMetadata ==  nil
    polygon.databaseTitle = polygon.cmpTableMetadata.Title_en
    polygon.components = eval(polygon.cmpTableName).where(:poly_id=>polygon.poly_id)
		errors.push "PolyId = #{polygon.poly_id}" if polygon.components ==  nil
		
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

		# erosivity_region
		if polygon.cmpType == "SLC" then slc_v3r2 = polygon.poly_id else slc_v3r2 = polygon.prtRecord.slc_v3r2 end
		eco_id = Slc_v3r2_canada_pat.where(:poly_id=>slc_v3r2).first.eco_id
		ecoprovince = Slc_v3r2_canada_eft.where(:eco_id=>eco_id).first.ecoprovinc
		polygon.erosivity_region = Climate_erosivity.identify_erosivityregion(ecoprovince)
	end

end	
