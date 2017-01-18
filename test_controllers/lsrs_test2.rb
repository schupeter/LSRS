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
#if @cmpTableMetadata ==  nil then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "FrameworkName"; @exceptionParameterValue = @cmpTableName; render :action => 'Error_response', :layout => false and return and exit 1 end
@databaseTitle = @cmpTableMetadata.Title_en
# climate table
@climateTableMetadata = LsrsClimate.find(:all, :conditions=>{"WarehouseName" => @climateTableName})[0]
#if @climateTableMetadata ==  nil then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "ClimateTable"; @exceptionParameterValue = @climateTableName; render :action => 'Error_response', :layout => false and return and exit 1 end
@climateTitle = @climateTableMetadata.Title_en # FIX THIS to properly support climate delivered via XML

# set and validate some parameters
# if component table or climate table are based on the SLC, then use the appropriate SLC poly_id
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

# determine SNF/SLF to use
#@nameTable = @cmpTableMetadata.NameTable.capitalize
#@layerTable = @cmpTableMetadata.LayerTable.capitalize

# prepare to get inputs
require "#{Rails.root.to_s}/app/helpers/libxml-helper"
require "open-uri"
#    require "lsrs_xml_read"
#prepare to calculate
require "lsrs_calculate"
require "rounding_class"

# get climate inputs
#    lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/service?POLY_ID=" + @climateId +"&DATA=climate&TABLE_NAME=" + @climateTableName
#    lsrsInput = open(lsrsInputURL).read().to_libxml_doc.root
#    if lsrsInput.search("//ExceptionReport") != [] then # invalid polygon number because missing from climate
#      @exceptionCode = "WebServiceRequestFailed"
#      @exceptionRequest = lsrsInputURL
#      @exceptionCascade = lsrsInput.search("//ExceptionReport/Exception")
#      render :action => 'Error_response', :layout => false and return and exit 1
#    end

# calculate climate
#    @climatePoly = LsrsXml.readClimate(lsrsInput)
@tableMetadata = LsrsClimate.find(:all, :conditions=>{:WarehouseName=>@climateTableName})
#if (@tableMetadata.size == 0) then # request parameter missing, so return error
#@exceptionCode = "InvalidParameterValue"
#@exceptionParameter = "TABLE_NAME"
#@exceptionParameterValue = @climateTableName
#render :action => 'Error_response', :layout => false and return and exit 1
#end
@climatePoly = eval(@tableMetadata[0].WarehouseName.capitalize).find(:all, :conditions=>{:poly_id=>@polyId}).first
#if (@climatePoly == nil) then # climate data missing, so return error
#@exceptionCode = "No Climate Data"
#@exceptionParameter = "PolyId"
#@exceptionParameterValue = @polyId
#render :action => 'Error_response', :layout => false and return and exit 1
#end
require "lsrs_climate"
climateParams = Lsrs_climateparam.find(:all, :conditions=>@cropHash)
@climateCoeff = Climate.params(climateParams)
@climate = Climate.calc(@climatePoly, @climateCoeff)

# get landscape inputs (available only by SL)
if @slcCmp == true then
@landscapePoly = Slc_v3r0_canada_climate1961x90uvic.find(:all, :conditions=>{:poly_id=>@polyId}).first
else
#      require "#{Rails.root.to_s}/lib/lsrs_landscape_input_class"
#@landscapePoly = LsrsLandscapeInputClass.new
#@landscapePoly.ErosivityRegion = "2" # FIX THIS to properly support detailed datasets in Erosivity Region 1
@landscapePoly = eval(@climateTableName).find(:all, :conditions=>{:poly_id=>@polyId}).first
end

# get soil components 
@componentHash = Hash.new
@componentHash.store("poly_id", @polyId)
@componentsCmp = eval(@cmpTableName).find(:all, :conditions=>@componentHash)
#if @componentsCmp == [] then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "PolyId"; @exceptionParameterValue = @polyId; render :action => 'Error_response', :layout => false and return and exit 1 end

