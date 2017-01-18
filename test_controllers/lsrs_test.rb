# run using "script/console < app/controllers/lsrs_test.rb",
# or manually at the script/console prompt (but first remove leading tabs)

@polygonHash = Hash.new
@cropHash = Hash.new
@cmpTable = "Ca_all_slc_v3x0_cmp"
@polyId = "959005"
@polygonHash.store("FEATURE_ID", @polyId)
@crop = "sssgrain"
@cropHash.store("CROP", @crop)
@climateTable = "Ca_all_slc_v3x0_climate1961x90"
@response = "Calculate"
# copy from comment "set and validate some parameters" to the offending line, and remove all indents
# ========================================

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
else 
@sl = "1006011" # ASSUME CLIMATE FOR ALL OTHER DATASETS
end 
if (Lsrsclimateparam.find(:all, :conditions => {:crop => @crop}).size !=  1 ) then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "CROP"; @exceptionParameterValue = @crop; render :action => 'Error_response', :layout => false and return and exit 1 end

    # determine SNF/SLF to use
case @cmpTable.split('_')[0] 
when "Ca" 
@namesTable = "Ca_all_slc_v3_snf"
@layersTable = "Ca_all_slc_v3_slf"
when "Bc"
@namesTable = "Bc_all_names_v1"
@layersTable = "Bc_all_layers_v1"
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
lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/serv?SL=" + @sl +"&CALC=climate"
else
lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/serv?SL=" + @sl +"&CALC=climate"
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
lsrsInputURL = "http://lsrs.gis.agr.gc.ca/lsrsinput/serv?SL=" + @sl +"&CALC=landscape"
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
if @slc == true then @componentHash.store("sl", @polyId) else @componentHash.store("feature_id", @polyId) end
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
#Retrieve records from SNF and SLF using LU = A
if @slc == true then @soilHash.store("soiltype", component.soiltype) else @soilHash.store("name_id", component.name_id) end
@soilHash.store("lu", "A")
@nameSLC = eval(@namesTable).find(:all, :conditions=>@soilHash)
cmp.nameData = cmp.layerData = false
if @nameSLC.size > 0 then
cmp.nameData = true
@layerSLC = eval(@layersTable).find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerSLC.size > 0 then
cmp.layerData = true
end
end
if cmp.layerData == false then
# no SNF hits, so try LU = N
@soilHash.store("lu", "N")
@nameSLC = eval(@namesTable).find(:all, :conditions=>@soilHash)
if @nameSLC.size > 0 then
cmp.nameData = true
@layerSLC = eval(@layersTable).find(:all, :conditions=>@soilHash).sort_by { |x| x.layer_no }
if @layerSLC.size > 0 then
cmp.layerData = true
end
end
end
if @nameSLC == [] then @exceptionCode = "NAME_ID NOT FOUND"; @exceptionParameter = "NAME_ID"; @exceptionParameterValue = @soilHash["soiltype"]; render :action => 'Error_response', :layout => false and return and exit 1 end
# SNF/SLF records should have been retrieved.  Start remaining calculations.
if cmp.layerData == true 
if @nameSLC[0].order3 == "OR" then
# organic component
cmp = Organic.inputsSLC(cmp, @nameSLC[0])
#cmp = Organic.horizonsSLC(cmp, @layerSLC)


 # def Organic.horizonsSLC(cmp, layerSLC)
