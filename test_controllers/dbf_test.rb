# run using "script/console < app/controllers/lsrs_test.rb",
# or manually at the script/console prompt (but first remove leading tabs)

tablename = "bc_soil_name_v2"
dirname = "/tmp"

# load libraries
require 'dbf'
require "#{Rails.root.to_s}/app/helpers/dbf-helper"

columns = Bc_soil_name_v2.column_names
rows = Bc_soil_name_v2.find(:all)

# prepare the fields array, which defines the structure of the new file
fields = Array.new
#for column in Bc_soil_name_v2.columns do
  #puts column.type
#end
for column in Bc_soil_name_v2.columns do
case column.type
when :string then columnType = "C"
when :float then columnType = "N"
when :integer then columnType = "N"
end
fields.push({:field_name=>column.name, :field_size=>column.limit, :field_type=>columnType, :decimals=>column.precision})
end
for field in fields do
  puts field
end

# add the field to be joined
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

# POPULATE tmpMapDir
# write out dbase file
patfilename = "#{directory.tmpMapDir}/#{@rootName}.dbf"
dbf_writer(patfilename, fields, records)
# create the rest of the shapefile as links
`ln -s #{@coverageDir}#{@rootName}.sbn #{directory.tmpMapDir}/#{@rootName}.sbn`
`ln -s #{@coverageDir}#{@rootName}.sbx #{directory.tmpMapDir}/#{@rootName}.sbx`
`ln -s #{@coverageDir}#{@rootName}.shp #{directory.tmpMapDir}/#{@rootName}.shp`
`ln -s #{@coverageDir}#{@rootName}.shx #{directory.tmpMapDir}/#{@rootName}.shx`
`ln -s #{@coverageDir}#{@rootName}.qix #{directory.tmpMapDir}/#{@rootName}.qix`

# CREATE MAPFILE
# get legend info
@legendURL = "http://lsrs.gis.agr.gc.ca/legends/lsrs02.xml"
@legend = open(@legendURL).read().to_libxml_doc.root
classesXmlArray = @legend.search("//Legend/Classes/Class")
# create hash containing the data to be joined
class LegendRanger
attr_accessor  :Identifier, :Title, :Color
end
classificationArray = Array.new
classesXmlArray.each do |i|
range = LegendRanger.new
range.Identifier = i.search("Identifier").to_a.first.content
range.Title = i.search("Title").to_a.first.content
range.Color = i.search("@color").first.value
classificationArray.push range
end  

@framework = Gframework.find(:all, :conditions => {:ShapeName => coverage})[0]


# changed MinLat etc to East West etc


# create .map file
mf = File.open("#{directory.tmpMapDir}/mapfile.map","w")
mf.puts 'MAP'
mf.puts '  NAME ' + "#{tmpDirName}"
mf.puts '  STATUS ON'
mf.puts '  SIZE 600 420'
mf.puts '  EXTENT  ' + "#{@framework.West} #{@framework.South} #{@framework.East} #{@framework.North}"
mf.puts '  UNITS m'
mf.puts '  SHAPEPATH "' + "#{directory.tmpMapDir}" + '"'
mf.puts '  IMAGECOLOR 255 255 255'
mf.puts '  PROJECTION'
mf.puts '   "proj=utm"'
mf.puts '   "ellps=GRS80"'
mf.puts '   "datum=NAD83"'
mf.puts '   "zone=15"'
mf.puts '   "units=m"'
mf.puts '   "north"'
mf.puts '   "no_defs"'
mf.puts '  END'
mf.puts ''
mf.puts '  WEB'
mf.puts '    IMAGEPATH "' + "#{directory.tmpHtmDir}" + '/"'
mf.puts '    IMAGEURL "/tmp/' + "#{tmpDirName}" + '/"'
mf.puts '    MAXSCALE 60000000'
mf.puts '    METADATA'
mf.puts '      "wms_title" "'  + "#{tmpDirName}" + '"'
mf.puts '      "wms_onlineresource" "http://localhost/cgi-bin/#{tmpDirName}/wms?" '
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

# POPULATE tmpCgiDir
# create cgi-bin mapserv script
ms = File.open("#{directory.tmpCgiDir}/wms","w") 
ms.puts '#!/bin/bash'
ms.puts 'MAPSERV="/usr/lib/cgi-bin/mapserv"'
ms.puts 'MAPFILE="' + "#{directory.tmpMapDir}" + '/mapfile.map"'
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
`chmod 755 #{directory.tmpCgiDir}/wms`




