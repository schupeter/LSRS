# run using "script/console < app/controllers/lsrs_test.rb",
# or manually at the script/console prompt (but first remove all indents)
@polygonHash = Hash.new
@cropHash = Hash.new
@cmpTableName = "Dss_v3_bclowerfraser_cmp"
@polyId = "BC5010040"
@polygonHash.store("FEATURE_ID", @polyId)
@crop = "corn"
@cropHash.store("CROP", @crop)
@climateTableName = "Dss_v3_bclowerfraser_climate1961x90uvic400m"
@response = "Details"
# copy from comment "set and validate some parameters" to the offending line, and remove all indents
# ========================================

@cmpTableMetadata = LsrsCmp.find(:all, :conditions=>{"WarehouseName" => @cmpTableName})[0]
if @cmpTableMetadata ==  nil then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "FrameworkName"; @exceptionParameterValue = @cmpTableName; render :action => 'Error_response', :layout => false and return and exit 1 end
@databaseTitle = @cmpTableMetadata.Title_en
@climateTableMetadata = LsrsClimate.find(:all, :conditions=>{"WarehouseName" => @climateTableName})[0]
if @climateTableMetadata ==  nil then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "ClimateTable"; @exceptionParameterValue = @climateTableName; render :action => 'Error_response', :layout => false and return and exit 1 end
@climateTitle = @climateTableMetadata.Title_en # FIX THIS to properly support climate delivered via XML
if @cmpTableMetadata.FrameworkURI[0..35] == "http://sis.agr.gc.ca/cansis/nsdb/slc" then
@slcCmp = true
@landscapeId = @polyId
@climateId = @polyId
elsif @climateTableMetadata.FrameworkURI[0..35] == "http://sis.agr.gc.ca/cansis/nsdb/slc" then #cmp is not based on SLC, but climatetable is based on SLC
patRecord = eval(@cmpTableMetadata.PolygonTable.capitalize).find(:all, :conditions => {:poly_id => @polyId})[0]
if patRecord != nil then
@landscapeId = patRecord.sl.to_s
@climateId = @landscapeId
else
@lsrsRating = "Invalid feature_id"; @lsrsArray=[]; render :action => 'lsrs/OutputRate', :layout => false and return and exit 1
end
else # cmp and climate data not SLC, must use CMP poly_id
patRecord = eval(@cmpTableMetadata.PolygonTable.capitalize).find(:all, :conditions => {:poly_id => @polyId})[0]
if patRecord != nil then
@landscapeId = patRecord.sl.to_s
@climateId = @polyId
else
@lsrsRating = "Invalid feature_id"; @lsrsArray=[]; render :action => 'lsrs/OutputRate', :layout => false and return and exit 1
end
end

require "#{Rails.root.to_s}/app/helpers/libxml-helper"
require "open-uri"
require "lsrs_calculate"
require "rounding_class"

@tableMetadata = LsrsClimate.find(:all, :conditions=>{:WarehouseName=>@climateTableName})
if (@tableMetadata.size == 0) then # request parameter missing, so return error
@exceptionCode = "InvalidParameterValue"
@exceptionParameter = "TABLE_NAME"
@exceptionParameterValue = @climateTableName
render :action => 'Error_response', :layout => false and return and exit 1
end
@climatePoly = eval(@tableMetadata[0].WarehouseName.capitalize).find(:all, :conditions=>{:poly_id=>@polyId}).first
if (@climatePoly == nil) then # climate data missing, so return error
@exceptionCode = "No Climate Data"
@exceptionParameter = "PolyId"
@exceptionParameterValue = @polyId
render :action => 'Error_response', :layout => false and return and exit 1
end
require "lsrs_climate"
climateParams = Lsrs_climateparam.find(:all, :conditions=>@cropHash)
@climateCoeff = Climate.params(climateParams)
@climate = Climate.calc(@climatePoly, @climateCoeff)

if @slcCmp == true then
@landscapePoly = Slc_v3r0_canada_climate1961x90uvic.find(:all, :conditions=>{:poly_id=>@polyId}).first
else
@landscapePoly = eval(@climateTableName).find(:all, :conditions=>{:poly_id=>@polyId}).first
end
    
@componentHash = Hash.new
@componentHash.store("poly_id", @polyId)
@componentsCmp = eval(@cmpTableName).find(:all, :conditions=>@componentHash)
if @componentsCmp == [] then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "PolyId"; @exceptionParameterValue = @polyId; render :action => 'Error_response', :layout => false and return and exit 1 end

require "lsrs_mineral"
mineralParams = LsrsMineralparam.find(:all, :conditions=>@cropHash)
@mineralCoeff = Mineral.params(mineralParams)
require "lsrs_organic"
organicParams = LsrsOrganicparam.find(:all, :conditions=>@cropHash)
@organicCoeff = Organic.params(organicParams)
@soilHash = Hash.new
@lsrsArray = Array.new

require "lsrs_landscape"
require "soil_soilnamefile"
#    for component in @componentsCmp do
component = @componentsCmp[0]
if @slcCmp == true then cmp = Landscape.inputsSLC(component) else cmp = Landscape.inputsDSS(component) end
@soilHash.store("soil_id", component.soil_id)
@soilHash.store("profile", "A")
@nameRecords = eval("Soil_name_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash)
cmp.nameData = cmp.layerData = false
if @nameRecords.size > 0 then
cmp.nameData = true
@layerRecords = eval("Soil_layer_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerRecords.size > 0 then
cmp.layerData = true
end
end
if cmp.layerData == false then
@soilHash.store("profile", "N")
@nameRecords = eval("Soil_name_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash)
if @nameRecords.size > 0 then
cmp.nameData = true
@layerRecords = eval("Soil_layer_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerRecords.size > 0 then
cmp.layerData = true
end
end
end
      if @nameRecords == [] then @exceptionCode = "SOIL NAME IDENTIFIER NOT FOUND"; @exceptionParameter = "SOIL_ID"; @exceptionParameterValue = @soilHash["soil_id"]; render :action => 'Error_response', :layout => false and return and exit 1 end