layerSLC = @layerSLC
# Horizon Processing if ORGANIC component.
# initialize values for horizon processing
cmp.OrganicDepth = 0
cmp.SurfaceDepth = 40
cmp.SurfaceBD = 0.0
cmp.SurfaceFibre = 0
cmp.SurfaceReaction = 0.0
cmp.SurfaceSalinity = 0.0
cmp.SurfaceWood = 0
cmp.SubsurfaceDepth = 120
cmp.SubsurfaceBD = 0.0
cmp.SubsurfaceFibre = 0
cmp.SubsurfaceReaction = 0.0
cmp.SubsurfaceSalinity = 0.0
#    cmp.SubsurfaceTexture = 0
cmp.SubsurfaceWood = 0
cmp.SubSubsurfaceExists = false
cmp.SubSubsurfaceTsilt = 0
cmp.SubSubsurfaceTclay = 0
cmp.SubSubsurfaceCofrag = 0  
# start processing horizons
lyrArray = Array.new
for layer in layerSLC do
lyr = LsrsLyrOrganicClass.new
# Get the HZN_MAS value and generalize it for subsequent processing. 
lyr.hznmasClass = layer.hzn_mas
if lyr.hznmasClass == "AB"  then lyr.hznmasClass = "A" end
if lyr.hznmasClass == "AC"  then lyr.hznmasClass = "A" end
if lyr.hznmasClass == "B"   then lyr.hznmasClass = "A" end
if lyr.hznmasClass == "BA"  then lyr.hznmasClass = "A" end
if lyr.hznmasClass == "BC"  then lyr.hznmasClass = "A" end
if lyr.hznmasClass == "C+H" then lyr.hznmasClass = "C" end
if lyr.hznmasClass == "CA"  then lyr.hznmasClass = "C" end
if lyr.hznmasClass == "CB"  then lyr.hznmasClass = "C" end
if lyr.hznmasClass == "W"   then lyr.hznmasClass = "R" end
if (lyr.hznmasClass == "O" and cmp.SubSubsurfaceExists == false) then cmp.OrganicDepth = layer.ldepth end
if (lyr.hznmasClass == ("R" or "CO") and cmp.SubSubsurfaceExists == false) then
cmp.SubSubsurfaceExists = true
cmp.SubSubsurfaceUpperDepth = layer.udepth
cmp.SubSubsurfaceLowerDepth = layer.ldepth
cmp.SubSubsurfaceHZNMAS = lyr.hznmasClass
end
if (lyr.hznmasClass == ("A" or "C") and cmp.SubSubsurfaceExists == false) then
cmp.SubSubsurfaceExists = true
cmp.SubSubsurfaceUpperDepth = layer.udepth
cmp.SubSubsurfaceLowerDepth = layer.ldepth
cmp.SubSubsurfaceHZNMAS = lyr.hznmasClass
cmp.SubSubsurfaceTsilt = layer.tsilt
cmp.SubSubsurfaceTclay = layer.tclay
cmp.SubSubsurfaceCofrag = layer.cofrag
end
# add calculated layer to array of layers
lyrArray.push lyr
end # for layer
# Now let's adjust depth numbers.
if cmp.OrganicDepth < cmp.SubsurfaceDepth then cmp.SubsurfaceDepth = cmp.OrganicDepth end
if cmp.SubsurfaceDepth > 120 then cmp.SubsurfaceDepth = 120 end
if cmp.SurfaceDepth > cmp.SubsurfaceDepth then cmp.SurfaceDepth = cmp.SubsurfaceDepth end

