# run using "script/console < app/controllers/lsrs_test.rb",
# or manually at the script/console prompt (but first remove leading tabs)

@polygonHash = Hash.new
@cropHash = Hash.new
@responseForm = "RawDataOutput"

@cmpTable = "Bc_tulameen_soil_v2x0_cmp"
@fromPoly = "90001"
@toPoly = "90002"
@crop = "sssgrain"
@cropHash.store("CROP", @crop)
@climateTable = "Ca_all_slc_v3x0_climate1961x90"
# copy from comment "get metadata" to the offending line, and remove all indents
# ========================================


# get metadata
dataset = Gdataset.find(:all, :conditions=>{"WarehouseName" => @cmpTable})[0]
framework = Gframework.find(:all, :conditions=>{"FrameworkURI" => dataset.FrameworkURI})[0]
# determine valid polygon numbers for processing
#    slNumbers = eval(@cmpTable).find(:all, :conditions => {:sl => @fromPoly..@toPoly})  ## FIX THIS HARDCODING OF sl
slNumbers = eval(@cmpTable).find(:all, :conditions => {dataset.DatasetKey.to_sym => @fromPoly..@toPoly}) 
@slArray = Array.new
for row in slNumbers do
@slArray.push row[dataset.DatasetKey]
end
if @slArray.size == 0 then # no valid identifiers in range
@exceptionCode = "InvalidParameterValue"
@exceptionText = "No valid polygon identifiers found within the range fromPoly toPoly"
render :action => 'Error_response', :layout => false and return and exit 1
end
@slArray.uniq!.sort!
# create unique string for temporary directory names
timeString = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t") + "r" + rand.to_s[2,4] 

    # prepare output
    if @responseForm == "ResponseDocument" or @slArray.size > 30 then
      # return status document as per WPS
      # determine temporary directory/file names and file URLs for status file and others
      statusDirName = "#{Rails.root.to_s}/public/batch/results/" + timeString
      statusFilename = "#{Rails.root.to_s}/public/batch/results/" + timeString + "/status.xml"
      controlFilename = "#{Rails.root.to_s}/public/batch/pending/" + timeString + "_control.yml"
      polygonFilename = "#{Rails.root.to_s}/public/batch/results/" + timeString + "/polygons.txt"
      outputFilename = "#{Rails.root.to_s}/public/batch/results/" + timeString + "/output.xml"
      @statusURL = "/batch/results/" + timeString + "/status.xml"
      @outputURL = "/batch/results/" + timeString + "/output.xml"
      # create temporary HTTP directory
      Dir.mkdir(statusDirName) unless File::directory?(statusDirName)
      #Create XML for status document
      require 'wps'
      xml = Wps.CreateStatusXml(@statusURL, @outputURL, @cmpTable, @fromPoly, @toPoly, @crop, @climateTable, "ProcessAccepted", 0)
      # store status document as file
      statusFile = File.open(statusFilename, 'w')
      statusFile << xml.target!
      statusFile.close
      # create control file
      controlFile = File.open(controlFilename, 'w')
      controlFile.puts "Rails.root.to_s: " + Rails.root.to_s
      controlFile.puts "PolygonsFilename: " + polygonFilename
      controlFile.puts "StatusFilename: " + statusFilename
      controlFile.puts "StatusURL: " + @statusURL
      controlFile.puts "OutputFilename: " + outputFilename
      controlFile.puts "OutputURL: " + @outputURL
      controlFile.puts "FrameworkName: " + framework.FrameworkName
      controlFile.puts "ComponentTable: " + @cmpTable
      controlFile.puts "FromPoly: " + @fromPoly
      controlFile.puts "ToPoly: " + @toPoly
      controlFile.puts "Crop: " + @crop
      controlFile.puts "ClimateTable: " + @climateTable 
      controlFile.close
      # create polygon file
      polygonFile = File.open(polygonFilename, 'w')
      for sl in @slArray do
        polygonFile.puts sl
      end
      polygonFile.close
      redirect_to @statusURL
    else
      # return response directly (RawDataOutput)
      # determine temporary directory/file names and file URLs for status file and others
      outputFilename = "#{Rails.root.to_s}/tmp/" + timeString + ".xml"
      # prepare to call LSRS routine
      require "#{Rails.root.to_s}/app/helpers/libxml-helper"
      require "open-uri"
      require "lsrs_xml_read"
      # prepare output file
      outputFile = File.open(outputFilename, 'w') 
      # populate top section
      require '/usr/local/httpd/lsrs/lib/lsrs_gdas'
      LSRS_GDAS.top(outputFile, @crop, framework)
      #populate rowset by calling LSRS routine for each SL
      @slArray.each_with_index do | poly, i |
        lsrsURL = "http://lsrs.gis.agr.gc.ca/lsrs/service?CMPTABLE=" + @cmpTable + "&POLYID=" + poly.to_s + "&CROP=" + @crop + "&CLIMATETABLE=" + @climateTable + "&RESPONSE=Rate"
        # append XML to file
        response = open(lsrsURL).read()
        if response[0..4] == "<Row>" then
          outputFile << response
        else
          outputFile.close
          outputFile = File.open(outputFilename, 'w') 
          outputFile << response
          outputFile.close
          render :file => outputFilename, :content_type => "text/xml", :layout => false and File.delete(outputFilename) and return and exit 1
        end
      end
      LSRS_GDAS.bottom(outputFile)
      outputFile.close
      # render and delete temporary file
      render :file => outputFilename, :content_type => "text/xml", :layout => false and File.delete(outputFilename) and return and exit 1
    end
  end
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def Index
    render
  end
