# run using "script/console < app/controllers/lsrs_test_mineral.rb"

@polygonHash = Hash.new
@cropHash = Hash.new
@polyId = "959005"
@polygonHash.store("SL", @polyId)
@crop = "alfalfa"
@cropHash.store("CROP", @crop)
@cmpTable = "Ca_all_slc_v3r2_cmp"
@climateTable = "Ca_all_slc_v3x0_climate1961x90nlwis"
@calc = @crop
@response = "Calculate"
componentNumber = 1
# set and validate some parameters
if @cmpTable.split('_')[2] == "slc" then # this assumes that the file naming convention for datasets is intact
@sl = @polyId 
@slc = true
elsif @cmpTable == "Bc_okanagan_soil_v2x0_cmp" then # TODO:  do this more elegantly by determining the name of the PAT from mysql
@patTable = "bc_okanagan_soil_v2x0_pat"
slFromCmp = Bc_okanagan_soil_v2x0_pat.find(:all, :conditions => {:feature_id => @polyId.to_i})[0]
if slFromCmp != nil then
@sl = slFromCmp.slc.to_s
else
@lsrsRating = "Invalid feature_id"
render :action => 'lsrs/OutputRate', :layout => false and return and exit 1
end
elsif @cmpTable == "Ab_agrisid_soil_v1x0_cmp" then # TODO:  do this more elegantly by determining the name of the PAT from mysql
@patTable = "ab_agrisid_soil_v1x0_pat"
slFromCmp = Ab_agrisid_soil_v1x0_pat.find(:all, :conditions => {:polynumb => @polyId.to_i})[0]
if slFromCmp != nil then
@sl = slFromCmp.sl.to_s
else
@lsrsRating = "Invalid feature_id"
render :action => 'lsrs/OutputRate', :layout => false and return and exit 1
end
else 
@sl = "1006011" # ASSUME CLIMATE FOR ALL OTHER DATASETS
end 
if (Lsrsclimateparam.find(:all, :conditions => {:crop => @crop}).size !=  1 ) then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "CROP"; @exceptionParameterValue = @crop; render :action => 'Error_response', :layout => false and return and exit 1 end

# determine SNF/SLF to use
case @cmpTable.split('_')[0] 
when "Ab"
@namesTable = "Ab_agrisid_soil_v1x0_snf"
@layersTable = "Ab_agrisid_soil_v1x0_slf"
when "Bc"
@namesTable = "Bc_all_names_v1"
@layersTable = "Bc_all_layers_v1"
when "Ca"
case @cmpTable
when "Ca_all_slc_v3x0_cmp"
@namesTable = "Ca_all_slc_v3_snf"
@layersTable = "Ca_all_slc_v3_slf"
when "Ca_all_slc_v3r2_cmp"
@namesTable = "Ca_all_name_v2r000"
@layersTable = "Ca_all_layer_v2r000"
end
end

# prepare to get inputs
require "#{Rails.root.to_s}/app/helpers/libxml-helper"
require "open-uri"
require "lsrs_xml_read"
#prepare to calculate
require "lsrs_calculate"
require "rounding_class"

# validate climate database exists 
climateMetadata = Gdataset.find(:all, :conditions=>{"WarehouseName" => @climateTable})
if climateMetadata ==  [] then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "ClimateTable"; @exceptionParameterValue = @climateTable; render :action => 'Error_response', :layout => false and return and exit 1 end
@climateTitle = climateMetadata[0].Title_en # FIX THIS to properly support climate delivered via XML

# get climate inputs (currently available only by SL)
if @slc == true then
lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/service?POLY_ID=" + @sl +"&DATA=climate&TABLE_NAME=" + @climateTable
else
lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/service?POLY_ID=" + @sl +"&DATA=climate&TABLE_NAME=" + @climateTable
end
lsrsInput = open(lsrsInputURL).read().to_libxml_doc.root
if lsrsInput.search("//ExceptionReport") != [] then # invalid polygon number because missing from climate
@exceptionCode = "WebServiceRequestFailed"
@exceptionRequest = lsrsInputURL
@exceptionCascade = lsrsInput.search("//ExceptionReport/Exception")
render :action => 'Error_response', :layout => false and return and exit 1
end

# calculate climate
@climatePoly = LsrsXml.readClimate(lsrsInput)
require "lsrs_climate"
climateParams = Lsrsclimateparam.find(:all, :conditions=>@cropHash)
@climateCoeff = Climate.params(climateParams)
@climate = Climate.calc(@climatePoly, @climateCoeff)

    # get landscape inputs (currently available only by SL)
