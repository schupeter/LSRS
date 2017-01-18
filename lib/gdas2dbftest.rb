# on webserv1
outputXmlFilename = "/home/peter/httpd/lsrs/public/batch/results/20111128t120335r4027/output.xml"
rails_root = "/home/peter/httpd/lsrs"

outputXmlFilename = "/production/systems/lsrs/public/batch/results/20120328t171856r1017/output.xml"
dbfname = "/production/systems/lsrs/public/batch/results/20120328t171856r1017/output.dbf"
rails_root = "/production/systems/lsrs"

require "#{rails_root}/lib/gdas_read"
require 'dbf'
require "#{rails_root}/app/helpers/dbf-helper"
require "rubygems"
require "#{rails_root}/app/helpers/libxml-helper"
require "#{rails_root}/lib/lsrs_xml_read"


gdas = open(outputXmlFilename).read().to_libxml_doc.root

gdas.register_namespace("tjs:http://www.opengis.net/tjs/1.0")

@frameworkHash = GDAS_read.framework(gdas)[0]
@attributesArray = GDAS_read.attributes(gdas, "none")

valueTypeArray = Array.new
for attribute in @attributesArray do
valueTypeArray.push attribute["Description"].Type
end

    # prepare the fields array, which defines the structure of the new dbase file 
fields = Array.new
if @frameworkHash.FrameworkKeyType == "string" then fieldType = "C" else fieldType = "N" end
fields.push({:field_name=>@frameworkHash.FrameworkKey.upcase, :field_size=>@frameworkHash.FrameworkKeyLength.to_i, :field_type=>fieldType, :decimals=>@frameworkHash.FrameworkKeyDecimals.to_i})

for attribute in @attributesArray do
case attribute["Description"].Type # TODO expand list of valid values
when "string" then columnType = "C"
when "float" then columnType = "N"
when "integer" then columnType = "N"
end
fields.push({:field_name=>attribute["Description"].AttributeName.upcase, :field_size=>attribute["Description"].Length, :field_type=>columnType, :decimals=>attribute["Description"].Decimals})
end

# get the data
@rowsetArray = GDAS_read.rowset(gdas, @frameworkHash.FrameworkKeyType, valueTypeArray)

# prepare the records array, which contains the content
records = Array.new 
rownum = 0
for gdasRow in @rowsetArray
dbaseRow = Hash.new
dbaseRow[:POLY_ID] = gdasRow[0]
dbaseRow[@attributesArray[0]["Description"].AttributeName.upcase.to_sym] = gdasRow[1][0]
records[rownum] = dbaseRow # add the completed hash to the records array
rownum += 1
end

# write out dbase file
dbf_writer(dbfname, fields, records)

File.open(dbfname, 'w') do |dbf|
    
now = Time.now()
numfields = fields.length
    
    # Header Info
    header = Array.new
    header << 3                                         # Version
    header << now.year-1900                             # Year
    header << now.month                                 # Month
    header << now.day                                   # Day
    header << records.length                            # Number of records
    header << (numfields * 32 + 33)                     # The length of the header
    x = 0
    fields.each { |f| x+=f[:field_size] }
    header << x + 1                                     # The length of each record

    hdr = header.pack('CCCCVvvxxxxxxxxxxxxxxxxxxxx')
    
    # Write out the header
    dbf.write(hdr)
    
    fields.each do |f|    
			
field = Array.new
field << fields[0][:field_name].ljust(11, "\x00")
field << fields[0][:field_type][0].unpack('c')[0] # added unpack March 28 2012
field << fields[0][:field_size]
field << fields[0][:decimals]
fld = field.pack('a11cxxxxCCxxxxxxxxxxxxxx') 
      

@webserv1:
irb(main):051:0> field = Array.new
=> []
irb(main):052:0> field << fields[0][:field_name].ljust(11, "\x00")
=> ["POLY_ID\000\000\000\000"]
irb(main):053:0> field << fields[0][:field_type][0]
=> ["POLY_ID\000\000\000\000", 78]
irb(main):054:0> field << fields[0][:field_size]
=> ["POLY_ID\000\000\000\000", 78, 10]
irb(main):055:0> field << fields[0][:decimals]
=> ["POLY_ID\000\000\000\000", 78, 10, 0]
irb(main):056:0> fld = field.pack('a11cxxxxCCxxxxxxxxxxxxxx') 
=> "POLY_ID\000\000\000\000N\000\000\000\000\n\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"

@genie
irb(main):060:0> field << fields[0][:field_type][0]
=> ["POLY_ID\u0000\u0000\u0000\u0000", "N"]
irb(main):061:0> field << fields[0][:field_size]
=> ["POLY_ID\u0000\u0000\u0000\u0000", "N", 10]
irb(main):062:0> field << fields[0][:decimals]
=> ["POLY_ID\u0000\u0000\u0000\u0000", "N", 10, 0]
irb(main):063:0> fld = field.pack('a11cxxxxCCxxxxxxxxxxxxxx') 
TypeError: can't convert String into Integer
	from (irb):63:in `pack'
	from (irb):63
	from /usr/local/bin/irb:12:in '<main>'

irb(main):064:0> field = ["POLY_ID\000\000\000\000", 78, 10, 0]
=> ["POLY_ID\u0000\u0000\u0000\u0000", 78, 10, 0]
irb(main):065:0> field.pack('a11cxxxxCCxxxxxxxxxxxxxx')
=> "POLY_ID\x00\x00\x00\x00N\x00\x00\x00\x00\n\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

