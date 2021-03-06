#!/usr/local/bin/ruby
# Script to run LSRSv4 in batch mode
# It is spawned from cron
# It uses a control file generated by the lsrsbatch_controller
# It uses a list of SL numbers from a text file generated by the lsrsbatch_controller
# It constructs a call to the LSRS web service for each SL
# It reads in the original status file and updates that same status file
# It writes its output to an XML file.
# call using 
#     lsrsbatchcron

@baseDir = "/production/sites/sislsrs/public/batch/"

log = File.new(@baseDir + "lsrsbatchlog", "a")
#log.puts("--")
#log.puts(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") + " lsrsbatchcron started" )

pendingJobs = Dir.entries(@baseDir + "pending/")
if pendingJobs.size > 2
  # at least one job is pending
  if Dir.entries(@baseDir + "processing/").size == 2
    # and no jobs are processing, so run the next job
    pendingJobs.delete(".")
    pendingJobs.delete("..")
    nextJob = pendingJobs.sort[0]
    require 'fileutils'
    @controlFilename = @baseDir + "processing/" + nextJob
    FileUtils.mv(@baseDir + "pending/" + nextJob, @controlFilename)
    
    #get control file
    require "yaml"
    @control = YAML.load_file(@controlFilename)

    #get libraries
    #require "rubygems"
    require "#{@control['RailsRoot']}/app/helpers/libxml-helper"
    require "#{@control['RailsRoot']}/app/models/v4andB4/lsrs_xml_read"
    require "#{@control['RailsRoot']}/app/models/ogc/wps"
    require "open-uri"
    require "builder"

    detailsDirName = @control['DetailsDirName']
    @detailsRootURL = @control['DetailsRootURL']
    outputXmlFilename = @control['OutputXmlFilename']
    outputCsvFilename = @control['OutputCsvFilename']
    outputDbfFilename = @control['OutputDbfFilename']
    outputHtmlFilename = @control['OutputHtmlFilename']
    outputDbfSummaryFilename = @control['OutputDbfSummaryFilename']
    @statusFilename = @control['StatusFilename']
    @statusURL = @control['StatusURL']
    @outputURL = @control['OutputURL']
    @frameworkName = @control['FrameworkName']
    @cmpTable = @control['ComponentTable']
    @fromPoly = @control['FromPoly']
    @toPoly = @control['ToPoly']
    @crop = @control['Crop']
		@management = @control['Management']
    @climateTableName = @control['ClimateTable']

    # Get array of SL numbers from the text file that was generated by the lsrsbatch_controller
    @slArray = File.new(@control['PolygonsFilename']).readlines.map {|line| line.chomp}

    # mimic rails
    require 'active_record'
    @config = YAML.load_file("#{@control['RailsRoot']}/config/database.yml")
    ActiveRecord::Base.establish_connection(@config["development"])
    class LsrsCmp < ActiveRecord::Base
		  self.table_name="lsrs_configuration.lsrs_cmps"
    end
    dataset = LsrsCmp.where(:WarehouseName=>@cmpTable).first
    class LsrsFramework < ActiveRecord::Base
			self.table_name="lsrs_configuration.lsrs_frameworks"
    end
    framework = LsrsFramework.where(:FrameworkURI=>dataset.FrameworkURI).first

    #prepare output file
    outputXmlFile = File.open(outputXmlFilename, 'w') 
    # populate top section
    require "#{@control['RailsRoot']}/app/models/ogc/lsrs_gdas"
    class LsrsClimate < ActiveRecord::Base
			self.table_name="lsrs_configuration.lsrs_climates"
    end
    climateTitle = LsrsClimate.where(:WarehouseName=>@climateTableName).first.Title_en
    LSRS_GDAS.top(outputXmlFile, @crop, framework, @cmpTable, climateTitle, @climateTableName)
    
    #Create the HTML file
    outputHtmlFile = File.open(outputHtmlFilename, 'w') 
    outputHtmlFile.puts '<html>'
    outputHtmlFile.puts '<head>'
    outputHtmlFile.puts '<title>LSRS results</title>'
    outputHtmlFile.puts '</head>'
    outputHtmlFile.puts '<body>'
    outputHtmlFile.puts '<h2>Land Suitability Rating Information</h2>'
    outputHtmlFile.puts '<table class="intro">'
    outputHtmlFile.puts '<tr><td class="subheader">Database:</td><td class="Abbr">' + framework.Title_en + '</td></tr>'
    outputHtmlFile.puts '<tr><td class="subheader">Climate:</td><td class="Abbr">' + climateTitle + '</td></tr>'
    outputHtmlFile.puts '<tr><td class="subheader">Crop:</td><td class="Abbr">' + @crop + '</td></tr>'
		outputHtmlFile.puts '<tr><td class="subheader">Management:</td><td class="Abbr">' + @management + '</td></tr>'
    outputHtmlFile.puts '</table>'
    outputHtmlFile.puts '<br/>'
    outputHtmlFile.puts '<table>'
    
    # Create the CSV file
    outputCsvFile = File.open(outputCsvFilename, 'w')
    #outputCsvFile.puts "POLY_ID,POLY_RATING,CMP,PERCENT,CMP_CLASS,CLIMATE_POINTS,CLIMATE_CLASS,SOIL_NAME,SOIL_POINTS,SOIL_CLASS,LANDSCAPE_POINTS,LANDSCAPE_CLASS"
    outputCsvFile.puts "POLY_ID,CMP_ID,POLY_RATING,CMP,PERCENT,CMP_CLASS,CLIMATE_POINTS,CLIMATE_CLASS,PROVINCE,SOIL_CODE,SOIL_NAME,SOIL_POINTS,SOIL_CLASS,LANDSCAPE_POINTS,LANDSCAPE_CLASS"
		
		# define the dbf file
		fields = Array.new
		fields.push({:field_name=>"POLY_ID", :field_size=>13, :field_type=>"C", :decimals=>0})
		fields.push({:field_name=>"CMP_ID", :field_size=>15, :field_type=>"C", :decimals=>0})
		fields.push({:field_name=>"POLY_RATIN", :field_size=>20, :field_type=>"C", :decimals=>0})
		fields.push({:field_name=>"CMP", :field_size=>2, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"PERCENT", :field_size=>3, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"CMP_CLASS", :field_size=>1, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"C_POINTS", :field_size=>3, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"C_CLASS", :field_size=>1, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"PROVINCE", :field_size=>2, :field_type=>"C", :decimals=>0})
		fields.push({:field_name=>"SOIL_CODE", :field_size=>9, :field_type=>"C", :decimals=>0})
		fields.push({:field_name=>"SOIL_NAME", :field_size=>30, :field_type=>"C", :decimals=>0})
		fields.push({:field_name=>"S_POINTS", :field_size=>3, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"S_CLASS", :field_size=>1, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"L_POINTS", :field_size=>3, :field_type=>"N", :decimals=>0})
		fields.push({:field_name=>"L_CLASS", :field_size=>1, :field_type=>"N", :decimals=>0})
		records = Array.new 
		
    #populate output files by calling LSRS routine for each SL
    @slArray.each_with_index do | poly, i |
      lsrsURL = "http://#{@control['Hostname']}/lsrs/service?FRAMEWORKNAME=" + @frameworkName + "&POLYID=" + poly.to_s + "&CROP=" + @crop + "&CLIMATETABLE=" + @climateTableName + "&MANAGEMENT=" + @management + "&RESPONSE=Details"