end


# REBUILD OUTPUT FILES


lsrsURL = "http://lsrs.gis.agr.gc.ca/lsrs/service?ClimateTable=Ca_all_slc_v3x0_climate1961x90nlwis&CmpTable=Ca_all_slc_v3r2_cmp&PolyId=534010&CROP=alfalfa&RESPONSE=Details"
require "#{Rails.root.to_s}/app/helpers/libxml-helper"
require "open-uri"
require "lsrs_xml_read"
response = open(lsrsURL).read().to_libxml_doc.root
outputXmlFile = File.open("#{Rails.root.to_s}/public/lsrstest.xml", 'w')
outputCsvFile = File.open("#{Rails.root.to_s}/public/lsrstest.csv", 'w')

if response.search("//LSRS") != [] then #normal response was received
poly_id = response.search("//LSRS/Request/Polygon").first.content
poly_rating = response.search("//LSRS/Rating/FinalCombinedRating").first.content
c_points = response.search("//LSRS/Climate/Value").first.content.to_i.to_s
c_class = response.search("//LSRS/Climate/Rating").first.content

cmpXMLArray = response.search("//LSRS/SoilLandscape/Cmp")

for cmpXML in cmpXMLArray do
cmp = cmpXML.search("Number").first.content
percent = cmpXML.search("Percent").first.content
cmp_class = cmpXML.search("MineralSoil/Rating").first.content.to_i.to_s
soil_name = cmpXML.search("SoilName").first.content
s_points = cmpXML.search("MineralSoil/Rating").first.content
if s_points == [] then
s_points = cmpXML.search("OrganicSoil/Rating").first.content.to_i.to_s
s_class = cmpXML.search("OrganicSoil/Class").first.content
else
s_points = s_points.to_i.to_s
s_class = cmpXML.search("MineralSoil/Class").first.content
end
l_points = cmpXML.search("Landscape/Rating").first.content.to_i.to_s
l_class = cmpXML.search("Landscape/Class").first.content.to_i.to_s
outputXmlFile.puts "<Row>"
outputXmlFile.puts "  <K>" + poly_id + "</K>"
outputXmlFile.puts "  <V>" + poly_rating + "</V>"
outputXmlFile.puts "</Row>"
outputCsvFile.puts "#{poly_id},#{poly_rating},#{cmp},#{percent},#{cmp_class},#{c_points},#{c_class},#{soil_name},#{s_points},#{s_class},#{l_points},#{l_class}"
#outputHtmlFile.puts "<tr><td>" + poly.to_s + "</td><td>" + response.split("<V>")[1].split("</V>")[0] + "</td></tr>"
end
else  #must be an error response
outputXmlFile.puts "<Row>"
outputXmlFile.puts "  <K>" + poly.to_s + "</K>"
outputXmlFile.puts "  <V>Error</V>"
outputXmlFile.puts "</Row>"
end
outputXmlFile.close
outputCsvFile.close