# Now continue processing for each horizon
layerSLC.each_with_index do | layer, i |
if layer.udepth == nil then
lyrArray[i].udepth = 0
else
lyrArray[i].udepth = layer.udepth
end
if layer.ldepth == nil then
lyrArray[i].ldepth = 120
else
lyrArray[i].ldepth = layer.ldepth
end
#lyrArray[i].bd = layer.bd
if layer.hzn_mas == "R" and layer.bd == -9 then lyrArray[i].bd = 3.2 else lyrArray[i].bd = layer.bd end # bug 19
lyrArray[i].cofrag = layer.cofrag
lyrArray[i].tsilt = layer.tsilt
lyrArray[i].tclay = layer.tclay
lyrArray[i].orgcarb = layer.orgcarb
lyrArray[i].ph2 = layer.ph2
lyrArray[i].ec = layer.ec
lyrArray[i].kp0 = layer.kp0
lyrArray[i].vonpost = layer.vonpost
lyrArray[i].wood = layer.wood
lyrArray[i].hznmas = layer.hzn_mas
# Proxy the value for % Fibre 
if layer.vonpost != -9 then
lyrArray[i].fibre = 109.3 + -21.228788 * layer.vonpost + 1.0378788 * layer.vonpost ** 2
elsif layer.bd != -9 then
lyrArray[i].fibre = (155.47688 * 0.032419017 +-22.457452 * layer.bd ** 1.2332106) / (0.032419017 + layer.bd ** 1.2332106)
else
lyrArray[i].fibre = 0   # updated Oct 5 2009 to control for missing bd values
end
if lyrArray[i].fibre < 0 then lyrArray[i].fibre = 0 end # updated Oct 5 2009 because statement was missing an action
#determine horizon assignment factors
lyrArray[i].SurfaceFactor = lyrArray[i].SubsurfaceFactor = 0.0
# calc surfaceFactor
if lyrArray[i].udepth < cmp.SurfaceDepth then
lyrArray[i].SurfaceFactor = ( [cmp.SurfaceDepth, lyrArray[i].ldepth].min - lyrArray[i].udepth ) / cmp.SurfaceDepth.to_f
end
# calc subsurfaceFactor
if lyrArray[i].ldepth > cmp.SurfaceDepth and  then
lyrArray[i].SubsurfaceFactor = ( [cmp.SubsurfaceDepth, lyrArray[i].ldepth].min - [cmp.SurfaceDepth, lyrArray[i].udepth].max ) / ( cmp.SubsurfaceDepth - cmp.SurfaceDepth ).to_f
if lyrArray[i].SubsurfaceFactor.nan? then lyrArray[i].SubsurfaceFactor = 0.0 end
end
# First -- Surface variables
cmp.SurfaceBD = cmp.SurfaceBD + layer.bd * lyrArray[i].SurfaceFactor;
cmp.SurfaceFibre = cmp.SurfaceFibre + lyrArray[i].fibre * lyrArray[i].SurfaceFactor
# Surface Reaction
cmp.SurfaceReaction = cmp.SurfaceReaction + layer.ph2 * lyrArray[i].SurfaceFactor
# Surface Salinity
if layer.ec == -9 then organic_SurfaceSalinityEC_Value = 0.1 else organic_SurfaceSalinityEC_Value = layer.ec end
cmp.SurfaceSalinity = cmp.SurfaceSalinity + organic_SurfaceSalinityEC_Value * lyrArray[i].SurfaceFactor
# Subsurface BD
cmp.SubsurfaceBD = cmp.SubsurfaceBD + layer.bd * lyrArray[i].SubsurfaceFactor
# Subsurface Fibre
cmp.SubsurfaceFibre = cmp.SubsurfaceFibre + lyrArray[i].fibre * lyrArray[i].SubsurfaceFactor
# Subsurface Reaction
if layer.ph2 != -9 then cmp.SubsurfaceReaction = cmp.SubsurfaceReaction + layer.ph2 * lyrArray[i].SubsurfaceFactor end  # added condition Jan 26 2010 to fix missing values for rock
# Subsurface Salinity
if layer.ec == -9 then organic_SubsurfaceSalinityEC_Value = 0.1 else organic_SubsurfaceSalinityEC_Value = layer.ec end
cmp.SubsurfaceSalinity = cmp.SubsurfaceSalinity + organic_SubsurfaceSalinityEC_Value * lyrArray[i].SubsurfaceFactor
# Surface and Subsurface Wood
if layer.wood == -9 then woodValue = 0 else woodValue = layer.wood end 
cmp.SurfaceWood = cmp.SurfaceWood + woodValue * lyrArray[i].SurfaceFactor
cmp.SubsurfaceWood = cmp.SubsurfaceWood + woodValue * lyrArray[i].SubsurfaceFactor
end # layerSLC.each

