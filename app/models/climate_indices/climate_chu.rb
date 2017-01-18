class Climate_chu

	def Climate_chu.dailyrange(climateArray,stopday)
		# Calculates start and stop dates for accumulating Crop Heat Units
		# :CHU_First = Starting day (julian day number) for accumulating CHU
		# :CHU_Last = Ending day (julian day number) for accumulating CHU
		midsummerindex = 195
		stopindex = stopday - 1
		hash = {:CHU_First=>nil, :CHU_Last=>nil}
		# determine CHU_First
		streak = 0
		for day in climateArray do
			if day[:tmean] >= 12.8 then streak += 1 else streak = 0 end
			if streak == 3 then
				hash[:CHU_First] = day[:daynumber]
				break
			end
		end
		# determine CHU_Last
		chu_fallindex = climateArray[midsummerindex..stopindex].index{|day| day[:tmin] < 0.0}
		if chu_fallindex == nil then hash[:CHU_Last] = stopindex + 1  else hash[:CHU_Last] = midsummerindex + chu_fallindex end
		return hash
	end

	def Climate_chu.startstreak(climateArray,earliestday,springtmean,streaklength)
		# determine starting day (julian day number) for accumulating CHU based on a streak of days above a given temperature
		start = 195
		streak = 0
		for day in climateArray[earliestday..195] do
			if day[:tmean] >= springtmean then streak += 1 else streak = 0 end
			if streak == streaklength then
				start = day[:daynumber]
				break
			end
		end
		return start
	end

	def Climate_chu.startmean(climateArray,earliestday,springtmean,normalThreshold)
		# determine starting day (julian day number) for accumulating CHU based on a running mean of temperatures rising above a threshold,
		# and a normals threshold being surpassed
		start = 195
		condition1 = false
		condition2 = false
		for day in earliestday..195 do
			if climateArray[day][:t10ave] >= normalThreshold then condition1 = true end
			if climateArray[day][:tmean_n] >= springtmean then condition2 = true end
			if condition1 and condition2 then
				start = climateArray[day][:daynumber]
				break
			end
		end
		return start
	end

	def Climate_chu.startmonthly(climateArray,earliestday,threshold)
		# determine starting day (julian day number) for accumulating CHU based on a mean daily air temperatures rising above a threshold,
		start = 195
		for day in earliestday..195 do
			if climateArray[day][:tmean] >= threshold then 
				start = climateArray[day][:daynumber]
				break
			end
		end
		return start
	end

	def Climate_chu.stopmean(climateArray,lastday,falltmean,normalThreshold,tmin)
		# determine stopping day (julian day number) for accumulating CHU, based on a running mean of temperatures falling below a threshold
		stop = lastday
		condition = false
		for day in 195..lastday do
			if climateArray[day][:tmean_n] <= falltmean then condition = true end
			if climateArray[day][:tmin] <= tmin then condition = true end
			if climateArray[day][:t10min] <= normalThreshold then condition = true end
			if condition then
				stop = climateArray[day][:daynumber] - 1
				break
			end
		end
		return stop
	end

	def Climate_chu.stopmin(climateArray,lastday,falltmin)
		# determine stoping day (julian day number) for accumulating CHU, based on a single occurence of a minimum temperature
		stop = lastday
		for day in 195..lastday do
			if climateArray[day][:tmin] <= falltmin then
				stop = climateArray[day][:daynumber] - 1
				break
			end
		end
		return stop
	end

	def Climate_chu.stopmonthly(climateArray,threshold)
		# determine starting day (julian day number) for accumulating CHU based on a mean daily air temperatures dropping below a threshold,
		stop = 196
		for day in 196..364 do
			if climateArray[day][:tmean] <= threshold then 
				stop = climateArray[day][:daynumber] -1
				break
			end
		end
		return stop
	end

	def Climate_chu.calculate(climateArray,startday,stopday,chuname)
		# calculate CHU during flowering period
		for day in climateArray[startday-1..stopday-1] do
			if day[:tmax] < 10.0 then 
				yMax = 0.0 
			else 
				yMax = (3.33 * (day[:tmax] - 10.0)) - (0.084 * ((day[:tmax] - 10.0) ** 2))
			end
			if day[:tmin] < 4.44 then 
				yMin = 0.0 
			else 
				yMin = 1.8 * (day[:tmin] - 4.44) 
			end
			day[chuname.to_sym] = (yMax + yMin) / 2.0
		end
		return climateArray
	end

	def Climate_chu.thresholds(lat,long)
		#The thresholds array contains the following information:
		#:lat_min, :lat_max, :long_min, :long_max
		#Latitude and longitude ranges (decimal degrees N and W).  Each row in the file must represent a unique area with no overlap.  Stations or grid point with co-ordinates outside the areas represented will not be analyzed.  Longitude ranges must be negative values.
		#:start_temp, :stop_temp
		#Start and Stop temperatures (°C).  These are threshold temperatures used to determine starting (Start_CHU) and ending dates (Stop_CHU) for accumulating CHU.  Values in the sample file have been appropriately calibrated for each region of Canada.  The start temperature is the threshold value of the mean daily air temperature that must be exceeded and is an estimate of the average planting date of corn in each region. Threshold temperatures estimate the average planting date of corn and presently vary from 8.8 to 12.7 ºC for different regions across Canada.  The stop temperature is the threshold value of the mean daily minimum air temperature that must be reached, and is an estimate of the 10% probability date of first fall freeze (-2ºC) and the average date of first fall frost (0ºC).  The stop temperature thresholds presently vary from 3.7 to 6.5 ºC for different regions across Canada. 
		#:chuave_const, :chuave_coeff
		#The constants and coefficients for the regression equations used to estimate CHUave from CHU2normal.  The equation is of the form
		#           			CHUAve = a0 + a1*CHU2normal.  
		#The constant (a0) and coefficient (a1) values must be entered in the input threshold file as input into the program.  Appropriate values have been developed for most regions as shown in the sample file below by comparing CHUnormal values determined from 30-year climate normals data with average CHU values determined annually using daily climate data using start and end criteria unique to each region of Canada.  However, these could be further refined in future.  The adjustment is needed so that the CHU values calculated from normals data corresponds closely to CHU values determined on an annual basis using daily climate. 
		#
		#:chu80_const, :chu80_coeff
		#The constants and coefficients for the regression equations used to estimate CHU80%.  The equation is of the form:
		#             		CHU80% = b0 + b1*CHU2normal
		#The constant (b0) and coefficient (b1) have been calibrated by comparing CHUnormal values determined from 30-year climate normals data with CHU exceeded at the 80% probability determined by computing CHU annually using daily climate data using start and end criteria unique to each region of Canada. However, these could be further refined in future. 
		thresholds = [
{:lat_min=>46.000, :lat_max=>66.00, :long_min=>-59.5, :long_max=>-51.00, :start_temp=>8.8, :stop_temp=>3.7, :chuave_const=>164.96, :chuave_coeff=>0.9465, :chu80_const=>-207.54, :chu80_coeff=>1.0342},
{:lat_min=>42.000, :lat_max=>47.95, :long_min=>-68.0, :long_max=>-59.50, :start_temp=>11.0, :stop_temp=>5.8, :chuave_const=>185.20, :chuave_coeff=>0.9377, :chu80_const=>-11.80, :chu80_coeff=>0.9538},
{:lat_min=>44.000, :lat_max=>47.95, :long_min=>-74.2, :long_max=>-68.05, :start_temp=>12.8, :stop_temp=>6.5, :chuave_const=>157.45, :chuave_coeff=>0.9194, :chu80_const=>37.55, :chu80_coeff=>0.9297},
{:lat_min=>47.951, :lat_max=>66.00, :long_min=>-79.0, :long_max=>-59.55, :start_temp=>12.8, :stop_temp=>6.5, :chuave_const=>157.45, :chuave_coeff=>0.9194, :chu80_const=>37.55, :chu80_coeff=>0.9297},
{:lat_min=>40.000, :lat_max=>47.95, :long_min=>-95.0, :long_max=>-74.01, :start_temp=>12.8, :stop_temp=>6.5, :chuave_const=>177.82, :chuave_coeff=>0.9150, :chu80_const=>68.62, :chu80_coeff=>0.9020},
{:lat_min=>47.951, :lat_max=>66.00, :long_min=>-95.0, :long_max=>-79.01, :start_temp=>12.8, :stop_temp=>6.5, :chuave_const=>177.82, :chuave_coeff=>0.9150, :chu80_const=>68.62, :chu80_coeff=>0.9020},
{:lat_min=>48.000, :lat_max=>66.00, :long_min=>-101.5, :long_max=>-95.01, :start_temp=>11.2, :stop_temp=>5.8, :chuave_const=>212.93, :chuave_coeff=>0.9071, :chu80_const=>143.75, :chu80_coeff=>0.8436},
{:lat_min=>48.000, :lat_max=>66.00, :long_min=>-110.0, :long_max=>-101.51, :start_temp=>11.2, :stop_temp=>5.3, :chuave_const=>212.93, :chuave_coeff=>0.9071, :chu80_const=>143.75, :chu80_coeff=>0.8436},
{:lat_min=>48.000, :lat_max=>52.00, :long_min=>-115.0, :long_max=>-110.01, :start_temp=>11.2, :stop_temp=>4.9, :chuave_const=>212.93, :chuave_coeff=>0.9071, :chu80_const=>143.75, :chu80_coeff=>0.8436},
{:lat_min=>52.001, :lat_max=>66.00, :long_min=>-120.0, :long_max=>-110.01, :start_temp=>11.2, :stop_temp=>4.9, :chuave_const=>212.93, :chuave_coeff=>0.9071, :chu80_const=>143.75, :chu80_coeff=>0.8436},
{:lat_min=>48.000, :lat_max=>52.00, :long_min=>-136.0, :long_max=>-115.01, :start_temp=>12.7, :stop_temp=>4.6, :chuave_const=>343.24, :chuave_coeff=>0.8427, :chu80_const=>121.28, :chu80_coeff=>0.8545},
{:lat_min=>52.001, :lat_max=>66.00, :long_min=>-140.0, :long_max=>-120.01, :start_temp=>12.7, :stop_temp=>4.6, :chuave_const=>343.24, :chuave_coeff=>0.8427, :chu80_const=>121.28, :chu80_coeff=>0.8545},
]
		for r in thresholds do
			if lat > r[:lat_min] and lat < r[:lat_max] and long > r[:long_min] and long < r[:long_max] then 
				threshold = r
				break
			end
		end
		return threshold
	end

	def Climate_chu.ave(chuNormal, threshold)
		(threshold[:chuave_const] + threshold[:chuave_coeff] * chuNormal).round()
	end

end
