class Climate_egdd

	def Climate_egdd.dailyrange(climateArray,startday,cracks5day,stopday) 
		# Calculates Effective Growing Degree Days above 5 degrees: from 10 days after tmean stays above 5 until the first fall frost
		# earliest = julian day number for the first possible day to start the waiting period for accumulating EGDD
		# latest = julian day number for the last possible day to accumulate EGDD
		# :GDD_First = Starting day (julian day number) for accumulating EGDD
		# :GDD_Last = Ending day (julian day number) for accumulating EGDD
		startindex = startday - 1
		stopindex = stopday - 1
		cracks5index = cracks5day - 1
		if cracks5index + 10 > startindex then startindex = cracks5index + 10 end
		hash = {:EGDD_First=>startindex + 1, :EGDD=>0.0,:cracks5index=>cracks5index}
		gdd2sum = 0
		for day in climateArray[startindex..stopindex] do
			if day[:daynumber] > 200 and day[:tmin] <= 0 then
				hash[:EGDD_Last] = day[:daynumber] - 1
				break
			end
		end
		if hash[:EGDD_Last] == nil then hash[:EGDD_Last] = stopday end
		return hash
	end

	def Climate_egdd.daily(climateArray, startday, stopday, lat)  
		# :EGDD = Growing degree days for northern crops
		# determine day length factor
		if lat > 49.0 then 
			if lat < 61.0  then
				dlf = -19.3257 + 1.158643*lat - 0.022107689*lat**2 + 0.0001413685*lat**3
			else
				dlf = 1.18
			end
		else
			dlf =  1.0
		end
		#return (gdd * dlf).round(0)
		for day in climateArray[startday-1..stopday-1] do
			day[:egdd] = [(day[:tmean] - 5.0) * dlf , 0].max
		end
		return climateArray
	end

=begin
	def Climate_egdd.monthly(climateArray,earliest,latest,tminJan,tminJuly, elev, lat) 
		# don't know where this calculation came from or why daily calcs won't apply
		# looks incomplete
		# probably doesn't apply zero-based array correctly
		# calculates EGDD
		cracks5 = climateArray[earliest..latest].index{|day| day[:tmean] > 5.0} 
		if cracks5 == nil then
			hash = {:EGDD_First=>nil, :EGDD_Last=>nil, :egdd_sum=>nil, :TmaxEGDD=>nil}
		else
			hash = {:EGDD_First=>[earliest, cracks5 + 10].max, :egdd_sum=>0.0}
			# estimate first fall frost 
			for day in climateArray[hash[:EGDD_First]..latest] do
				if day[:tmean] < 5.56 then  # i.e. 42 degrees F
					df42 = day[:daynumber]
					x1 = (day[:tmin] - climateArray[day[:daynumber]-29][:tmin]) * 1.8
					x2 = (tminJuly - tminJan) * 1.8
					x3 = elev *  3.2808 # i.e. convert to feet
					puts "#{day[:daynumber]} = #{day[:daylen]}"
					x4 = ((24 - day[:daylen]) ** 2 ) * (day[:tmax] - day[:tmin]) * 1.8
					lag = -32.7 + (0.769*x1) + (0.341*x2) - (0.00484*x3) + (0.00928*x4)
					fallfrost = (df42 - lag).to_i
					break
				end
			end
			hash[:EGDD_Last] = [latest,fallfrost].min
		end
		return hash
	end
=end

end
