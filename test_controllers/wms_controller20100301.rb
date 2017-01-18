class WmsController < ApplicationController
    class LegendRanger
      attr_accessor  :Identifier, :Title, :Color
    end

  def create
    # standardize request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "COVERAGE"
          @coverage = value
        when "TMPDIR"  
          @tmpDirName = value
      end # case
    end # params

    # validate request parameters are present
    if !(defined? @coverage) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "Coverage"; render :action => 'Error_response', :layout => false and return and exit 1 end
    if !(defined? @tmpDirName) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "TmpDir"; render :action => 'Error_response', :layout => false and return and exit 1 end
# TEMPORARILY force values of parameters
#coverage = "okanagan"
#tmpDirName = "20100122t163103r4600"
    # Assign parameter values
    @getDataURL = "http://lsrs.gis.agr.gc.ca/batch/results/" + @tmpDirName + "/output.xml"
    if @coverage == "Okanagan" then 
      @rootName = "bc_okanagan_soil_v2x0"
      @coverageDir = "/usr/local/httpd/mapdata/bc/okanagan/soil/v2x0/"
    end

    # CREATE DIRECTORIES
    # MapDir and HtmDir are the same, but cgi is different
    tmpMapDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpHtmDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpCgiDir = "/usr/local/httpd/lsrs/cgi-bin/" + @tmpDirName
    # create CGI-BIN directory because it won't yet exist
    Dir.mkdir(tmpCgiDir)

    # CREATE SHAPEFILE
    require 'dbf'
    require "#{Rails.root.to_s}/app/helpers/dbf-helper"
    # load the original PAT file
    @originalPAT = DBF::Table.new(@coverageDir + @rootName + ".dbf")
    # prepare the fields array, which defines the structure of the new PAT file
    fields = Array.new
    for column in @originalPAT.columns do
      case column.type
        when "C" then columnType = "C"
        when "F" then columnType = "N"
        when "N" then columnType = "N"
      end
      fields.push({:field_name=>column.name, :field_size=>column.length, :field_type=>columnType, :decimals=>column.decimal})
    end
    # add the fields to be joined
    fields.push({:field_name=>"LSRSRATING", :field_size=>30, :field_type=>"C", :decimals=>0})
    fields.push({:field_name=>"LSRSCLASS", :field_size=>1, :field_type=>"C", :decimals=>0})
    # load ratings from GDAS XML file
    require "#{Rails.root.to_s}/app/helpers/libxml-helper"
    require "open-uri"
    @gdas = open(@getDataURL).read().to_libxml_doc.root
    @gdas.register_default_namespace("tjs")
    rowsXmlArray = @gdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row")
    # create hash containing the data to be joined
    @keyvalues = Hash.new
    rowsXmlArray.each do |i|
      i.register_default_namespace("tjs")
      @keyvalues[i.search("tjs:K").to_a.first.content]=i.search("tjs:V").to_a.first.content
    end  
    # populate the records array from data in the original PAT and MySQL
    records = Array.new 
    for poly in Bc_okanagan_soil_v2x0.find(:all)
      row = Hash.new
      for field in fields # populate the row with the original PAT
        row[field[:field_name].to_sym] = poly[field[:field_name].downcase]  
      end
      puts poly.id
      row[:LSRSRATING] = @keyvalues[row[:FEATURE_ID].to_f.to_i.to_s]
      if row[:LSRSRATING] != nil then row[:LSRSCLASS] = row[:LSRSRATING][0,1] end
      records.push row # add the completed hash to the records array
    end
    # write out dbase file
    patfilename = "#{tmpMapDir}/#{@rootName}.dbf"
    dbf_writer(patfilename, fields, records)
    # create the rest of the shapefile as links
    `ln -s #{@coverageDir}#{@rootName}.sbn #{tmpMapDir}/#{@rootName}.sbn`
    `ln -s #{@coverageDir}#{@rootName}.sbx #{tmpMapDir}/#{@rootName}.sbx`
    `ln -s #{@coverageDir}#{@rootName}.shp #{tmpMapDir}/#{@rootName}.shp`
    `ln -s #{@coverageDir}#{@rootName}.shx #{tmpMapDir}/#{@rootName}.shx`
    `ln -s #{@coverageDir}#{@rootName}.qix #{tmpMapDir}/#{@rootName}.qix`

    # CREATE MAPFILE
    # get framework info
    @framework = Gframework.find(:all, :conditions => {:ShapeName => @coverage})[0]
    # get legend info
    @legendURL = "http://lsrs.gis.agr.gc.ca/legends/lsrs02.xml"
    @legend = open(@legendURL).read().to_libxml_doc.root
    classesXmlArray = @legend.search("//Legend/Classes/Class")
    # create array containing the legend info
    classificationArray = Array.new
    classesXmlArray.each do |i|
      range = LegendRanger.new
      range.Identifier = i.search("Identifier").to_a.first.content
      range.Title = i.search("Title").to_a.first.content
      range.Color = i.search("@color").first.value
      classificationArray.push range
    end
    # create .map file
    mf = File.open("#{tmpMapDir}/mapfile.map","w")
    mf.puts 'MAP'
    mf.puts '  NAME ' + "test"
    mf.puts '  STATUS ON'
    mf.puts '  SIZE 600 420'
    mf.puts '  EXTENT  ' + "#{@framework.West} #{@framework.South} #{@framework.East} #{@framework.North}"
    mf.puts '  UNITS meters'
    mf.puts '  SHAPEPATH "' + "#{tmpMapDir}" + '"'
    mf.puts '  IMAGECOLOR 255 255 255'
    mf.puts '  PROJECTION'
    mf.puts '   "proj=utm"'
    mf.puts '   "ellps=GRS80"'
    mf.puts '   "datum=NAD83"'
    mf.puts '   "zone=11"'
    mf.puts '   "units=m"'
    mf.puts '   "north"'
    mf.puts '   "no_defs"'
    mf.puts '  END'
    mf.puts ''
    mf.puts '  WEB'
    mf.puts '    IMAGEPATH "' + "#{tmpHtmDir}" + '/"'
    mf.puts '    IMAGEURL "/tmp/' + "#{@tmpDirName}" + '/"'
    mf.puts '    MAXSCALE 60000000'
    mf.puts '    METADATA'
    mf.puts '      "wms_title" "'  + "#{@tmpDirName}" + '"'
    mf.puts '      "wms_onlineresource" "http://localhost/cgi-bin/#{@tmpDirName}/wms?" '
    mf.puts '      "wms_abstract" "These data were derived from: RURAL MUNICIPALITY OF PINEY-RMSID, MB.  The boundaries were designed for use at a scale of 1:100000." '
    mf.puts '      "wms_srs" "EPSG:42304 EPSG:42101 EPSG:4269 EPSG:4326 EPSG:4267"'
    mf.puts '      "wms_accesscontraints" "none"'
    mf.puts '      "wms_addresstype" "postal"'
    mf.puts '      "wms_address" "960 Carling Ave."'
    mf.puts '      "wms_city" "Ottawa"'
    mf.puts '      "wms_stateorprovince" "Ontario"'
    mf.puts '      "wms_postcode" "K1A 0C6"'
    mf.puts '      "wms_country" "Canada"'
    mf.puts '      "wms_contactelectronicmailaddress" "schutp@agr.gc.ca"'
    mf.puts '      "wms_contactfacsimiletelephone" "613-759-1937"'
    mf.puts '      "wms_contactperson" "Peter Schut"'
    mf.puts '      "wms_contactorganization" "Agriculture and Agri-Food Canada"'
    mf.puts '      "wms_contactposition" "Head, CanSIS"'
    mf.puts '      "wms_fees" "none"'
    mf.puts '      "wms_keywordlist" "soil, soil survey, slope, stoniness, kind of surface material, drainage, mode of deposition (uppermost)"'
    mf.puts '    END'
    mf.puts '  END'
    mf.puts ''
    mf.puts '  LAYER'
    mf.puts '    NAME "' + "#{@rootName}" + '"'
    mf.puts '    TYPE Polygon'
    mf.puts '    STATUS DEFAULT'
    mf.puts '    DATA ' + "#{@rootName}"
    mf.puts '    DUMP TRUE'
    mf.puts '    CLASSITEM "LSRSCLASS"'
    classificationArray.each do |range|
      mf.puts '     CLASS'
      mf.puts '        EXPRESSION "' + "#{range.Identifier}" + '"'
      mf.puts '        NAME "' + "#{range.Title}" + '"'
      r = Integer("0x" + range.Color[0..1])
      g = Integer("0x" + range.Color[2..3])
      b = Integer("0x" + range.Color[4..5])
      mf.puts '        COLOR ' + "#{r} #{g} #{b}"
      mf.puts '      END'
    end
    mf.puts '      TOLERANCE 3'
    mf.puts '      PROJECTION'
    mf.puts '     "proj=latlong"'
    mf.puts '      END'
    mf.puts '      METADATA'
    mf.puts '        "wms_title" "LSRS Rating"'
    mf.puts '        "wms_srs"   "latlong"'
    mf.puts '        "wms_abstract" "May include ocean."  '  
    mf.puts '        "wms_extent" "EXTENT_VALUES"'
    mf.puts '        "wms_opaque" "1"'
    mf.puts '      END'
    mf.puts '    END'
    mf.puts '  END'
    mf.puts 'END  # MAP'
    mf.close

    # CREATE CGI FILE
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

    # create html file that starts OpenLayers client and displays a layer
    ht = File.open("#{tmpHtmDir}/mapclient.html","w") 
    ht.puts '<html xmlns="http://www.w3.org/1999/xhtml">'
    ht.puts '  <head>'
    ht.puts '    <style type="text/css">'
    ht.puts '        #map {'
    ht.puts '            width: 100%;'
    ht.puts '            height: 100%;'
    ht.puts '            border: 1px solid black;'
    ht.puts '        }'
    ht.puts '    </style>'
    ht.puts '    <script src="http://www.openlayers.org/api/OpenLayers.js"></script>'
    ht.puts '    <script type="text/javascript">'
    ht.puts '        var map;'
    ht.puts '        function init(){'
    ht.puts "            map = new OpenLayers.Map('map');"
    ht.puts ' '
    ht.puts '            //map.addControl(new OpenLayers.Control.PanZoomBar({zoomWorldIcon:true}));'
    ht.puts "            map.addControl(new OpenLayers.Control.LayerSwitcher({'ascending':false}));"
    ht.puts '            map.addControl(new OpenLayers.Control.Permalink());'
    ht.puts "            map.addControl(new OpenLayers.Control.Permalink('permalink'));"
    ht.puts '            map.addControl(new OpenLayers.Control.MousePosition());'
    ht.puts '            map.addControl(new OpenLayers.Control.OverviewMap());'
    ht.puts '            map.addControl(new OpenLayers.Control.KeyboardDefaults());'
    ht.puts ''
    ht.puts "             var theme = new OpenLayers.Layer.WMS( 'Kind of Material <a href=http://sis.agr.gc.ca/cansis>test</a>',"
    ht.puts '                "http://lsrs.gis.agr.gc.ca/cgi-bin/' + @tmpDirName + '/wms", '
    ht.puts '                {layers: "' + @rootName + '"});'
    ht.puts ' '
    ht.puts '            map.addLayers([theme]);'
    ht.puts ' '
    ht.puts '            map.setCenter(new OpenLayers.LonLat(-119, 50), 9);'
    ht.puts '            //map.zoomToMaxExtent();'
    ht.puts '        }'
    ht.puts '    </script>'
    ht.puts '  </head>'
    ht.puts '  <body onload="init()">'
    ht.puts '    <div id="map"></div>'
    ht.puts ' '
    ht.puts '  </body>'
    ht.puts '</html>'
    ht.close

    # render output and close
    render :file => (tmpHtmDir + "/mapclient.html"), :content_type => "text/html", :layout => false and return and exit 1
  end
  
  def remove
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "COVERAGE"
          @coverage = value
        when "TMPDIR"  
          @tmpDirName = value
      end # case
    end # params

    if @coverage == "Okanagan" then 
      @rootName = "bc_okanagan_soil_v2x0"
    end

    # MapDir and HtmDir are the same, but 
    tmpMapDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpHtmDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpCgiDir = "/usr/local/httpd/lsrs/cgi-bin/" + @tmpDirName

    File.delete(tmpCgiDir + "/wms")
    Dir.delete(tmpCgiDir)

    File.delete(tmpMapDir + "/mapclient.html")
    File.delete(tmpMapDir + "/mapfile.map")
    File.delete(tmpMapDir + "/" + @rootName + ".dbf")
    File.delete(tmpMapDir + "/" + @rootName + ".sbn")
    File.delete(tmpMapDir + "/" + @rootName + ".sbx")
    File.delete(tmpMapDir + "/" + @rootName + ".shp")
    File.delete(tmpMapDir + "/" + @rootName + ".shx")
    File.delete(tmpMapDir + "/" + @rootName + ".qix")
  end

end
