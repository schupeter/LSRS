class LsrsController < ApplicationController

# basic url is http://foo.bar/lsrs/service

# assumes 
#  a component table in MySQL identified by WarehouseName (@cmpTableName)
#  climate data available by SL, currently fixed.  Will be gridded in the future.
#  

  def service
    # initialize request parameters to prevent errors during subsequent testing
    @polygonHash = Hash.new
    @cropHash = Hash.new

# standardize request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
					@frameworkName = value
          @cmpTableName = value.capitalize.delete("~") + "_cmp"
        when "POLYID"  
          @polyId = value
#          @polygonHash.store("SL", value)
        when "CROP"
          @crop = value
          @cropHash.store("CROP", value)
        when "CLIMATETABLE"
          @climateTableName = value.capitalize
        when "RESPONSE"
          @response = value
				when "MANAGEMENT"
					@management = value
      end # case
    end # params
		if @management != "improved" then @management = "basic" end

    # validate request parameters are present and valid
    if !(defined? @cmpTableName) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "FrameworkName"; render :action => 'Error_response', :layout => false and return and exit 1 end
    if !(defined? @polyId) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "PolyId"; render :action => 'Error_response', :layout => false and return and exit 1 end
    if !(defined? @crop) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "Crop"; render :action => 'Error_response', :layout => false and return and exit 1 end
    if !(defined? @climateTableName) then @exceptionCode = "MissingParameterValue"; @exceptionParameter = "ClimateTable"; render :action => 'Error_response', :layout => false and return and exit 1 end
    if !(defined? @response) then @response = "Details" end # default behaviour
    # crop record
    if (Lsrs_climateparam.where(:crop=>@crop).size !=  1 ) then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "CROP"; @exceptionParameterValue = @crop; render :action => 'Error_response', :layout => false and return and exit 1 end
    # component table
    @cmpTableMetadata = LsrsCmp.where("WarehouseName"=>@cmpTableName).first
    if @cmpTableMetadata ==  nil then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "FrameworkName"; @exceptionParameterValue = @cmpTableName; render :action => 'Error_response', :layout => false and return and exit 1 end
    @databaseTitle = @cmpTableMetadata.Title_en
    # climate table
    @climateTableMetadata = LsrsClimate.where("WarehouseName" => @climateTableName).first
    if @climateTableMetadata ==  nil then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "ClimateTable"; @exceptionParameterValue = @climateTableName; render :action => 'Error_response', :layout => false and return and exit 1 end
    @climateTitle = @climateTableMetadata.Title_en # FIX THIS to properly support climate delivered via XML

    # set and validate some parameters
    # if component table or climate table are based on the SLC, then use the appropriate SLC poly_id
    if @cmpTableMetadata.FrameworkURI[0..35] == "http://sis.agr.gc.ca/cansis/nsdb/slc" then
      @slcCmp = true
      @landscapeId = @polyId
      @climateId = @polyId
    elsif @climateTableMetadata.FrameworkURI[0..35] == "http://sis.agr.gc.ca/cansis/nsdb/slc" then #cmp is not based on SLC, but climatetable is based on SLC
      patRecord = eval(@cmpTableMetadata.PolygonRatingTable.capitalize).where(:poly_id => @polyId).first
      if patRecord != nil then
        @landscapeId = patRecord.slc_v3r2.to_s
        @climateId = @landscapeId
      else
				@exceptionCode = "InvalidParameterValue"; @exceptionParameter = "PolyId"; @exceptionParameterValue = @polyId; @exceptionText = "Polygon identifier not found (@65)"; render :action => 'Error_response', :layout => false and return and exit 1
      end
    else # cmp and climate data not SLC, must use CMP poly_id to obtain climatetable data
      patRecord = eval(@cmpTableMetadata.PolygonRatingTable.capitalize).where(:poly_id => @polyId).first
      if patRecord != nil then
        @landscapeId = patRecord.poly_id
        @climateId = @landscapeId
      else
				@exceptionCode = "InvalidParameterValue"; @exceptionParameter = "PolyId"; @exceptionParameterValue = @polyId; @exceptionText = "Polygon identifier not found (@73)"; render :action => 'Error_response', :layout => false and return and exit 1
      end
    end

    # prepare to get inputs
    require "#{Rails.root.to_s}/app/helpers/libxml-helper"
    require "open-uri"
    #prepare to calculate

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
		@tableMetadata = LsrsClimate.where(:WarehouseName=>@climateTableName)
		if (@tableMetadata.size == 0) then # request parameter missing, so return error
			@exceptionCode = "InvalidParameterValue"
			@exceptionParameter = "TABLE_NAME"
			@exceptionParameterValue = @climateTableName
			render :action => 'Error_response', :layout => false and return and exit 1
    end
    @climatePoly = eval(@tableMetadata[0].WarehouseName.capitalize).where(:poly_id=>@climateId).first
		if (@climatePoly == nil) then # climate data missing, so return error
			@exceptionCode = "No Climate Data"
			@exceptionParameter = "PolyId"
			@exceptionParameterValue = @polyId
			@exceptionText = "No climate data found for climate identifier #{@climateId}"
			render :action => 'Error_response', :layout => false and return and exit 1
    end
    climateParams = Lsrs_climateparam.where(@cropHash)
    @climateCoeff = Rate_climate.params(climateParams)
    @climate = Rate_climate.calc(@climatePoly, @climateCoeff)

    # get landscape inputs (available only by SL)
    if @slcCmp == true then
			@landscapePoly = Slc_v3r0_canada_climate1961x90uvic.where(:poly_id=>@polyId).first
    else
			@landscapePoly = eval(@climateTableName).where(:poly_id=>@landscapeId).first
    end
    
    # get soil components 
    @componentHash = Hash.new
    @componentHash.store("poly_id", @polyId)
    @componentsCmp = eval(@cmpTableName).where(@componentHash)
    if @componentsCmp == [] then @exceptionCode = "InvalidParameterValue"; @exceptionParameter = "PolyId"; @exceptionParameterValue = @polyId; @exceptionText = "Polygon not found in CMP table"; render :action => 'Error_response', :layout => false and return and exit 1 end

    # prepare to calculate LSRS ratings
    mineralParams = LsrsMineralparam.where(@cropHash)
    @mineralCoeff = Mineral.params(mineralParams)
    organicParams = LsrsOrganicparam.where(@cropHash)
    @organicCoeff = Organic.params(organicParams)
    @soilHash = Hash.new
    @lsrsArray = Array.new

    # calculate LSRS ratings for each soil component
    for component in @componentsCmp do
      # initialize cmp
      if @slcCmp == true then cmp = Landscape.inputsSLC(component) else cmp = Landscape.inputsDSS(component) end
      # calculate soil ratings     
      #Retrieve records from SNF and SLF using Profile = A
			@soilHash.store("province", component.province)
			@soilHash.store("soil_code", component.soil_code)
			@soilHash.store("modifier", component.modifier)
      @soilHash.store("profile", "A")
      @nameRecords = eval("Soil_name_"+component.province.downcase+"_v2").where(@soilHash)
      cmp.nameData = false
      cmp.layerData = false
      if @nameRecords.size > 0 then
        cmp.nameData = true
        @layerRecords = eval("Soil_layer_"+component.province.downcase+"_v2").where(@soilHash).sort_by { |x| x.layer_no }
        if @layerRecords.size > 0 then
          cmp.layerData = true
        end
      end
      if cmp.layerData == false then
        # no SNF hits, so try Profile = N
        @soilHash.store("profile", "N")
				@nameRecords = eval("Soil_name_"+component.province.downcase+"_v2").where(@soilHash)
        if @nameRecords.size > 0 then
          cmp.nameData = true
          @layerRecords = eval("Soil_layer_"+component.province.downcase+"_v2").where(@soilHash).sort_by { |x| x.layer_no }
          if @layerRecords.size > 0 then
            cmp.layerData = true
          end
        end
      end
      #if @layerRecords.size == 0 then @exceptionCode = "SOIL NAME IDENTIFIER NOT FOUND"; @exceptionParameter = "SOIL_ID"; @exceptionParameterValue = component.soil_id; render :action => 'Error_response', :layout => false and return and exit 1 end
      # SNF/SLF records should have been retrieved.  Start remaining calculations.
      if cmp.layerData == true
				if @management == "improved" then 
					#manageBySoil = SoilManagement.where(:soil_id => cmp.soil_id).first # deleted 20151027
					manageByCrop = CropManagement.where(:crop=>@crop).first
					#if manageBySoil then cmp.ManagedWaterTableDepth = manageBySoil.watertabledepth end # deleted 20151027
				end
        if @nameRecords[0].order3 == "OR" then
          # organic component
          if @nameRecords[0].g_group3 == "FO" and @nameRecords[0].s_group3 == "HU" then # process as pseudo mineral (not rated) Bug 28
            cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
            cmp = Mineral.horizonsSLC(cmp, @layerRecords, @climatePoly)
            cmp = Mineral.NotSoil(cmp)
          else # process as normal organic
            cmp = Organic.inputsSLC(cmp, @nameRecords[0])
            cmp = Organic.horizonsSLC(cmp, @layerRecords)
            #if @management == "improved" then cmp = Organic.management(cmp, manageBySoil, manageByCrop) end# deleted 20151027
            if @management == "improved" then cmp = Organic.management(cmp) end
            cmp = Organic.calc(cmp, @climatePoly, @organicCoeff)
          end
        elsif @nameRecords[0].order3 == "-" then
          # pseudo mineral component (not rated)
          cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
          cmp = Mineral.horizonsSLC(cmp, @layerRecords, @climatePoly)
          cmp = Mineral.NotSoil(cmp)
        else
          # true mineral component
          cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
          cmp = Mineral.horizonsSLC(cmp, @layerRecords, @climatePoly)
          cmp = Mineral.validateHorizons(cmp)
          #if @management == "improved" then cmp = Mineral.management(cmp, manageBySoil, manageByCrop) end # deleted 20151027
          if @management == "improved" then cmp = Mineral.management(cmp, manageByCrop) end
          cmp = Mineral.calc(cmp, @climatePoly, @mineralCoeff, DEDUCTIONS[@crop])
        end
      elsif @nameRecords[0] then
        # pseudo mineral component (without layer info)
        cmp = Mineral.inputsSLC(cmp, component, @nameRecords[0])
        cmp = Mineral.NotSoil(cmp)
			else
				# missing name record
				cmp = Mineral.inputsFake(cmp)
        cmp = Mineral.NotSoil(cmp)
      end
			if @nameRecords[0] then
				# populate SNF content
				cmp = Soilname.attributes(cmp, @nameRecords[0])
			end
      # calculate landscape ratings
      @cropLandscapeModel = Landscape.model(@crop, @landscapePoly.ErosivityRegion, cmp.LandscapeComplexity)
      @landscape = Landscape.calc(cmp, @landscapePoly, @cropLandscapeModel, @crop)
      # populate lsrsArray 
      @lsrsArray.push cmp
    end # of components
    
    # Create aggregate rating
    # STEP 1: Assign Components to Categories
    category = Aggregate4.Categorize(@lsrsArray)
    # STEP 2: Summarize the special Not Rated category
    percentNotRated = Aggregate4.NotRated(category.NotRated)
    # STEP 3: Summarize the normal categories:
    drainageFactorHash = Aggregate4.Soil(category.Drainage)
    dominantFactorHash = Aggregate4.Soil(category.Dominant)
    dissimilarFactorHash = Aggregate4.Soil(category.Dissimilar)
    
    # STEP 4: Determine the class number 
    # assign climate factor rating
    drainageFactorHash['ClimateRating'] = @climate.Value.round
    dominantFactorHash['ClimateRating'] = @climate.Value.round
    dissimilarFactorHash['ClimateRating'] = @climate.Value.round
    # determine most limiting factor and calculate class
    drainageFactorHash = Aggregate4.MostLimitingFactor(drainageFactorHash)
    dominantFactorHash = Aggregate4.MostLimitingFactor(dominantFactorHash)
    dissimilarFactorHash = Aggregate4.MostLimitingFactor(dissimilarFactorHash)
    
    # STEP 5: Aggregate4 the subclass values (do this before step 4 to initialize *SubfactorHash easily)
    # Step 5.1: Calculate weighted average for soil and landscape factors
    drainageSubfactorHash = Aggregate4.SummarizeSubfactors(category.Drainage, drainageFactorHash['Percent'])
    dominantSubfactorHash = Aggregate4.SummarizeSubfactors(category.Dominant, dominantFactorHash['Percent'])
    dissimilarSubfactorHash = Aggregate4.SummarizeSubfactors(category.Dissimilar, dissimilarFactorHash['Percent'])
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
    drainageSubfactorHash = Aggregate4.DropBelow20(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate4.DropBelow20(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate4.DropBelow20(dissimilarSubfactorHash)
    # Step 6.2 drop A and H if climate is not the most limiting factor
    drainageSubfactorHash = Aggregate4.DropAH(drainageSubfactorHash, drainageFactorHash)
    dominantSubfactorHash = Aggregate4.DropAH(dominantSubfactorHash, dominantFactorHash)
    dissimilarSubfactorHash = Aggregate4.DropAH(dissimilarSubfactorHash, dissimilarFactorHash)
    # Step 6.3  drop A or M if both are present
    drainageSubfactorHash = Aggregate4.DropAM(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate4.DropAM(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate4.DropAM(dissimilarSubfactorHash)
    # Step 6.4  drop less significant subclasses
    # Step 6.4.1  within factor comparison
    drainageSubfactorHash = Aggregate4.DropWithinFactor(drainageSubfactorHash)
    dominantSubfactorHash = Aggregate4.DropWithinFactor(dominantSubfactorHash)
    dissimilarSubfactorHash = Aggregate4.DropWithinFactor(dissimilarSubfactorHash)
    # Step 6.4.2  between factor comparison
    drainageSubfactorHash = Aggregate4.DropOtherFactors(drainageSubfactorHash, drainageFactorHash)
    dominantSubfactorHash = Aggregate4.DropOtherFactors(dominantSubfactorHash, dominantFactorHash)
    dissimilarSubfactorHash = Aggregate4.DropOtherFactors(dissimilarSubfactorHash, dissimilarFactorHash)
    # Step 6.5 determine primary subclass
    drainageFactorHash = Aggregate4.PrimarySubclass(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate4.PrimarySubclass(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate4.PrimarySubclass(dissimilarSubfactorHash, dissimilarFactorHash)
    # determine remaining subclasses
    drainageFactorHash = Aggregate4.AdditionalSubclasses(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate4.AdditionalSubclasses(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate4.AdditionalSubclasses(dissimilarSubfactorHash, dissimilarFactorHash)

    # STEP 7: Create Category Ratings
    drainageFactorHash = Aggregate4.FinalClass(drainageSubfactorHash, drainageFactorHash)
    dominantFactorHash = Aggregate4.FinalClass(dominantSubfactorHash, dominantFactorHash)
    dissimilarFactorHash = Aggregate4.FinalClass(dissimilarSubfactorHash, dissimilarFactorHash)
    
    # STEP 8: Create a Composite Rating
    # calculate deciles
    decileArray = Calculate.perdecim([drainageFactorHash['Percent'], dominantFactorHash['Percent'], dissimilarFactorHash['Percent'], percentNotRated])
    drainageFactorHash['PerDecim']  = decileArray[0]
    dominantFactorHash['PerDecim'] = decileArray[1]
    dissimilarFactorHash['PerDecim'] = decileArray[2]
    perdecimNotRated = decileArray[3]
    # create rating
    @lsrsRating = Aggregate4.rating(drainageFactorHash,dominantFactorHash,dissimilarFactorHash,perdecimNotRated)

    #Render results as XML
    case @response 
      when "Rate" then render :action => 'OutputRate', :layout => false and return and exit 1
      when "Components" then render :action => 'OutputComponents', :layout => false and return and exit 1
      else render :action => 'OutputDetails', :layout => false and return and exit 1
    end
    
  end
  
  def client
    params.each do |key, value|      # standardize request parameters
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
          @frameworkName = value
					@cmpTable = value.delete("~") + "_cmp"
					@patTable = value.delete("~").capitalize + "_pat"
      end # case
    end # params
    if !(defined? @frameworkName) or @frameworkName == "" then
      @step = 1
      @soilDatasets = LsrsCmp.order("Title_en ASC")
    else
      @step = 2
      @soilDataset = LsrsCmp.where(:WarehouseName=>@cmpTable).first
      @climateTables = LsrsClimate.where('PolygonTable like ? or PolygonTable like ?',@soilDataset.DSSClimatePolygonTable,@soilDataset.SLCClimatePolygonTable).order("Title_en")
      @crops = Lsrs_crop.all
    end
    render
  end

  def Index
    render
  end
end