#     lsrsURL = "http://lsrsdev.gis.agr.gc.ca/lsrs/service?CMPTABLE=" + @cmpTable + "&POLYID=" + poly.to_s + "&CROP=" + @crop + "&CLIMATETABLE=" + @climateTableName + "&RESPONSE=Details"
      # append results to file
      responseRaw = open(lsrsURL).read()
      # write a copy of response to file
      detailsFile = File.open(detailsDirName + poly.to_s + ".xml", 'w')
      detailsFile << responseRaw
      detailsFile.close
      # process results
      response = responseRaw.to_libxml_doc.root
      if response.search("//LSRS") != [] then #normal response was received
        poly_id = response.search("//LSRS/Request/Polygon").first.content
        poly_rating = response.search("//LSRS/Rating/FinalCombinedRating").first.content
        # populate XML file
        outputXmlFile.puts "<Row>"
        outputXmlFile.puts "  <K>" + poly_id + "</K>"
        outputXmlFile.puts "  <V>" + poly_rating + "</V>"
        outputXmlFile.puts "</Row>"
        # populate HTML file
        outputHtmlFile.puts '<tr><td><a href="details/' + poly_id + '.xml">' + poly_id + '</a></td><td>' + poly_rating + '</td></tr>'
        # populate CSV file
        c_points = response.search("//LSRS/Climate/Value").first.content.to_i.to_s
        c_class = response.search("//LSRS/Climate/Rating").first.content
        cmpXMLArray = response.search("//LSRS/SoilLandscape/Cmp")
        for cmpXML in cmpXMLArray do
          cmp = cmpXML.search("Number").first.content
					cmp_id = poly_id + format("%02d",cmp)
          percent = cmpXML.search("Percent").first.content
          l_points = cmpXML.search("Landscape/Rating").first.content.to_i.to_s
          l_class = cmpXML.search("Landscape/Class").first.content.to_i.to_s
          soil_name = cmpXML.search("SoilName").first.content.gsub(","," ")
          province = cmpXML.search("Soil_id").first.content[0..1]
          soil_codemodpro = cmpXML.search("Soil_id").first.content[2..-1]
          s_points = cmpXML.search("MineralSoil/Rating")
          if s_points == [] then #Organic soil
            s_points = cmpXML.search("OrganicSoil/Rating").first.content.to_i.to_s
            s_class = cmpXML.search("OrganicSoil/Class").first.content
          else #Mineral soil
            s_points = cmpXML.search("MineralSoil/Rating").first.content.to_i.to_s
            s_class = cmpXML.search("MineralSoil/Class").first.content
          end
          cmp_class = [c_class,l_class,s_class].max
          outputCsvFile.puts "#{poly_id},#{cmp_id},#{poly_rating},#{cmp},#{percent},#{cmp_class},#{c_points},#{c_class},#{province},#{soil_codemodpro},#{soil_name},#{s_points},#{s_class},#{l_points},#{l_class}"
					records.push({:POLY_ID=>poly_id, :CMP_ID=>cmp_id, :POLY_RATIN=>poly_rating, :CMP=>cmp, :PERCENT=>percent, :CMP_CLASS=>cmp_class.to_i, :C_POINTS=>c_points, :C_CLASS=>c_class.to_i, :PROVINCE=>province, :SOIL_CODE=>soil_codemodpro, :SOIL_NAME=>soil_name, :S_POINTS=>s_points, :S_CLASS=>s_class.to_i, :L_POINTS=>l_points, :L_CLASS=>l_class.to_i})
        end
      else  #must be an error response
        outputXmlFile.puts "<Row>"
        outputXmlFile.puts "  <K>" + poly.to_s + "</K>"
        outputXmlFile.puts "  <V>Error</V>"
        outputXmlFile.puts "</Row>"
      end
