class Polygonbatch
	#lsrs5

	def Polygonbatch.get_poly_ids(batch)
    # get metadata
    dataset = LsrsCmp.where("WarehouseName" => batch.cmpTableName).first
		batch.framework = LsrsFramework.where("FrameworkURI"=>dataset.FrameworkURI).first
    # determine polygon numbers for processing
    if batch.region == nil then # determine valid polygon numbers from a range
      polyArray = eval(batch.cmpTableName.capitalize).where(:poly_id=>batch.fromPoly..batch.toPoly).select(:poly_id).map{|x| x.poly_id}
    else # read in all polygon numbers, or numbers for a region
      if batch.region == "all" then #select all polygons
        polyArray = eval(batch.cmpTableName.capitalize).all.select(:poly_id).map{|x| x.poly_id}
      else # must be a region
				regionDir = "/production/geodata/" + batch.cmpTableName.split("_")[0..2].join("/") + "/polygonsets/"
        f = File.open(regionDir + batch.region + ".txt", "r")
        polyArray = f.readlines
      end
      # ensure batch status page works RELOCATE THIS CODE!!!
      @fromPoly = @region
      @toPoly = @region
    end
		if polyArray == [] then
			batch.errors.push("No polygon identifiers found")
		else
			batch.polygonsHash = Hash[polyArray.sort.uniq.zip] # convert array of poly_ids to a hash with nil values
		end
    batch.timeStamp = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t") + "r" + rand.to_s[2,4]
	end

	def Polygonbatch.calc_ratings(batch)
		params2 = {"FrameworkName"=>batch.frameworkName, "Climate"=>batch.climateTableName, "Crop"=>batch.crop, "Management"=>batch.management}
		for poly in batch.polygonsHash.keys do
			params2["PolyId"] = poly
			# this part is identical to how a single polygon gets calculated
			@rating = AccessorsRating.new
			Validate.polygon(params2, @rating)
			Polygon.get_data(@rating.polygon, @rating.climateData, @rating.errors) if @rating.errors == []
			Polygon.get_ratings(@rating.crop, @rating.polygon, @rating.climateData.data, @rating.climate, @rating.errors) if @rating.errors == []
			Polygon.aggregate_ratings(@rating.polygon.components, @rating.climate, @rating.aggregate) if @rating.errors == []
			if @rating.errors == [] then
				batch.polygonsHash[poly] = @rating.aggregate
			else
				batch.polygonsHash[poly] = @rating.errors.join("; ")
			end
		end
	end

	def Polygonbatch.run(batch) # OBSOLETE
		# return response directly (RawDataOutput)
		# prepare to call LSRS routine
		require "#{Rails.root.to_s}/app/helpers/libxml-helper"
		require "#{Rails.root.to_s}/app/models/ogc/lsrs_gdas"
		require "open-uri"
		# create output file
		outputFile = File.open("#{Rails.root.to_s}/tmp/#{batch.timeStamp}.xml", 'w') 
		# populate top section
		#climateTitle = LsrsClimate.where(:WarehouseName=>batch.climateTableName).first.Title_en
		LSRS_GDAS.top(outputFile, batch.crop, batch.framework, batch.cmpTableName, batch.climateMetadata[:title], batch.climateTableName)
		#populate rowset by calling LSRS routine for each polygon
		batch.polyArray.each_with_index do | poly, i |
			lsrsURL = "http://#{batch.host}/lsrs5/polygon?FRAMEWORKNAME=" + batch.frameworkName + "&POLYID=" + poly.to_s + "&CROP=" + batch.crop + "&CLIMATETABLE=" + batch.climateTableName + "&MANAGEMENT=" + batch.management + "&RESPONSE=Rate"
			# append XML to file
			response = open(lsrsURL).read()
			if response[0..4] == "<Row>" then
				outputFile << response.split("CSV:\n")[0]
			else
				outputFile.puts "<Row>"
				outputFile.puts "<K>#{poly}</K>"
				outputFile.puts "<V>Error</V>"
				outputFile.puts "</Row>"
			end
		end
		LSRS_GDAS.bottom(outputFile)
		outputFile.close
	end

	def Polygonbatch.queue(batch)
		# create unique string for temporary directory names
		timeString = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t") + "r" + rand.to_s[2,4] 
    # return status document as per WPS
    # create unique string for temporary directory names
		batch.dir =  "#{Rails.root.to_s}/public/batch5"
		batch.url = "/batch5/results/#{timeString}"
    # prepare output
    # determine temporary directory/file names and file URLs for status file and others
		batchDirName = "#{batch.dir}/results/" + timeString
		batchName  = "#{batch.frameworkName}_#{batch.crop}_#{batch.management}_#{batch.climateTableName.delete('/')}_#{timeString}"
		
		statusFilename = "#{batchDirName}/status.xml"
		controlFilename = "#{batchDirName}/control.yml"
		polygonFilename = "#{batchDirName}/polygons.txt"
		outputXmlFilename = "#{batchDirName}/output.xml"
		outputCsvFilename = "#{batchDirName}/#{batchName}.csv"
		outputHtmlFilename = "#{batchDirName}/#{batchName}.html"
		outputDbfFilename = "#{batchDirName}/#{batchName}.dbf"
		outputDbfSummaryFilename = "#{batchDirName}/#{batchName}summary.dbf"
		detailsRootURL = "#{batch.url}/"
		outputDbfURL = "#{batch.url}/#{batchName}.dbf"
		# pass configuration back to controller
		batch.statusFilename = statusFilename
		batch.statusURL = "#{batch.url}/status.xml"
		batch.outputURL = "#{batch.url}/output.xml"
		# create HTTP directories
		Dir.mkdir(batchDirName) unless File::directory?(batchDirName)
		#Create XML for status document
		require 'wps'
		xml = Wps1.CreateStatusXml(batch.statusURL, batch.outputURL, batch.cmpTableName, batch.fromPoly, batch.toPoly, batch.crop, batch.management, batch.climateTableName, "ProcessAccepted", 0)
		# store status document as file
		statusFile = File.open(statusFilename, 'w')
		statusFile << xml.target!
		statusFile.close
		# create control file
		controlFile = File.open(controlFilename, 'w')
		controlFile.puts "Hostname: " + batch.host
		controlFile.puts "RailsRoot: " + Rails.root.to_s
		controlFile.puts "DetailsRootURL: " + detailsRootURL
		controlFile.puts "PolygonsFilename: " + polygonFilename
		controlFile.puts "StatusFilename: " + statusFilename
		controlFile.puts "StatusURL: " + batch.statusURL
		controlFile.puts "OutputXmlFilename: " + outputXmlFilename
		controlFile.puts "OutputCsvFilename: " + outputCsvFilename
		controlFile.puts "OutputDbfFilename: " + outputDbfFilename
		controlFile.puts "OutputHtmlFilename: " + outputHtmlFilename
		controlFile.puts "OutputDbfSummaryFilename: " + outputDbfSummaryFilename
		controlFile.puts "OutputURL: " + batch.outputURL
		controlFile.puts "OutputDbfURL: " + outputDbfURL
		controlFile.puts "FrameworkName: " + batch.frameworkName
		controlFile.puts "ComponentTable: " + batch.cmpTableName
		controlFile.puts 'FromPoly: "' + batch.fromPoly + '"'
		controlFile.puts 'ToPoly: "' + batch.toPoly + '"'
		controlFile.puts "Crop: " + batch.crop
		controlFile.puts "Management: " + batch.management
		controlFile.puts "ClimateTable: " + batch.climateTableName 
		controlFile.close
		# create link in pending
		FileUtils.ln_s(controlFilename, "#{batch.dir}/pending/#{timeString}_control.yml")
		# create polygon file
		polygonFile = File.open(polygonFilename, 'w')
		for poly in batch.polygonsHash.keys.sort do
			polygonFile.puts poly
		end
		polygonFile.close
	end

end
