# run using "script/console < app/controllers/lsrs_test.rb",
# or manually at the script/console prompt (but first remove leading tabs)
require 'dbf'
require "#{Rails.root.to_s}/app/helpers/dbf-helper"
require "#{Rails.root.to_s}/app/helpers/libxml-helper"

# determine file names
cmpFilename = "ca_okanagan_soil_v2x0_cmp"
filenameArray = cmpFilename.split("_")
outputFilename = filenameArray[0] + "_" + filenameArray[1] + "_" + filenameArray[2] + "_" + filenameArray[3] + ".dbf"
outputDirFilename = "/usr/local/httpd/mapdata/" +  filenameArray[0] + "/" + filenameArray[1] + "/" + filenameArray[2] + "/" + filenameArray[3] + "/" + outputFilename

# load the original PAT file
#table = DBF::Table.new(patDirFilename)

# prepare the fields array, which defines the structure of the new dbase file
fields = Array.new
fields.push({:field_name=>"FEATURE_ID", :field_size=>10, :field_type=>"N", :decimals=>0})
fields.push({:field_name=>"LSRSRATING", :field_size=>30, :field_type=>"C", :decimals=>0})

# get the LSRS ratings
dir = "/usr/local/httpd/lsrs/public/batch/results/20100201t131934r6318/"   # FIX THIS HARDCODING
lsrsRatingsFileName = dir + "output.xml"

xgdas = File.new(lsrsRatingsFileName).read.to_libxml_doc.root
xgdas.register_default_namespace("tjs")

# create data array containing the Join Table
records = Array.new
data = xgdas.search("//tjs:GDAS/tjs:Framework/tjs:Dataset/tjs:Rowset/tjs:Row").to_a
data.each do |i|
row = Hash.new
i.register_default_namespace("tjs")
row[:FEATURE_ID] = i.search("tjs:K").to_a.first.content.to_i
row[:LSRSRATING] = i.search("tjs:V").to_a.first.content
records.push row
end  

# POPULATE tmpMapDir
# write out dbase file
newPatFilename = dir + "results.dbf"                       # FIX THIS HARDCODING - draw it in from the control file.  And add to status.xml
dbf_writer(newPatFilename, fields, records)
# WORKS TO HERE