#      outputXmlFile << open(lsrsURL).read()
      #update the status file regularly
      if i % 30 == 0
        percentComplete = ( (i + 1)/ @slArray.size.to_f * 100 ).round(2)
        xml = Wps.CreateStatusXml(@statusURL, @outputURL, @cmpTable, @fromPoly, @toPoly, @crop, @management, @climateTableName, "ProcessStarted", percentComplete)
        # store status document as file
        statusFile = File.open(@statusFilename, 'w')
        statusFile << xml.target!
        statusFile.close
      end
    end
    LSRS_GDAS.bottom(outputXmlFile)
    # close the output XML file
    outputXmlFile.close
    
    # close the output CSV file
    outputCsvFile.close

    # populate and close the output DBF file
    require 'dbf'
		require "#{@control['RailsRoot']}/app/helpers/dbf-helper"
		dbf_writer(outputDbfFilename, fields, records)

    # close the output HTML file
    outputHtmlFile.puts "</table>"
    outputHtmlFile.puts "</body>"
    outputHtmlFile.puts "</html>"
    outputHtmlFile.close


    # create the summary dbf file
    gdas = open(outputXmlFilename).read().to_libxml_doc.root
    require "#{@control['RailsRoot']}/app/models/ogc/gdas2dbf"
    GDAS2DBF.convert(gdas, outputDbfSummaryFilename, @control['RailsRoot'])
    
    # update status file
    xml = Wps.CreateStatusXml(@statusURL, @outputURL, @cmpTable, @fromPoly, @toPoly, @crop, @management, @climateTableName, "ProcessSucceeded", 100)
    # store status document as file
    statusFile = File.open(@statusFilename, 'w')
    statusFile << xml.target!
    statusFile.close
     
    # delete control file
#    FileUtils.rm(@baseDir + "processing/" + nextJob)
    FileUtils.mv(@controlFilename, @baseDir + "results/" + nextJob[0..19] + "/control.yml")
    log.puts(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") + " processing complete for " + nextJob)
  else
#    log.puts(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") + " a job is already processing")
  end
else
#  log.puts(Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") + " no pending jobs")
end
