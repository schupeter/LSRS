module Wms_create
  def Wms_create.Directories
		require 'directoryClass'
		directory = Directory.new
    # determine temporary directory names
    tmpDirString = DateTime::now.to_s[0,19].delete("-T:") + rand.to_s[2,4]
    tmpDirLevel2Name = tmpDirString[0,10]
    tmpDirLevel3Name = tmpDirString[10,8]
    directory.tmpDirName = "#{tmpDirLevel2Name}/#{tmpDirLevel3Name}"
    # create temporary MAPDATA and MAPFILE directory
    tmpMapDirRoot = "#{Rails.root.to_s}/tmp/mapdata"
    Dir.mkdir("#{tmpMapDirRoot}/#{tmpDirLevel2Name}") unless File::directory?("#{tmpMapDirRoot}/#{tmpDirLevel2Name}")
    directory.tmpMapDir = "#{tmpMapDirRoot}/#{tmpDirLevel2Name}/#{tmpDirLevel3Name}"
    Dir.mkdir(directory.tmpMapDir)
    # create temporary CGI-BIN directory
    tmpCgiDirRoot = "#{Rails.root.to_s}/cgi-bin"
    Dir.mkdir("#{tmpCgiDirRoot}/#{tmpDirLevel2Name}") unless File::directory?("#{tmpCgiDirRoot}/#{tmpDirLevel2Name}")
    directory.tmpCgiDir = "#{tmpCgiDirRoot}/#{tmpDirLevel2Name}/#{tmpDirLevel3Name}"
    Dir.mkdir(directory.tmpCgiDir)
		# create temporary HTML directory
    tmpHtmDirRoot = "#{Rails.root.to_s}/public/tmp"
    Dir.mkdir("#{tmpHtmDirRoot}/#{tmpDirLevel2Name}") unless File::directory?("#{tmpHtmDirRoot}/#{tmpDirLevel2Name}")
    directory.tmpHtmDir = "#{tmpHtmDirRoot}/#{tmpDirLevel2Name}/#{tmpDirLevel3Name}"
    Dir.mkdir(directory.tmpHtmDir)
		return directory
	end

  def Wms_create.Shapefile(xgdas, xwarehouseName, xoriginalPAT, xall_frameworks, tmpMapDir)
    require "#{Rails.root.to_s}/app/helpers/dbf-helper"

    # load the original PAT file
    table = DBF::Table.new('/production/data//bc/okanagan/soil/v2x0/bc_okanagan_soil_v2x0.dbf')

    # prepare the fields array, which defines the structure of the new PAT file
    fields = Array.new
    for column in table.columns do
      fields.push({:field_name=>column.name, :field_size=>column.length, :field_type=>column.type, :decimals=>column.decimal})
    end
    # add the field to be joined
    fields.push({:field_name=>"LSRSCLASS", :field_size=>1, :field_type=>"C", :decimals=>0})
    fields.push({:field_name=>"LSRSRATING", :field_size=>30, :field_type=>"C", :decimals=>0})

    # create data array containing the Join Table
    @keyvalues = Hash.new
    data = xgdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row").to_a
    data.each do |i|
      i.register_default_namespace("tjs")
      k = i.search("tjs:K").to_a.first.content
      v = i.search("tjs:V").to_a.first.content
      @keyvalues[k]=v
    end

    # create an array with the PAT field names, for controlling iteration
    @patFields = Array.new
    for column in table.columns
     @patFields.push column.name
    end

    # populate the records array from data in the original PAT and the new Join Table
    records = Array.new 
    rownum = 0
    for poly in xoriginalPAT
      row = Hash.new
      for field in @patFields # populate the row with the original PAT
        row[field.upcase.to_sym] = eval("poly.#{field}")  
      end
      key = row[xall_frameworks[0]["FrameworkKey"].upcase.to_sym] # determine the value of the relate key to use
      row[:LSRSRATING] = @keyvalues[key.to_s] # add the data from the Join Table
      records[rownum] = row # add the completed hash to the records array
      rownum += 1
    end

    # POPULATE tmpMapDir
    # write out dbase file
    patfilename = "#{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.dbf"
    dbf_writer(patfilename, fields, records)
=begin
		xx = xall_frameworks[0]['ShapeDir'].split("_")
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.sbn #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.sbn`
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.sbx #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.sbx`
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.shp #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.shp`
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.shx #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.shx`
		return @attributesArray
