class Climate_gdd

	def Climate_gdd.calc(station,tbase,startday,stopday,tmeandays) 
		# Calculates Growing Degree Days above the tbase temperature
		# tbase = the base temperature to use when calculating GDD
		# startday = julian day number for the first possible day to start accumulating GDD
		# stopday = julian day number for the last possible day to accumulate GDD
		# tmeandays = number of sequential days where the temperature is below tbase that is required to stop accumulating GDD1
		# :GDD_First = Starting day (julian day number) for accumulating GDD
		# :GDD_Last = Ending day (julian day number) for accumulating GDD
		# :GDD = Growing degree days
		startindex = startday - 1
		stopindex = stopday - 1
		midsummerindex = 195
		#calculate 5 day running tmeans
		tmean5 = [nil]
		for day in station[:climate][0..3] do
			tmean5.push(day[:tmean])
		end
		for day in station[:climate][4..364] do
			tmean5.shift
			tmean5.push(day[:tmean])
			day[:tmean5] = tmean5.sum / 5.0
		end
		#calculate n day running tmeans
		tmean_n = [nil]
		for day in station[:climate][0..tmeandays-2] do
			tmean_n.push(day[:tmean])
		end
		for day in station[:climate][tmeandays-1..364] do
			tmean_n.shift
			tmean_n.push(day[:tmean])
			day[:tmean_n] = tmean_n.sum / tmeandays.to_f
		end
		if station[:climate][4..midsummerindex].index{|day| day[:tmean5] > 5.0} != nil then
			#determine GDD start and end dates
			gdd_startindex = midsummerindex - station[:climate][4..midsummerindex].reverse.index{|day| day[:tmean5] < 5.0} + 1
			gdd_endindex = midsummerindex + station[:climate][midsummerindex..364].index{|day| day[:tmean5] < 5.0} - 1
			#calculate daily GDD values
			for day in station[:climate][gdd_startindex..gdd_endindex] do
				day[:gdd] = [day[:tmean] - tbase,0.0].max
			end
			#calculate summary GDD values
			gddHash = Hash.new
			gddHash[:GDD_First] = gdd_startindex + 1
			gddHash[:GDD_Last] = gdd_endindex + 1
			gddHash[:GDD_Length] = gddHash[:GDD_Last] - gddHash[:GDD_First] + 1
			gddHash[:GDD] = station[:climate].map{|day| day[:gdd]}.compact.sum.round(0)

			# for forages, GDDF should include intermittent periods (start at earliest, go to latest day with running mean above 5 degrees
			gddf_startindex = station[:climate][4..midsummerindex].index{|day| day[:tmean5] > 5.0} + 4
			gddf_endindex = 365 - station[:climate][midsummerindex..364].reverse.index{|day| day[:tmean5] > 5.0} - 1
			#calculate daily GDDF values
			for day in station[:climate][gddf_startindex..gddf_endindex] do
				day[:gddf] = [day[:tmean] - tbase,0.0].max
			end
			#calculate summary GDD values
			gddHash[:GDDF_First] = gddf_startindex + 1
			gddHash[:GDDF_Last] = gddf_endindex + 1
			gddHash[:GDDF_Length] = gddHash[:GDDF_Last] - gddHash[:GDDF_First] + 1
			gddHash[:GDDF] = station[:climate].map{|day| day[:gddf]}.compact.sum.round(0)
		else
			gddHash = {:GDD_First=>nil, :GDD_Last=>nil, :GDD_Length=>nil, :GDD=>0, :GDDF_First=>nil, :GDDF_Last=>nil, :GDDF_Length=>nil, :GDDF=>0}
		end
		return gddHash
	end

end
