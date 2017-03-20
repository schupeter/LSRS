class Polygonbatch

	def Polygonbatch.get_poly_ids(batch)
    # get metadata
    dataset = LsrsCmp.where("WarehouseName" => batch.cmpTableName).first
		batch.framework = LsrsFramework.where("FrameworkURI"=>dataset.FrameworkURI).first
    # determine polygon numbers for processing
    if batch.region == nil then # determine valid polygon numbers from a range
      batch.polyArray = eval(batch.cmpTableName.capitalize).where(:poly_id=>batch.fromPoly..batch.toPoly).select(:poly_id).map{|x| x.poly_id}.sort.uniq
    else # read in all polygon numbers, or numbers for a region
      if batch.region == "all" then #select all polygons
        batch.polyArray = eval(batch.cmpTableName.capitalize).all.select(:poly_id).map{|x| x.poly_id}.sort.uniq
      else # must be a region
				regionDir = "/production/geodata/" + batch.cmpTableName.split("_")[0..2].join("/") + "/polygonsets/"
        f = File.open(regionDir + batch.region + ".txt", "r")
        batch.polyArray = f.readlines
      end
      # ensure batch status page works RELOCATE THIS CODE!!!
      @fromPoly = @region
      @toPoly = @region
    end
    batch.errors.push("No polygon identifiers found") if batch.polyArray == []
    batch.timeStamp = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t") + "r" + rand.to_s[2,4]
	end

	def Polygonbatch.run(batch)
		# return response directly (RawDataOutput)
		# determine temporary directory/file names and file URLs for status file and others
		batch.outputFilename = "#{Rails.root.to_s}/tmp/#{batch.timeStamp}.xml"
		# prepare to call LSRS routine
		require "#{Rails.root.to_s}/app/helpers/libxml-helper"
		require "#{Rails.root.to_s}/lib/lsrs_gdas"
		require "open-uri"
		# create output file
		outputFile = File.open(batch.outputFilename, 'w') 
		# populate top section
		climateTitle = LsrsClimate.where(:WarehouseName=>batch.climateTableName).first.Title_en
		LSRS_GDAS.top(outputFile, batch.crop, batch.framework, batch.cmpTableName, climateTitle, batch.climateTableName)
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
    # return status document as per WPS
    # create unique string for temporary directory names
		batch.dir =  "#{Rails.root.to_s}/public/batch/"
		batch.url = "/batch/results/#{batch.timeStamp}/"
    # prepare output
    # determine temporary directory/file names and file URLs for status file and others
		statusDirName = "#{Rails.root.to_s}/public/batch/results/" + timeString
		statusFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/status.xml"
		controlFilename = "#{Rails.root.to_s}/public/batch/pending/#{timeString}_control.yml"
		polygonFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/polygons.txt"
		outputXmlFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/output.xml"
		outputCsvFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/output.csv"
		outputHtmlFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/output.html"
		outputDbfFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/#{@frameworkName}_#{@crop}_#{@management}_#{@climateTableName}_#{timeString}.dbf"
		outputDbfSummaryFilename = "#{Rails.root.to_s}/public/batch/results/#{timeString}/#{@frameworkName}_#{@crop}_#{@management}_#{@climateTableName}_#{timeString}summary.dbf"
		detailsDirName = "#{Rails.root.to_s}/public/batch/results/#{timeString}/details/"
		detailsRootURL = "/batch/results/#{timeString}/"
		outputDbfURL = "/batch/results/#{timeString}/#{@frameworkName}_#{@crop}_#{@management}_#{@climateTableName}_#{timeString}.dbf"
		@statusURL = "/batch/results/#{timeString}/status.xml"
		@outputURL = "/batch/results/#{timeString}/output.xml"
		# create HTTP directories
		Dir.mkdir(statusDirName) unless File::directory?(statusDirName)
		Dir.mkdir(detailsDirName) unless File::directory?(detailsDirName)
		#Create XML for status document
		require 'wps'
		xml = Wps.CreateStatusXml(@statusURL, @outputURL, @cmpTable, @fromPoly, @toPoly, @crop, @management, @climateTableName, "ProcessAccepted", 0)
		# store status document as file
		statusFile = File.open(statusFilename, 'w')
		statusFile << xml.target!
		statusFile.close
		# create control file
		controlFile = File.open(controlFilename, 'w')
		controlFile.puts "Hostname: " + request.host
		controlFile.puts "RailsRoot: " + Rails.root.to_s
		controlFile.puts "DetailsDirName: " + detailsDirName
		controlFile.puts "DetailsRootURL: " + detailsRootURL
		controlFile.puts "PolygonsFilename: " + polygonFilename
		controlFile.puts "StatusFilename: " + statusFilename
		controlFile.puts "StatusURL: " + @statusURL
		controlFile.puts "OutputXmlFilename: " + outputXmlFilename
		controlFile.puts "OutputCsvFilename: " + outputCsvFilename
		controlFile.puts "OutputDbfFilename: " + outputDbfFilename
		controlFile.puts "OutputHtmlFilename: " + outputHtmlFilename
		controlFile.puts "OutputDbfSummaryFilename: " + outputDbfSummaryFilename
		controlFile.puts "OutputURL: " + @outputURL
		controlFile.puts "OutputDbfURL: " + outputDbfURL
		controlFile.puts "FrameworkName: " + framework.FrameworkName
		controlFile.puts "ComponentTable: " + @cmpTable
		controlFile.puts 'FromPoly: "' + @fromPoly + '"'
		controlFile.puts 'ToPoly: "' + @toPoly + '"'
		controlFile.puts "Crop: " + @crop
		controlFile.puts "Management: " + @management
		controlFile.puts "ClimateTable: " + @climateTableName 
		controlFile.close
		# create polygon file
		polygonFile = File.open(polygonFilename, 'w')
		for poly in @polyArray do
			polygonFile.puts poly
		end
		polygonFile.close
		redirect_to @statusURL
	end

end