=end
	end

  def Wms_create.Shapefile_original(attributeHash, rowsXmlArray, xwarehouseName, xoriginalPAT, xall_frameworks, tmpMapDir, classificationArray, exceptionsArray)
    require "#{Rails.root.to_s}/app/helpers/dbf-helper"

		# determine dbase types - ADD ALL TYPES FROM SCHEMA!!!!!!!!!!
		if attributeHash['Description'].Type == "string"
			dbaseType = "C" 
			decimals = 0
		end
		if attributeHash['Description'].Type == "float"
			dbaseType = "N"
			decimals = attributeHash['Description'].Decimals
		end
		if attributeHash['Description'].Type == "integer"
			 dbaseType = "N"
			 decimals = 0
		end
		if attributeHash['Description'].Type == "decimal"
			 dbaseType = "N"
			 decimals = attributeHash['Description'].Decimals
		end
			 
    # populate the fields array with all PAT records
    @patDatabase = eval("#{xwarehouseName}.columns")
    fields = Array.new
    for column in @patDatabase
      if column.sql_type == "float"
        fields.push({:field_name=>column.name.upcase, :field_size=>18, :field_type=>'N', :decimals=>5})
      end
      if column.sql_type == "int(11)"
        fields.push({:field_name=>column.name.upcase, :field_size=>11, :field_type=>'N', :decimals=>0})
      end
      if column.sql_type[0...7] == "varchar"
        fields.push({:field_name=>column.name.upcase, :field_size=>column.limit, :field_type=>'C', :decimals=>0})
      end
    end
    # add the raw data field to be joined
    fields.push({:field_name=>attributeHash['Description'].AttributeName.upcase, :field_size=>attributeHash['Description'].Length, :field_type=>dbaseType, :decimals=>attributeHash['Description'].Decimals})
    # add the classification field to be joined 
		if classificationArray != "n/a" #NEW
			fields.push({:field_name=>"CLASSIF_ID", :field_size=>2, :field_type=>'C', :decimals=>0}) #NEW
		end #NEW

    # create hash containing the data to be joined
    @keyvalues = Hash.new
		if dbaseType == "C"
			rowsXmlArray.each do |i|
				i.register_default_namespace("tjs")
				@keyvalues[i.search("tjs:K").to_a.first.content]=i.search("tjs:V").to_a.first.content
			end  
		elsif dbaseType == "N"
			rowsXmlArray.each do |i|
				i.register_default_namespace("tjs")
				@keyvalues[i.search("tjs:K").to_a.first.content]=i.search("tjs:V").to_a.first.content.to_f
			end  
		end

    # create an array with the PAT field names, for controlling iteration
    @patFields = Array.new
    for column in @patDatabase
     @patFields.push column.name
		end

		# NEW create exceptionValuesArray to simplify determination of membership
		exceptionValuesArray = Array.new #NEW
		if exceptionsArray != "n/a" #NEW
			exceptionsArray.each {|x| exceptionValuesArray.push x.OriginalValue} # NEW
		end # NEW

    # populate the records array from data in the original PAT and the data hash
    records = Array.new 
    rownum = 0
    for poly in xoriginalPAT
      row = Hash.new
      for field in @patFields # populate the row with the original PAT
        row[field.upcase.to_sym] = eval("poly.#{field}")  
      end
      key = row[xall_frameworks[0]["FrameworkKey"].upcase.to_sym] # determine the value of the relate key to use
      row[attributeHash['Description'].AttributeName.upcase.to_sym] = @keyvalues[key.to_s] # add the value for this key from the data hash
			if classificationArray != "n/a" #NEW
				row[:CLASSIF_ID] = Classify.numeric(@keyvalues[key.to_s], classificationArray, exceptionsArray, exceptionValuesArray) #NEW add the classification code from the classificationURI 
			end #NEW
      records[rownum] = row # add the completed hash to the records array
      rownum += 1
    end

    # POPULATE tmpMapDir
    # write out dbase file
    patfilename = "#{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.dbf"
    dbf_writer(patfilename, fields, records)
		xx = xall_frameworks[0]['ShapeDir'].split("_")
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.sbn #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.sbn`
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.sbx #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.sbx`
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.shp #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.shp`
    `ln -s /usr/local/httpd/mapdata/#{xx[0]}/#{xx[1]}/#{xx[2]}/#{xx[3]}/#{xall_frameworks[0]['ShapeName']}.shx #{tmpMapDir}/#{xall_frameworks[0]['ShapeName']}.shx`
	end

  def Wms_create.MapFile(tmpMapDir, tmpHtmDir, tmpDirName, xall_frameworks, xattributesArray, xstyling, xclassificationArray, xexceptionsArray)
    # create .map file
    mf = File.open("#{tmpMapDir}/mapfile.map","w")