# prepare to calculate LSRS ratings
require "lsrs_mineral"
mineralParams = LsrsMineralparam.find(:all, :conditions=>@cropHash)
@mineralCoeff = Mineral.params(mineralParams)
require "lsrs_organic"
organicParams = LsrsOrganicparam.find(:all, :conditions=>@cropHash)
@organicCoeff = Organic.params(organicParams)
@soilHash = Hash.new
@lsrsArray = Array.new

# calculate LSRS ratings for each soil component
require "lsrs_landscape"
require "soil_soilnamefile"
for component in @componentsCmp do
# initialize cmp
if @slcCmp == true then cmp = Landscape.inputsSLC(component) else cmp = Landscape.inputsDSS(component) end
# calculate soil ratings     
#Retrieve records from SNF and SLF using Profile = A
@soilHash.store("soil_id", component.soil_id)
@soilHash.store("profile", "A")
#      @nameRecords = eval(@nameTable).find(:all, :conditions=>@soilHash)
@nameRecords = eval("Soil_name_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash)
cmp.nameData = cmp.layerData = false
if @nameRecords.size > 0 then
cmp.nameData = true
#        @layerRecords = eval(@layerTable).find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
@layerRecords = eval("Soil_layer_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerRecords.size > 0 then
cmp.layerData = true
end
end
if cmp.layerData == false then
# no SNF hits, so try Profile = N
@soilHash.store("profile", "N")
#        @nameRecords = eval(@nameTable).find(:all, :conditions=>@soilHash)
@nameRecords = eval("Soil_name_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash)
if @nameRecords.size > 0 then
cmp.nameData = true
#          @layerRecords = eval(@layerTable).find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
@layerRecords = eval("Soil_layer_"+component.province.downcase+"_v2").find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
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
if @nameRecords[0].g_group3 == "FO" and @nameRecords[0].s_group3 == "HU" then # process as pseudo mineral (not rated) Bug 28
cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
cmp = Mineral.horizonsSLC(cmp, @layerRecords, @climatePoly)
cmp = Mineral.NotSoil(cmp)
else # process as normal organic
cmp = Organic.inputsSLC(cmp, @nameRecords[0])
cmp = Organic.horizonsSLC(cmp, @layerRecords)
cmp = Organic.calc(cmp, @climatePoly, @organicCoeff)
end
elsif @nameRecords[0].order3 == "-" then
# pseudo mineral component (not rated)
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
@cropLandscapeModel = Landscape.model(@crop, @landscapePoly.ErosivityRegion, cmp.LandscapeComplexity)
@landscape = Landscape.calc(cmp, @landscapePoly, @cropLandscapeModel, @crop)
# populate lsrsArray 
@lsrsArray.push cmp
end # of components




    # Create aggregate rating
    # STEP 1: Assign Components to Categories
    require 'lsrs_aggregate'
    category = Aggregate.Categorize(@lsrsArray)
    # STEP 2: Summarize the special Not Rated category
    percentNotRated = Aggregate.NotRated(category.NotRated)
    # STEP 3: Summarize the normal categories:
    drainageFactorHash = Aggregate.Soil(category.Drainage)
    dominantFactorHash = Aggregate.Soil(category.Dominant)
    dissimilarFactorHash = Aggregate.Soil(category.Dissimilar)
    
    # STEP 4: Determine the class number 
    # assign climate factor rating
    drainageFactorHash['ClimateRating'] = @climate.Value.round
    dominantFactorHash['ClimateRating'] = @climate.Value.round
    dissimilarFactorHash['ClimateRating'] = @climate.Value.round
    # determine most limiting factor and calculate class
    drainageFactorHash = Aggregate.MostLimitingFactor(drainageFactorHash)
    dominantFactorHash = Aggregate.MostLimitingFactor(dominantFactorHash)
    dissimilarFactorHash = Aggregate.MostLimitingFactor(dissimilarFactorHash)
    
    # STEP 5: Aggregate the subclass values (do this before step 4 to initialize *SubfactorHash easily)
    # Step 5.1: Calculate weighted average for soil and landscape factors
    drainageSubfactorHash = Aggregate.SummarizeSubfactors(category.Drainage, drainageFactorHash['Percent'])
    dominantSubfactorHash = Aggregate.SummarizeSubfactors(category.Dominant, dominantFactorHash['Percent'])
    dissimilarSubfactorHash = Aggregate.SummarizeSubfactors(category.Dissimilar, dissimilarFactorHash['Percent'])
    # introduce climate subfactors A/H
    drainageSubfactorHash['H'] = @climate.H_deduct
    drainageSubfactorHash['A'] = @climate.A_deduct
    dominantSubfactorHash['H'] = @climate.H_deduct
    dominantSubfactorHash['A'] = @climate.A_deduct
    dissimilarSubfactorHash['H'] = @climate.H_deduct
    dissimilarSubfactorHash['A'] = @climate.A_deduct
    # STEP 5.2: sort subclasses in order of importance
    drainageSubfactorHash.sort { |l, r| l[1]<=>r[1] }
    dominantSubfactorHash.sort { |l, r| l[1]<=>r[1] }
    dissimilarSubfactorHash.sort { |l, r| -1*(l[1]<=>r[1]) }
    
    # STEP 6: Drop the less important subclasses
    # Step 6.1 drop subfactor values less than or equal to 20
    drainageSubfactorHash = Aggregate.DropBelow20(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate.DropBelow20(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate.DropBelow20(dissimilarSubfactorHash)
    # Step 6.2 drop A and H if climate is not the most limiting factor
    drainageSubfactorHash = Aggregate.DropAH(drainageSubfactorHash, drainageFactorHash)
    dominantSubfactorHash = Aggregate.DropAH(dominantSubfactorHash, dominantFactorHash)
    dissimilarSubfactorHash = Aggregate.DropAH(dissimilarSubfactorHash, dissimilarFactorHash)
    # Step 6.3  drop A or M if both are present
    drainageSubfactorHash = Aggregate.DropAM(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate.DropAM(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate.DropAM(dissimilarSubfactorHash)
    # Step 6.4  drop less significant subclasses
    # Step 6.4.1  within factor comparison
    drainageSubfactorHash = Aggregate.DropWithinFactor(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate.DropWithinFactor(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate.DropWithinFactor(dissimilarSubfactorHash)
    # Step 6.4.2  between factor comparison
    drainageSubfactorHash = Aggregate.DropOtherFactors(drainageSubfactorHash, drainageFactorHash)
    dominantSubfactorHash = Aggregate.DropOtherFactors(dominantSubfactorHash, dominantFactorHash)
    dissimilarSubfactorHash = Aggregate.DropOtherFactors(dissimilarSubfactorHash, dissimilarFactorHash)
    # Step 6.5 determine primary subclass
    drainageFactorHash = Aggregate.PrimarySubclass(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate.PrimarySubclass(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate.PrimarySubclass(dissimilarSubfactorHash, dissimilarFactorHash)
    # determine remaining subclasses
    drainageFactorHash = Aggregate.AdditionalSubclasses(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate.AdditionalSubclasses(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate.AdditionalSubclasses(dissimilarSubfactorHash, dissimilarFactorHash)

    # STEP 7: Create Category Ratings
    drainageFactorHash = Aggregate.FinalClass(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate.FinalClass(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate.FinalClass(dissimilarSubfactorHash, dissimilarFactorHash)
    
    # STEP 8: Create a Composite Rating
    # calculate deciles
    decileArray = Calculate.perdecim([drainageFactorHash['Percent'], dominantFactorHash['Percent'], dissimilarFactorHash['Percent'], percentNotRated])
    drainageFactorHash['PerDecim']  = decileArray[0]
    dominantFactorHash['PerDecim'] = decileArray[1]
    dissimilarFactorHash['PerDecim'] = decileArray[2]
    perdecimNotRated = decileArray[3]
    # create rating
    @lsrsRating = Aggregate.rating(drainageFactorHash,dominantFactorHash,dissimilarFactorHash,perdecimNotRated)

    #Render results as XML
    case @response 
      when "Rate" then render :action => 'OutputRate', :layout => false and return and exit 1
      when "Components" then render :action => 'OutputComponents', :layout => false and return and exit 1
      else render :action => 'OutputDetails', :layout => false and return and exit 1
    end
    
