class LsrsbatchController < ApplicationController
# This program generates LSRS ratings for multiple polygons.
# This program runs in two modes.  RawDataOutput and ResponseDocument.
# ResponseDocument mode populates directories in the /public/batch/ hierarchy.
# A control file is written to the /public/batch/pending/ directory 
# A cron job (/lib/lsrs_batch_cron) moves processes from pending to processing and runs lsrs.
# Outputs are written to /public/batch/outputs.

  def service
    # initialize request parameters to prevent errors during subsequent testing
#    @polygonHash = Hash.new
    @cropHash = Hash.new
    @responseForm = "RawDataOutput"

# standardize request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
					@frameworkName = value
          @cmpTable = value.delete("~") + "_cmp"
        when "FROMPOLY"  
          @fromPoly = value
#          @polygonHash.store("SL", value)
        when "TOPOLY"  
          @toPoly = value
#          @polygonHash.store("SL", value)
        when "REGION"
          @region = value
        when "CROP"
          @crop = value
          @cropHash.store("CROP", value)
        when "RESPONSEFORM"
          @responseForm = value
        when "CLIMATETABLE"
          @climateTableName = value
				when "MANAGEMENT"
					@management = value
      end # case
    end # params
		if @management != "improved" then @management = "basic" end

#    render :action => 'DescribeProcess_response', :layout => false and return and exit 1
    # validate request parameters
    params.delete("action")
    params.delete("controller")
    if params.size == 0 then
      # request is for a process description document
      @processHash = YAML.load_file("#{Rails.root.to_s}/config/services/wps/processes/lsrs.yml")
      @lang="en"
      render :action => 'DescribeProcess_response', :layout => false and return and exit 1
    else
      if (Lsrs_climateparam.where(:crop => @crop).size !=  1 ) then # invalid crop name
        @exceptionCode = "InvalidParameterValue"
        @exceptionParameter = "CROP"
        @exceptionParameterValue = @crop
        render :action => 'Error_response', :layout => false and return and exit 1
      end
    end
    # get metadata
    dataset = LsrsCmp.where("WarehouseName" => @cmpTable).first
    framework = LsrsFramework.where("FrameworkURI"=>dataset.FrameworkURI).first
    # determine polygon numbers for processing
    if !(defined? @region) or @region == "" then # determine valid polygon numbers for processing
      if !(defined? @fromPoly) or @fromPoly == "" then # request parameter missing, so return error
        @exceptionCode = "MissingParameterValue"
        @exceptionParameter = "fromPoly"
        render :action => 'Error_response', :layout => false and return and exit 1
      end
      if !(defined? @toPoly) or @toPoly == "" then # request parameter missing, so return error
        @exceptionCode = "MissingParameterValue"
        @exceptionParameter = "toPoly"
        render :action => 'Error_response', :layout => false and return and exit 1
      end
      polyNumbers = eval(@cmpTable.capitalize).where(:poly_id=>@fromPoly..@toPoly) 
    else # read in all polygon numbers or numbers by province
      if @region == "all" then #select all polygons
        polyNumbers = eval(@cmpTable.capitalize).all
      else # must be prov identifier
				regionDir = "/production/geodata/" + @cmpTable.split("_")[0..2].join("/") + "/polygonsets/"
        f = File.open(regionDir + @region + ".txt", "r")
        @polyArray = f.readlines
      end
      # ensure batch status page works
      @fromPoly = @region
      @toPoly = @region
    end
    # ensure numbers are sorted and unique; assume province listings are sorted in preferred order; deal with the others
    if defined?(@polyArray) == nil then 
      @polyArray = Array.new
      for row in polyNumbers do
        @polyArray.push row["poly_id"]
      end
      if @polyArray.size == 0 then # no valid identifiers in range
        @exceptionCode = "InvalidParameterValue"
        @exceptionText = "No valid polygon identifiers found within the range fromPoly toPoly"
        render :action => 'Error_response', :layout => false and return and exit 1
      end
      @polyArray.uniq!.sort!
    end
    
    # create unique string for temporary directory names
    timeString = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t") + "r" + rand.to_s[2,4] 

    # prepare output
    if @responseForm == "ResponseDocument" or @polyArray.size > 30 then
      # return status document as per WPS
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
    else
      # return response directly (RawDataOutput)
      # determine temporary directory/file names and file URLs for status file and others
      outputFilename = "#{Rails.root.to_s}/tmp/#{timeString}.xml"
      # prepare to call LSRS routine
      require "#{Rails.root.to_s}/app/helpers/libxml-helper"
      require "open-uri"
      #require "#{Rails.root.to_s}/lib/lsrs_xml_read"
      # prepare output file
      outputFile = File.open(outputFilename, 'w') 
      # populate top section
      require "#{Rails.root.to_s}/lib/lsrs_gdas"
      climateTitle = LsrsClimate.where(:WarehouseName=>@climateTableName).first.Title_en
      LSRS_GDAS.top(outputFile, @crop, framework, @cmpTable, climateTitle, @climateTableName)
      #populate rowset by calling LSRS routine for each polygon
      @polyArray.each_with_index do | poly, i |
        lsrsURL = "http://#{request.host}/lsrs/service?FRAMEWORKNAME=" + @frameworkName + "&POLYID=" + poly.to_s + "&CROP=" + @crop + "&CLIMATETABLE=" + @climateTableName + "&MANAGEMENT=" + @management + "&RESPONSE=Rate"
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
      # render and delete temporary file
      render :file => outputFilename, :content_type => "text/xml", :layout => false and File.delete(outputFilename) and return and exit 1
    end
  end

	def client
    params.each do |key, value|      # standardize request parameters
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
          @frameworkName = value
					@cmpTable = value.delete("~") + "_cmp"
					@patTable = value.delete("~").capitalize + "_pat"
      end # case
    end # params
    if !(defined? @frameworkName) or @frameworkName == "" then
      @step = 1
      @soilDatasets = LsrsCmp.order("Title_en ASC")
    else
      @step = 2
      @soilDataset = LsrsCmp.where(:WarehouseName=>@cmpTable).first
      @climateTables = LsrsClimate.where('PolygonTable like ? or PolygonTable like ?',@soilDataset.DSSClimatePolygonTable,@soilDataset.SLCClimatePolygonTable)
      @crops = Lsrs_crop.all
    end
    render
  end

  def Index
    render
  end
end
