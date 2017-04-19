class Climate_canolaheat
# calculate Canola Heat during flowering period

	def Climate_canolaheat.daily(climateArray,startday,stopday)
		egdd_sum = 0
		days_over_30 = 0
		for day in climateArray[startday-1..stopday-1] do
			egdd_sum += day[:egdd]
			if egdd_sum > 600 and egdd_sum < 1100 and day[:tmax] > 30 then days_over_30 += 1 end
		end
		return days_over_30
	end

	def Climate_canolaheat.tmax_egdd(climateArray,startday,stopday)
		canolaFloweringTemperatures = climateArray[startday-1..stopday-1].map{|day| day[:tmax]}
		if canolaFloweringTemperatures.size > 0 then
			tmaxEGDD = (canolaFloweringTemperatures.sum / canolaFloweringTemperatures.size).round(1)
		else
			tmaxEGDD = -99
		end
		return tmaxEGDD
	end

	def Climate_canolaheat.canhm(tmaxEGDD)
		if tmaxEGDD < 19 then
			canhm = 0.0
		elsif tmaxEGDD > 32 then
			canhm = -99
		else
			canhm = ((0.11551 * (tmaxEGDD ** 2)) - (4.37124 * tmaxEGDD) + 41.54).round(1)
		end
		return canhm
	end

	def Climate_canolaheat.egdd_sum(climateArray,egdd_first,threshold)
		egdd_sum = 0
		daynumber = nil
		for day in climateArray[egdd_first..-1] do
			if day[:egdd] == nil then break else egdd_sum += day[:egdd] end
			if egdd_sum >= threshold then 
				daynumber = day[:daynumber]
				break 
			end
		end
		return daynumber
	end

end