#populate cmp with layers
cmp.layers = lyrArray
# Set defaults for Subsubsurface
if cmp.SubSubsurfaceExists == false then 
cmp.SubSubsurfaceHZNMAS = "-"
cmp.SubSubsurfaceTsilt = 0
cmp.SubSubsurfaceTclay = 0
cmp.SubSubsurfaceCofrag = 0
end



#cmp = Organic.calc(cmp, @climatePoly, @organicCoeff)



climatePoly = @climatePoly
coeff = @organicCoeff
cmp.TemperatureDeduction = Calculate.constrain( (coeff.Za + coeff.Zb * climatePoly.EGDD), 0, 25)
cmp.OrganicBaseRating = 100 - cmp.TemperatureDeduction
# moisture deficit factor (M)
cmp.WaterCapacityDeduction = [(40 * ( [cmp.SurfaceFibre,0].max / 80) ) - (((250 + climatePoly.PPE) / 50) * 5), 0].max
if cmp.SubsurfaceFibre < 0 then subsurfaceFibre = 0.01 else subsurfaceFibre = cmp.SubsurfaceFibre end
cmp.WaterTableAdjustment = cmp.WaterCapacityDeduction * (100 - ((cmp.WaterTableDepth ** 2) / 12) / (5 + (10 / (0.1 * subsurfaceFibre))) ) / -100
cmp.MoistureDeficitDeduction = cmp.WaterCapacityDeduction + cmp.WaterTableAdjustment
cmp.InterimRating = cmp.OrganicBaseRating -  cmp.MoistureDeficitDeduction
# surface factors (sf)
# surface structure deduction (B)
cmp.SurfaceStructureDeduction = [(40.00873619 + -2.3912966 * cmp.SurfaceFibre + 0.213398324 * climatePoly.PPE + 0.045354094 * cmp.SurfaceFibre ** 2 + 0.000614069 * climatePoly.PPE ** 2 + -0.009623 * cmp.SurfaceFibre * climatePoly.PPE + -0.0002331 * cmp.SurfaceFibre ** 3 +2.78E-07 * climatePoly.PPE ** 3 + -3.53E-06 * cmp.SurfaceFibre * climatePoly.PPE ** 2 + 7.33E-05 * cmp.SurfaceFibre ** 2 * climatePoly.PPE),0].max
# surface reaction deduction (V)
if cmp.SurfaceReaction < 5.5 then
cmp.SurfaceReactionDeduction = [(40*((Math.sqrt(cmp.SurfaceFibre)) / 8.9)) + (((5.5 - cmp.SurfaceReaction) / 0.1) * ( 1 + ((Math.sqrt( 100 / (cmp.SurfaceFibre+0.1))) * 0.1))),0].max 
else 
cmp.SurfaceReactionDeduction = [(40 * ((Math.sqrt(cmp.SurfaceFibre)) / 8.9)),0].max
end
# surface salinity deduction (N) - Table 5.7
cmp.SurfaceSalinityDeductionInterim = (-13.230275*22.752925 + 94.480275 * cmp.SurfaceSalinity ** 1.67181) / (22.752925 + cmp.SurfaceSalinity ** 1.67181) 
cmp.SurfaceSalinityDeduction = Calculate.constrain(cmp.SurfaceSalinityDeductionInterim,0,100).to_f
cmp.SurfaceMostLimitingDeduction = [cmp.SurfaceReactionDeduction,cmp.SurfaceSalinityDeduction].max
cmp.SurfaceTotalDeductions = cmp.SurfaceStructureDeduction + cmp.SurfaceMostLimitingDeduction
cmp.SurfaceFinalDeduction = (cmp.SurfaceTotalDeductions.to_f / 100) * cmp.InterimRating
cmp.BasicOrganicRating = cmp.InterimRating - cmp.SurfaceFinalDeduction
# subsurface factors
# subsurface structure deduction (B) - Table 5.8
#subsurfaceFibre = [cmp.SubsurfaceFibre,0].max # removed Jan 26 2010 to eliminate error - should be OK because of line 169
if subsurfaceFibre >= 40 then
cmp.SubsurfaceStructureDeduction = -20 + 0.5 * subsurfaceFibre
elsif subsurfaceFibre > 20
cmp.SubsurfaceStructureDeduction = 0
else
cmp.SubsurfaceStructureDeduction = (20 + -1 * subsurfaceFibre ) / (1 + 0.1 *  subsurfaceFibre)
end
# subsurface substrate deduction (G) - Table 5.9
cmp.SubsurfaceSubstrateDeduction = 0 # force zero to start with to prevent errors (not in prototype)
if cmp.OrganicDepth >= 140 then cmp.SubsurfaceSubstrateDeduction = 0 
else
if cmp.SubSubsurfaceHZNMAS == "R" then cmp.SubsurfaceSubstrateDeduction = ((120 - cmp.OrganicDepth) * 0.8) + (10 + ((climatePoly.PPE) / -15)) end
if cmp.SubSubsurfaceHZNMAS == "CO" then cmp.SubsurfaceSubstrateDeduction = ((120 - cmp.OrganicDepth) * 0.7) + ( 5 + ((climatePoly.PPE) / -15)) end
if cmp.SubSubsurfaceHZNMAS == ("C" or "A") then 
if cmp.SubSubsurfaceCofrag >= 20 then 
cmp.SubsurfaceSubstrateDeduction = ((120-D)*0.6)+((climatePoly.PPE)/-15) 
else
cmp.SubsurfaceSubstrateDeduction = (((100 - cmp.OrganicDepth) * 0.6) * ((cmp.SubSubsurfaceTsilt + cmp.SubSubsurfaceTclay) / 80)) + ((climatePoly.PPE)/-15) 
end
end
end
cmp.SubsurfaceSubstrateDeduction = [cmp.SubsurfaceSubstrateDeduction,0].max
# subsurface reaction deduction (V) - Table 5.10