#    mf.puts 'NAME ' + "#{xall_frameworks[0]['Subject'].upcase}" # removed because it failed to find Subject
    mf.puts 'MAP'
    mf.puts '  NAME ' + "#{xall_frameworks[0]['ShapeDir'].upcase}"
    mf.puts '  STATUS ON'
    mf.puts '  SIZE 600 420'
    mf.puts '  EXTENT  ' + "#{xall_frameworks[0]['MinLong']} #{xall_frameworks[0]['MinLat']} #{xall_frameworks[0]['MaxLong']} #{xall_frameworks[0]['MaxLat']}"
    mf.puts '  UNITS dd'
    mf.puts '  SHAPEPATH "' + "#{tmpMapDir}" + '"'
    mf.puts '  IMAGECOLOR 255 255 255'
    mf.puts '  PROJECTION'
    mf.puts '   "proj=latlong"'
    mf.puts '  END'
    mf.puts ''
    mf.puts '  WEB'
    mf.puts '    IMAGEPATH "' + "#{tmpHtmDir}" + '/"'
    mf.puts '    IMAGEURL "/tmp/' + "#{tmpDirName}" + '/"'
    mf.puts '    MAXSCALE 60000000'
    mf.puts '    METADATA'
    mf.puts '      "wms_title" "'  + "#{xall_frameworks[0]['Title_en']}" + '"'
    mf.puts '      "wms_onlineresource" "http://localhost/cgi-bin/#{tmpDirName}/wms?" '
    mf.puts '      "wms_abstract" "These data were derived from: ....  The boundaries were designed for use at a scale of ...." '
    mf.puts '      "wms_srs" "EPSG:42304 EPSG:42101 EPSG:4269 EPSG:4326 EPSG:4267"'
    mf.puts '      "wms_accesscontraints" "none"'
    mf.puts '      "wms_addresstype" "postal"'
    mf.puts '      "wms_address" "960 Carling Ave."'
    mf.puts '      "wms_city" "Ottawa"'
    mf.puts '      "wms_stateorprovince" "Ontario"'
    mf.puts '      "wms_postcode" "K1A 0C6"'
    mf.puts '      "wms_country" "Canada"'
    mf.puts '      "wms_contactelectronicmailaddress" "peter.schut@agr.gc.ca"'
    mf.puts '      "wms_contactfacsimiletelephone" "613-759-1937"'
    mf.puts '      "wms_contactperson" "Peter Schut"'
    mf.puts '      "wms_contactorganization" "Agriculture and Agri-Food Canada"'
    mf.puts '      "wms_contactposition" "Head, CanSIS"'
    mf.puts '      "wms_fees" "none"'
    mf.puts '      "wms_keywordlist" "soil, soil survey, lsrs"'
    mf.puts '      "wms_feature_info_mime_type" "text/html"'
    mf.puts '    END'
    mf.puts '  END'
    mf.puts ''
    mf.puts '  LAYER'
#    mf.puts '  NAME "' + "#{xall_frameworks[0]['Subject'].upcase}" + '"'
    mf.puts '    NAME "' + "#{xall_frameworks[0]['ShapeName'].downcase}" + '"'
    mf.puts '    TYPE Polygon'
    mf.puts '    STATUS DEFAULT'
    mf.puts '    DATA ' + "#{xall_frameworks[0]['ShapeName']}"
    mf.puts '    TEMPLATE "getfeatureinfo.html"'
#    mf.puts '    DUMP TRUE'
    #mf.puts '  CLASSITEM "' + "#{xall_frameworks[0]['FrameworkKey'].upcase}" + '"'
    #mf.puts '  CLASSITEM "' + "#{xattributesArray[0].AttributeName.upcase}" + '"'
    mf.puts '    CLASSITEM "' + "CLASSIF_ID" + '"'
