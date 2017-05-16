class Validate
	# ensure that parameters are reasonable values
	
	def Validate.climate_params(params, climate, errors)
		if params.has_key?(:ppe) then
			climate.PPE = params[:ppe].to_i
			errors.push "ppe" if not climate.PPE.between?(-2000,1000) 
		end
		if params.has_key?(:chu) then
			climate.CHU = params[:chu].to_i
			errors.push "chu" if not climate.CHU.between?(0,5000) 
		end
		if params.has_key?(:egdd) then
			climate.EGDD = params[:egdd].to_i
			errors.push "egdd" if not climate.EGDD.between?(0,5000) 
		end
		if params.has_key?(:gdd) then
			climate.GDD = params[:gdd].to_i
			errors.push "gdd" if not climate.GDD.between?(0,5000) 
		end
		if params.has_key?(:gsl) then
			climate.GSL = params[:gsl].to_i
			errors.push "gsl" if not climate.GSL.between?(0,365) 
		end
		if params.has_key?(:esm) then
			climate.ESM = params[:esm].to_i
			errors.push "esm" if not climate.ESM.between?(-1000,1000) 
		end
		if params.has_key?(:efm) then
			climate.EFM = params[:efm].to_i
			errors.push "efm" if not climate.EFM.between?(-1000,1000) 
		end
		if params.has_key?(:canhm) then
			climate.CANHM = params[:canhm].to_i
			errors.push "canhm" if not climate.CANHM.between?(0,60) 
		end
	end

	# SOIL + LANDSCAPE
	def Validate.site_params(params, site, climate, soil, landscape, errors)
		if params.has_key?(:crop) then
			site.crop = params[:crop]
			errors.push "crop" if not ["alfalfa","brome","canola","corn","soybean","sssgrain"].include?(site.crop)
		end
		if params.has_key?(:egdd) then
			climate.EGDD = params[:egdd].to_i
			errors.push "egdd" if not climate.EGDD.between?(0,5000) 
		end		
		if params.has_key?(:ppe) then
			climate.PPE = params[:ppe].to_f
			errors.push "ppe" if not climate.PPE.between?(-2000,1000) 
		end
		if params.has_key?(:soil_id) then
			soil.soil_id = params[:soil_id]
			errors.push "soilcode" if not PROVINCES.include?(soil.soil_id[0..1])
			errors.push "soilcode" if not ["A","N"].include?(soil.soil_id[10])
			errors.push "soilcode" if not soil.soil_id.size == 11
		end
		if params.has_key?(:region) then
			landscape.ErosivityRegion = params[:region]
			errors.push "region" if not ["1","2"].include?(landscape.ErosivityRegion)
		end
		if params.has_key?(:slope) then
			landscape.SlopePercent = params[:slope].to_f
			# handle SLC slope classes
			if ["A","B","C","D","E","F"].include?(params[:slope]) then
				landscape.SlopePercent = 1.0 if params[:slope] == "A"
				landscape.SlopePercent = 6.0 if params[:slope] == "B"
				landscape.SlopePercent = 12.0 if params[:slope] == "C"
				landscape.SlopePercent = 20.0 if params[:slope] == "D"
				landscape.SlopePercent = 40.0 if params[:slope] == "E"
				landscape.SlopePercent = 70.0 if params[:slope] == "F"
			end
			errors.push "slope" if not landscape.SlopePercent.between?(0,70) 
		end
		if params.has_key?(:length) then
			landscape.SlopeLength = params[:length].to_i
			# handle SLC slope length classes
			if ('A'..'Z').to_a.include?(params[:length][0]) then
				if ["H","K","R","U"].include?(params[:length]) then landscape.SlopeLength = 100 else landscape.SlopeLength = 300 end
			end
			# handle missing value
			landscape.SlopeLength = 300 if landscape.SlopeLength == -9 
			errors.push "length" if not landscape.SlopeLength.between?(5,3000) 
		end
		if params.has_key?(:stoniness) then
			# handle real decimal values
			landscape.Stoniness = params[:stoniness].to_f
			if params[:stoniness].size == 1 then
				# handle SLC stone classes
				landscape.Stoniness = 0.20 if params[:stoniness] == "S"
				landscape.Stoniness = 0.60 if params[:stoniness] == "V"
				# handle DSS stoniness classes
				landscape.Stoniness = 0.01 if params[:stoniness] == "1"
				landscape.Stoniness = 0.20 if params[:stoniness] == "2"
				landscape.Stoniness = 0.40 if params[:stoniness] == "3"
				landscape.Stoniness = 0.80 if params[:stoniness] == "4"
				landscape.Stoniness = 1.60 if params[:stoniness] == "5"
			end
			errors.push "stoniness" if not landscape.Stoniness.between?(0,1000) 
		end
	end

	def Validate.polygon(params, rating)
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
					rating.polygon.frameworkName = value
        when "POLYID"  
          rating.polygon.poly_id = value
        when "CROP"
          rating.crop = value
        when "CLIMATETABLE"
          rating.climateData.redisKey = value
        when "RESPONSE"
          rating.responseForm = value.downcase
				when "MANAGEMENT"
					rating.management = value
      end
    end
	end

	def Validate.polygonbatch(params, request, batch)
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
					batch.frameworkName = value
          batch.cmpTableName = value.delete("~") + "_cmp"
        when "FROMPOLY"  
          batch.fromPoly = value
        when "TOPOLY"  
          batch.toPoly = value
        when "REGION"
          batch.region = value
        when "CROP"
					if VALID_CROPS.keys.include?(value) then
						batch.crop = value
						batch.cropHash.store("CROP", value)
					else
						batch.errors.push "crop name"
					end
        when "RESPONSEFORM"
          if value == "xml" then batch.view = "xml" end
        when "CLIMATETABLE"
          batch.climateTableName = value
				when "MANAGEMENT"
					batch.management = value
      end # case
    end # params
		# set defaulits
		batch.management = "basic" if batch.management != "improved"
		#batch.view = "html" if batch.view == nil
		batch.region = "all" if batch.region == nil and batch.toPoly == nil
		batch.host = request.host
	end

end