cmp.SubsurfaceReactionDeduction = [((6.0 - cmp.SubsurfaceReaction) * 10),0].max
# subsurface salinity deduction (N) - Table 5.11
cmp.SubsurfaceSalinityDeduction = [(-13.333333 + 3.75 * cmp.SubsurfaceSalinity + -0.10416667 * cmp.SubsurfaceSalinity ** 2),0].max
cmp.SubsurfaceMostLimitingDeduction = [cmp.SubsurfaceReactionDeduction,cmp.SubsurfaceSalinityDeduction].max
cmp.SubsurfaceTotalDeductions = cmp.SubsurfaceStructureDeduction + cmp.SubsurfaceSubstrateDeduction + cmp.SubsurfaceMostLimitingDeduction
cmp.SubsurfaceFinalDeduction = (cmp.SubsurfaceTotalDeductions.to_f / 100) * cmp.BasicOrganicRating
cmp.InterimFinalRating = cmp.BasicOrganicRating - cmp.SubsurfaceFinalDeduction
# drainage deduction (W) Tables 5.12, 5.13, 5.14
subsurfaceFibre = [cmp.SubsurfaceFibre,0].max
waterTableDepth = [cmp.WaterTableDepth,0].max
cmp.DrainagePercentDeduction = Calculate.constrain((100 - (((((climatePoly.PPE) - 150) / -150) ** 2) * (Math.sqrt(subsurfaceFibre / 10))) - (waterTableDepth * Math.sqrt(((climatePoly.PPE) - 150) / -300))),0,100)
cmp.DrainageDeduction = (cmp.DrainagePercentDeduction / 100) * cmp.InterimFinalRating
cmp.FinalSoilRating = cmp.InterimFinalRating - cmp.DrainageDeduction
cmp.SoilClass = Calculate.rating(cmp.FinalSoilRating.round) 
