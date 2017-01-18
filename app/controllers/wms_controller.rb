class WmsController < ApplicationController
    class LegendRanger
      attr_accessor  :Identifier, :Title, :Color
    end

  def create
    # standardize request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
          @frameworkName = value
        when "TMPDIR"  
          @tmpDirName = value
      end # case
    end # params

    # validate request parameters are present
    if !(defined? @frameworkName) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "FrameworkName"; render :action => 'Error_response', :layout => false and return and exit 1 end
    if !(defined? @tmpDirName) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "TmpDir"; render :action => 'Error_response', :layout => false and return and exit 1 end
# TEMPORARILY force values of parameters
#coverage = "okanagan"
#tmpDirName = "20100122t163103r4600"
    # Assign parameter values
    @getDataURL = "http://#{request.host}/batch/results/" + @tmpDirName + "/output.xml"
#    if @frameworkName == "Okanagan" then 
#      @frameworkName = "bc_okanagan_soil_v2x0"
#      @coverageDir = "/usr/local/httpd/mapdata/bc/okanagan/soil/v2x0/"
#    end
    @coverageDir = "/usr/local/httpd/mapdata/" + @frameworkName.gsub("_","/") + "/"
    @jobHash = YAML.load_file("/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName + "/control.yml")

    # CREATE DIRECTORIES
    # MapDir and HtmDir are the same, but cgi is different
    tmpMapDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpHtmDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpCgiDir = "/usr/local/httpd/lsrs/cgi-bin/" + @tmpDirName
    wmsURL = "http://#{request.host}/cgi-bin/" + @tmpDirName + "/wms"
    # create CGI-BIN directory because it won't yet exist
    Dir.mkdir(tmpCgiDir)

    # CREATE SHAPEFILE
    require 'dbf'
    require "#{Rails.root.to_s}/app/helpers/dbf-helper"
    # load the original PAT file
    @originalPAT = DBF::Table.new(@coverageDir + @frameworkName + ".dbf")
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
    fields.push({:field_name=>"QUERYPOLY", :field_size=>10, :field_type=>"C", :decimals=>0})
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
    for poly in Bc_okanagan_soil_v2x0.all  ##########FIX THIS HARDCODING#########
      row = Hash.new
      for field in fields # populate the row with the original PAT
        row[field[:field_name].to_sym] = poly[field[:field_name].downcase]  
      end
      puts poly.id
      row[:LSRSRATING] = @keyvalues[row[:FEATURE_ID].to_f.to_i.to_s]
      if row[:LSRSRATING] != nil then row[:LSRSCLASS] = row[:LSRSRATING][0,1] end
      row[:QUERYPOLY] = row[:FEATURE_ID].to_f.to_i.to_s
      records.push row # add the completed hash to the records array
    end
    # write out dbase file
    patfilename = "#{tmpMapDir}/#{@frameworkName}.dbf"
    dbf_writer(patfilename, fields, records)
    # create the rest of the shapefile as links
    `ln -s #{@coverageDir}#{@frameworkName}.sbn #{tmpMapDir}/#{@frameworkName}.sbn`
    `ln -s #{@coverageDir}#{@frameworkName}.sbx #{tmpMapDir}/#{@frameworkName}.sbx`
    `ln -s #{@coverageDir}#{@frameworkName}.shp #{tmpMapDir}/#{@frameworkName}.shp`
    `ln -s #{@coverageDir}#{@frameworkName}.shx #{tmpMapDir}/#{@frameworkName}.shx`
    `ln -s #{@coverageDir}#{@frameworkName}.qix #{tmpMapDir}/#{@frameworkName}.qix`

    # CREATE MAPFILE
    # get framework info
    @framework = LsrsFramework.where(:FrameworkName => @frameworkName).first
    # get legend info
    @legendURL = "http://#{request.host}/schemas/legend/1.0/examples/lsrs02.xml"
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
    mf.puts '  SHAPEPATH "' + tmpMapDir + '"'
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
    mf.puts '    IMAGEPATH "' + tmpHtmDir + '/"'
    mf.puts '    IMAGEURL "/tmp/' + @tmpDirName + '/"'
    mf.puts '    MAXSCALE 60000000'
    mf.puts '    METADATA'
    mf.puts '      "wms_title" "'  + @tmpDirName + '"'
    mf.puts '      "wms_onlineresource" "http://localhost/cgi-bin/#{@tmpDirName}/wms?" '
    mf.puts '      "wms_abstract" "These data were derived from....  The boundaries were designed for use at a scale of ...." '
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
    mf.puts '    NAME "' + @frameworkName + '"'
    mf.puts '    TYPE Polygon'
    mf.puts '    STATUS DEFAULT'
    mf.puts '    DATA ' + @frameworkName
    mf.puts '    TEMPLATE "getfeatureinfo.html"'
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
    mf.puts '        "wms_abstract" "LSRS ratings."  '  
    mf.puts '        "wms_extent" "EXTENT_VALUES"'
    mf.puts '        "wms_opaque" "1"'
    mf.puts '        "ows_include_items" "all"'
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
    ms.puts 'MAPFILE="' + tmpMapDir + '/mapfile.map"'
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
    ht.puts ' <head>'
    ht.puts '  <title>LSRS ' + @framework.Title_en + '</title>'
    ht.puts '   <script src="/ext-2.3.0/adapter/ext/ext-base.js" type="text/javascript"></script>'
    ht.puts '   <script src="/ext-2.3.0/ext-all.js"  type="text/javascript"></script>'
    ht.puts '   <link rel="stylesheet" type="text/css" href="/ext-2.3.0/resources/css/ext-all.css"></link>'
    ht.puts '   <script src="/OpenLayers-2.8/OpenLayers.js" type="text/javascript"></script>'
    ht.puts '   <script src="/GeoExt/script/GeoExt.js" type="text/javascript"></script>'
    ht.puts '   <link rel="stylesheet" type="text/css" href="/GeoExt/resources/css/geoext-all.css"></link>'
    ht.puts '   <script type="text/javascript">'
    ht.puts "    "
    ht.puts '         Ext.onReady(function() {'
    ht.puts '           var map = new OpenLayers.Map();'
    ht.puts '           var lsrs = new OpenLayers.Layer.WMS( "LSRS Rating",'
    ht.puts '             "' + wmsURL + '", '
#    ht.puts '             {layers: "bc_okanagan_soil_v2x0"'  # FIX THIS
    ht.puts '             {layers: "' + @frameworkName + '"'
    ht.puts '             },{'
    ht.puts '             displayInLayerSwitcher: true'
    ht.puts '             });'
    ht.puts '           map.addLayer(lsrs);'
    ht.puts '           var hydro = new OpenLayers.Layer.WMS( "Hydro", "http://wms.ess-ws.nrcan.gc.ca/wms/toporama_en",  {transparent: "true", layers: "hydrography"},{displayInLayerSwitcher: true});'
    ht.puts '           map.addLayer(hydro);'
    ht.puts '           map.addControl(new OpenLayers.Control.Permalink());'
    ht.puts '           map.addControl(new OpenLayers.Control.Permalink("permalink"));'
    ht.puts '           map.addControl(new OpenLayers.Control.MousePosition());'
    ht.puts '           map.addControl(new OpenLayers.Control.OverviewMap());'
    ht.puts '           map.addControl(new OpenLayers.Control.KeyboardDefaults());'
    ht.puts ''
    ht.puts '           var info = new OpenLayers.Control.WMSGetFeatureInfo({'
    ht.puts '              url: "' + wmsURL + '", '
    ht.puts '              title: "Identify features by clicking",'
    ht.puts '              queryVisible: true,'
    ht.puts '              eventListeners: {'
    ht.puts '                  getfeatureinfo: function(event) {'
    ht.puts '                      map.addPopup(new OpenLayers.Popup.FramedCloud('
    ht.puts '                          "chicken", '
    ht.puts '                          map.getLonLatFromPixel(event.xy),'
    ht.puts '                          null,'
    ht.puts '                          event.text,'
    ht.puts '                          null,'
    ht.puts '                          true'
    ht.puts '                      ));'
    ht.puts '                  }'
    ht.puts '              }'
    ht.puts ''
    ht.puts '           });'
    ht.puts '           map.addControl(info);'
    ht.puts '           info.activate();'
    ht.puts ''
    ht.puts '           var mapPanel = new GeoExt.MapPanel({'
    ht.puts '               center: new OpenLayers.LonLat(' + @framework.CenterLong.to_s + ', ' + @framework.CenterLat.to_s + '),'
    ht.puts '               zoom: ' + @framework.Zoom.to_s + ','
    ht.puts '               map: map,'
    ht.puts '               title: "' + @jobHash['Crop'] + '",'
    ht.puts '               region: "center"'
    ht.puts '           });'
    ht.puts '           legendPanel = new GeoExt.LegendPanel({'
    ht.puts '               defaults: {'
    ht.puts '                   labelCls: "mylabel",'
    ht.puts '                   style: "padding:5px"'     
    ht.puts '               },'
    ht.puts '               bodyStyle: "padding:5px",'
    ht.puts '               width: 160,'
    ht.puts '               autoScroll: true,'
    ht.puts '               title: "Legend",'
    ht.puts '               region: "west"'
    ht.puts '           });'
    ht.puts '          new Ext.Panel({'
    ht.puts '             title: "LSRS Ratings for: ' + @framework.Title_en + '",'
    ht.puts '             layout: "border",'
    ht.puts '             renderTo: "map",'
    ht.puts '             height: 780,'
    ht.puts '             width: 1100,'
    ht.puts '             items: [mapPanel, legendPanel]'
    ht.puts '           });'
    ht.puts '       });'
    ht.puts '   </script>'
    ht.puts '  </head>'
    ht.puts '  <body onload="init()">'
    ht.puts '    <div id="map"></div>'
    ht.puts ' '
    ht.puts '  </body>'
    ht.puts '</html>'
    ht.close

    # create mapserver template file for WMS GetFeatureInfo requests
    qf = File.open("#{tmpMapDir}/getfeatureinfo.html","w")
    qf.puts '<!-- Mapserver Template -->'
    qf.puts '<style type="text/css">'
    qf.puts '<!-- '
    qf.puts 'p'
    qf.puts '{'
    qf.puts '   font-size:10pt;'
    qf.puts '   font-family: Verdana;'
    qf.puts '   }'
    qf.puts 'td.green'
    qf.puts '   {'
    qf.puts '   color:green;'
    qf.puts '   font-size:10pt;'
    qf.puts '   font-family: Verdana;'
    qf.puts '   font-style:italic;'
    qf.puts '   text-align: right;'
    qf.puts '   padding-right: 5px;'
    qf.puts '   }'
    qf.puts 'td.black'
    qf.puts '   {'
    qf.puts '   font-size:10pt;'
    qf.puts '   font-family: Verdana;'
    qf.puts '   }'
    qf.puts '-->'
    qf.puts '</style>'
    qf.puts '<table>'
    qf.puts '<tr><td class="green">CLASS:</td><td class="black">[LSRSCLASS]</td></tr>'
    qf.puts '<tr><td class="green">RATING:</td><td class="black">[LSRSRATING]</td></tr>'
    qf.puts '<tr><td class="green">FEATURE_ID:</td><td class="black">[QUERYPOLY]</td></tr>'
    qf.puts '</table>'
    qf.puts '<p><a href="http://'+request.host+'/lsrs/service?ClimateTable=Ca_all_slc_v3x0_climate1961x90&FrameworkName=Bc_okanagan_soil_v2x0_cmp&PolyId=[QUERYPOLY]&CROP=sssgrain&RESPONSE=Details">View calculation details</a>.</p>'
    qf.puts '<hr/>'
    qf.close

    # render output and close
    render :file => (tmpHtmDir + "/mapclient.html"), :content_type => "text/html", :layout => false and return and exit 1
  end
  
  def remove
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
          @frameworkName = value
        when "TMPDIR"  
          @tmpDirName = value
      end # case
    end # params

#    if @frameworkName == "Okanagan" then 
#      @frameworkName = "bc_okanagan_soil_v2x0"
#    end

    # MapDir and HtmDir are the same, but 
    tmpMapDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpHtmDir = "/usr/local/httpd/lsrs/public/batch/results/" + @tmpDirName
    tmpCgiDir = "/usr/local/httpd/lsrs/cgi-bin/" + @tmpDirName

    File.delete(tmpCgiDir + "/wms")
    Dir.delete(tmpCgiDir)

    File.delete(tmpMapDir + "/mapclient.html")
    File.delete(tmpMapDir + "/mapfile.map")
    File.delete(tmpMapDir + "/getfeatureinfo.html")
    File.delete(tmpMapDir + "/" + @frameworkName + ".dbf")
    File.delete(tmpMapDir + "/" + @frameworkName + ".sbn")
    File.delete(tmpMapDir + "/" + @frameworkName + ".sbx")
    File.delete(tmpMapDir + "/" + @frameworkName + ".shp")
    File.delete(tmpMapDir + "/" + @frameworkName + ".shx")
    File.delete(tmpMapDir + "/" + @frameworkName + ".qix")
  end

end