=begin		if xstyling.class == String then
			data = xstyling.search("//Palette/ColorSet/Color").to_a
			data.each do |i|
				mf.puts '   CLASS'
				e = i.search("@id").first.content
				mf.puts '      EXPRESSION "' + "#{e}" + '"'
				mf.puts '      NAME "' + "#{e}" + '"'
				color = i.content
				r = Integer("0x" + color[0..1])
				g = Integer("0x" + color[2..3])
				b = Integer("0x" + color[4..5])
				mf.puts '      COLOR ' + "#{r} #{g} #{b}"
				mf.puts '    END'
			end
=end			
		if xclassificationArray.size > 0 then
			xclassificationArray.each do |range|
				mf.puts '     CLASS'
				mf.puts '        EXPRESSION "' + "#{range.Identifier}" + '"'
				mf.puts '        NAME "' + "#{range.Title}" + '"'
				r = Integer("0x" + range.Color[0..1])
				g = Integer("0x" + range.Color[2..3])
				b = Integer("0x" + range.Color[4..5])
				mf.puts '        COLOR ' + "#{r} #{g} #{b}"
				mf.puts '      END'
			end
		end
		
    mf.puts '      TOLERANCE 3'
    mf.puts '      PROJECTION'
    mf.puts '     "proj=latlong"'
    mf.puts '      END'
    mf.puts '      METADATA'
    mf.puts '        "wms_title" "' + "#{xall_frameworks[0]['Subject']}" + '"'
    mf.puts '        "wms_srs"   "latlong"'
    mf.puts '        "wms_abstract" "May include ocean."  '  
    mf.puts '        "wms_extent" "EXTENT_VALUES"'
    mf.puts '        "wms_opaque" "1"'
    mf.puts '      END'
    mf.puts '    END'
		mf.puts '  END'
    mf.puts 'END  # MAPFILE'
    mf.close
	end

  def Wms_create.TemplateFile(tmpMapDir)
    # create mapserver template file for WMS GetFeatureInfo requests
    qf = File.open("#{tmpMapDir}/getfeatureinfo.html","w")
    qf.puts '<!-- Mapserver Template -->'
    qf.puts '<html>'
    qf.puts '<body>'
    qf.puts '<h1>test</h1>'
    qf.puts '<ul>'
    qf.puts '<li>SLC: [SLC]</li>'
    qf.puts '<li>LSRSRATING: [LSRSRATING]</li>'
    qf.puts '<li>FEATURE_ID: [FEATURE_ID]</li>'
    qf.puts '</ul>'
    qf.puts '<a href="http://'+request.host+'/lsrs/service?ClimateTable=Ca_all_slc_v3x0_climate1961x90&CmpTable=Bc_okanagan_soil_v2x0_cmp&PolyId=[FEATURE_ID]&CROP=sssgrain&RESPONSE=Details">LSRS rating calculation</a>'
    qf.puts '<html>'
    qf.close
	end

  def Wms_create.MapservScript(tmpCgiDir, tmpMapDir)
    # POPULATE tmpCgiDir
    # create cgi-bin mapserv script
    ms = File.open("#{tmpCgiDir}/wms","w") 
    ms.puts '#!/bin/bash'
    ms.puts 'MAPSERV="/usr/lib/cgi-bin/mapserv"'
    ms.puts 'MAPFILE="' + "#{tmpMapDir}" + '/mapfile.map"'
    ms.puts 'if [ "${REQUEST_METHOD}" != "GET" ]; then'
    ms.puts '  echo "Content-type: text/html"'
    ms.puts '  echo ""'
    ms.puts '  echo ""'
    ms.puts '  echo "Sorry, I only understand GET requests."'
    ms.puts '  exit'
    ms.puts 'fi'
    ms.puts 'if [ -z ${QUERY_STRING} ] ; then'
    ms.puts '  QUERY_STRING="map=${MAPFILE}"'
    ms.puts 'else'
    ms.puts '  QUERY_STRING="map=${MAPFILE}&${QUERY_STRING}"'
    ms.puts 'fi'
    ms.puts 'exec ${MAPSERV}'
    ms.puts 'exit'
    ms.close
    `chmod 755 #{tmpCgiDir}/wms`
	end


end