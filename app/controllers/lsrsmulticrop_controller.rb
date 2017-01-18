class LsrsmulticropController < ApplicationController
# This program generates LSRS ratings for multiple crops in the same polygon.

  def service
    # initialize request parameters to prevent errors during subsequent testing
#    @polygonHash = Hash.new
    @cropHash = Hash.new

# standardize request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
					@frameworkName = value
          @cmpTable = value.delete("~") + "_cmp"
        when "POLYID"  
          @poly = value
        when "CROP"
          @crop = value
          @cropHash.store("CROP", value)
        when "CLIMATETABLE"
          @climateTableName = value
      end # case
    end # params

#    render :action => 'DescribeProcess_response', :layout => false and return and exit 1
    # validate request parameters
    params.delete("action")
    params.delete("controller")
    if params.size == 0 then
      # request is for a process description document
      @processHash = YAML.load_file("#{Rails.root.to_s}/config/services/wps/processes/lsrs.yml")
      @lang="en"
      render :action => 'DescribeProcess_response', :layout => false and return and exit 1
    end
    # get metadata
    dataset = LsrsCmp.where("WarehouseName" => @cmpTable).first
    climateTitle = LsrsClimate.where("WarehouseName" => @climateTableName).first.Title_en
    framework = LsrsFramework.where("FrameworkURI"=>dataset.FrameworkURI).first

    # return response directly (RawDataOutput)
    # determine temporary directory/file names and file URLs for status file and others
    timeString = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t") + "r" + rand.to_s[2,4] 
    outputFilename = "#{Rails.root.to_s}/tmp/" + timeString + ".xml"
    # prepare to call LSRS routine
    require "#{Rails.root.to_s}/app/helpers/libxml-helper"
    require "open-uri"
    #require "#{Rails.root.to_s}/lib/lsrs_xml_read"
    # prepare output file
    outputFile = File.open(outputFilename, 'w')
    # populate top section
    require "#{Rails.root.to_s}/lib/lsrs_gdas"
    LSRS_GDAS.top(outputFile, "all", framework, @cmpTable, climateTitle, @climateTableName)

    # determine list of crops to process
    @cropArray = Array.new
    Lsrs_climateparam.all.each {|crop| @cropArray.push crop.crop }
    
    #populate rowset by calling LSRS routine for each crop
    outputFile.puts "    <Row>"
    outputFile.puts "      <K>" + @poly + "</K>"
    @cropArray.each_with_index do | crop, i |
      lsrsURL = "http://#{request.host}/lsrs/service?FRAMEWORKNAME=" + @frameworkName + "&POLYID=" + @poly + "&CROP=" + crop + "&CLIMATETABLE=" + @climateTableName + "&RESPONSE=Rate"
      # append rating to file
      response = open(lsrsURL).read().split("CSV:")[0]
      if response[0..4] == "<Row>" then
        outputFile.puts '      <V aid="' + crop + '">' + response.to_libxml_doc.root.search("V")[0].content + "</V>"
      else
        #outputFile.close
        #outputFile = File.open(outputFilename, 'w') 
        outputFile << response
        outputFile.close
        render :file => outputFilename, :content_type => "text/xml", :layout => false and File.delete(outputFilename) and return and exit 1
      end
    end
    outputFile.puts "    </Row>"
    LSRS_GDAS.bottom(outputFile)
    outputFile.close
    # render and delete temporary file
    render :file => outputFilename, :content_type => "text/xml", :layout => false and File.delete(outputFilename) and return and exit 1
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