if @slc == true then
lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/service?POLY_ID=" + @sl +"&DATA=landscape"
lsrsInput = open(lsrsInputURL).read().to_libxml_doc.root
@landscapePoly = LsrsXml.readLandscape(lsrsInput)
else
require "#{Rails.root.to_s}/lib/lsrs_landscape_input_class"
@landscapePoly = LsrsLandscapeInputClass.new
@landscapePoly.ErosivityRegion = "2" # FIX THIS to properly support detailed datasets in Erosivity Region 1
end

    # validate soil database exists 
databaseMetadata = Gdataset.find(:all, :conditions=>{"WarehouseName" => @cmpTable})
if databaseMetadata ==  [] then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "CmpTable"; @exceptionParameterValue = @cmpTable; render :action => 'Error_response', :layout => false and return and exit 1 end
@databaseTitle = databaseMetadata[0].Title_en
# and get soil components 
@componentHash = Hash.new
@componentHash.store("poly_id", @polyId)
@componentsCmp = eval(@cmpTable).find(:all, :conditions=>@componentHash)
if @componentsCmp == [] then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "PolyId"; @exceptionParameterValue = @polyId; render :action => 'Error_response', :layout => false and return and exit 1 end

    # prepare to calculate LSRS ratings
require "lsrs_mineral"
mineralParams = Lsrsmineralparam.find(:all, :conditions=>@cropHash)
@mineralCoeff = Mineral.params(mineralParams)
require "lsrs_organic"
organicParams = Lsrsorganicparam.find(:all, :conditions=>@cropHash)
@organicCoeff = Organic.params(organicParams)
@soilHash = Hash.new
@lsrsArray = Array.new

    # calculate LSRS ratings for each soil component
require "lsrs_landscape"
require "soil_soilnamefile"
for component in @componentsCmp do
# initialize cmp
if @slc == true then cmp = Landscape.inputsSLC(component) else cmp = Landscape.inputsDSS(component) end
# calculate soil ratings     
#Retrieve records from SNF and SLF using Profile = A
@soilHash.store("soil_id", component.soil_id)
@soilHash.store("profile", "A")
@nameRecords = eval(@namesTable).find(:all, :conditions=>@soilHash)
cmp.nameData = cmp.layerData = false
if @nameRecords.size > 0 then
cmp.nameData = true
@layerRecords = eval(@layersTable).find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerRecords.size > 0 then
cmp.layerData = true
end
end
if cmp.layerData == false then
# no SNF hits, so try Profile = N
@soilHash.store("profile", "N")
@nameRecords = eval(@namesTable).find(:all, :conditions=>@soilHash)
if @nameRecords.size > 0 then
cmp.nameData = true
@layerRecords = eval(@layersTable).find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerRecords.size > 0 then
cmp.layerData = true
end
end
end
if @nameRecords == [] then @exceptionCode = "SOIL NAME IDENTIFIER NOT FOUND"; @exceptionParameter = "SOIL_ID"; @exceptionParameterValue = @soilHash["soil_id"]; render :action => 'Error_response', :layout => false and return and exit 1 end
# SNF/SLF records should have been retrieved.  Start remaining calculations.
if cmp.layerData == true 
if @nameRecords[0].order3 == "OR" then
# organic component
cmp = Organic.inputsSLC(cmp, @nameRecords[0])
cmp = Organic.horizonsSLC(cmp, @layerRecords)
cmp = Organic.calc(cmp, @climatePoly, @organicCoeff)
elsif @nameRecords[0].order3 == "-" then
# pseudo mineral component
cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
cmp = Mineral.horizonsSLC(cmp, @layerRecords, @climatePoly)
cmp = Mineral.NotSoil(cmp)
#cmp = Mineral.calc(cmp, @climatePoly, @mineralCoeff)
else
# true mineral component
cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
cmp = Mineral.horizonsSLC(cmp, @layerRecords, @climatePoly)
cmp = Mineral.validateHorizons(cmp)
cmp = Mineral.calc(cmp, @climatePoly, @mineralCoeff)
end
else
# pseudo mineral component (without layer info)
cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
cmp = Mineral.NotSoil(cmp)
#cmp = Mineral.calc(cmp, @climatePoly, @mineralCoeff)
end
# populate SNF content
cmp = Soilname.attributes(cmp, @nameRecords[0])
# calculate landscape ratings
cropLandscapeModel = Landscape.model(@crop, @landscapePoly.ErosivityRegion, cmp.LandscapeComplexity)
landscapeParams = Lsrslandscapeparam.find(:all, :conditions=>{:crop=>@crop})
landscapeModelParams = Lsrslandscapemodelparam.find(:all, :conditions=>{:model=>cropLandscapeModel})
@landscapeCoeff = Landscape.params(landscapeParams, landscapeModelParams)
@landscape = Landscape.calc(cmp, @landscapePoly, cropLandscapeModel, @landscapeCoeff, @crop)
# populate lsrsArray 
@lsrsArray.push cmp
end # of components
