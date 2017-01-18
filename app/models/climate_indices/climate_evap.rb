class Climate_evap
	# evapotranspiration
	# :radiation is solar radiation at the top of the atmosphere

  def Climate_evap.radiation_fao(lat)
		# Calculates solar radiation at the top of the atmosphere
		# formulas are from http://www.fao.org/docrep/x0490e/x0490e07.htm#solar%20radiation
		# lat is latitude in decimal degrees
		days = Array.new
		phi = lat / 57.29578
		for nday in 1..365 do
			theta = 0.01721*nday
      delta = (0.3964 + 3.631*Math.sin(theta)-22.97*Math.cos(theta)+0.03838*Math.sin(2*theta)-0.3885*Math.cos(2*theta)+0.07659*Math.sin(3*theta)-0.1587*Math.cos(3*theta)-0.01021*Math.cos(4*theta))
      delta = delta / 57.29578
      daylen = Math.acos((-0.01454-Math.sin(phi)*Math.sin(delta))/(Math.cos(phi)*Math.cos(delta)))
      daylen = daylen*7.639
			distance = 1+(0.033*Math.cos(2*Math::PI*(nday.to_f/365)))
			declination = 0.409*Math.sin(2*Math::PI*(nday.to_f/365)-1.39)
			angle = Math.acos(-Math.tan(phi)*Math.tan(declination))
			radiation = (24*60*0.082/Math::PI)*distance*((angle*Math.sin(phi)*Math.sin(declination))+(Math.cos(phi)*Math.cos(declination)*Math.sin(angle))) * 23.89
			#days.push({:day => nday, :java => theta, :distance => distance, :declination=>declination, :angle=>angle, :phi=>phi, :radiation=>radiation })
			days.push({:daylen=>daylen,:radiation=>radiation})
		end
    return days
  end
	
	def Climate_evap.radiation(lat)
		#Calculates day length and the solar radiation in the upper atmosphere.
		# Origin and original formulas are unknown, but this approach was used to create the original Fortran, and C, and Java programs.  
		# These values are about 3% higher than the FAO formula, but results match earlier versions of this program
		# Code was translated from the C version, retaining some bizarre aspects.
		days = Array.new
		if lat < 66 then
			phi = lat / 57.29578
			photp = Array.new(366)
			rad = Array.new(13)
			nday = 1
			while nday <= 365 do
				f = 60.0
				theta = 0.01721*nday
				delta = 0.3964 + 3.631*Math.sin(theta)-22.97*Math.cos(theta)+0.03838*Math.sin(2*theta)-0.3885*Math.cos(2*theta)+0.07659*Math.sin(3*theta)-0.1587*Math.cos(3*theta)-0.01021*Math.cos(4*theta);
				delta = delta / 57.29578;
				daylen = Math.acos((-0.01454-Math.sin(phi)*Math.sin(delta))/(Math.cos(phi)*Math.cos(delta)));
				daylen = daylen*7.639;
				photp[nday] = daylen;
				r = 1.0 - 0.0009464 * Math.sin(theta) - 0.00002917 * Math.sin(3 * theta) - 0.01671 *  Math.cos(theta) - 0.0001489 * Math.cos(2 * theta) - 0.00003438 * Math.cos(4 * theta)
				ourmax = Math.acos(-0.01454 - Math.sin(phi) * Math.sin(delta) / (Math.cos(phi) * Math.cos(delta)))
				ormax = Math.acos( -Math.sin(phi) * Math.sin(delta) / (Math.cos(phi) * Math.cos(delta)))
				solar = 0.0
				oour = 0.0
				our = oour + 6.2832/24.0
				i = 1
				x = 1
				while x == 1 do
					x = 0
					cosoz = (Math.sin(phi) * Math.sin(delta)) + (Math.cos(phi) * Math.cos(delta) * Math.cos(oour))
					cosz = (Math.sin(phi) * Math.sin(delta)) + (Math.cos(delta) * Math.cos(phi) * Math.cos(our))
					rad[i] = f * 2.0 * (cosoz+cosz)/(2*r*r)
					solar = solar + 2 * rad[i]
					i += 1
					if f >= 60 then
						x = 1
						oour = our
						our = oour + 6.2832/24.0
						if our-ormax > 0 then
							our = ormax
							f = 60.0 * (ourmax-oour) * 24.0 / 6.2832
						end
					end
				end
				days.push({:daylen=>daylen,:radiation=>solar})
				nday += 1
			end
		else
			days = Array.new(365,{:daylen=>0.0,:radiation=>0.0})
		end
    return days
	end

	def Climate_evap.baier_robertson(climateArray)
		# Baier-Robertson method of calculating PE
		# adds :pe to each hash in climateArray
		for day in climateArray do
			tmaxf = day[:tmax] * 1.8 + 32
			tminf = day[:tmin] * 1.8 + 32
			day[:pe] =0.086*((0.928*tmaxf)+(0.933*(tmaxf - tminf))+(0.0486*day[:radiation]) - 87.03)
			#day[:pe] =0.094*((0.928*tmaxf)+(0.933*(tmaxf - tminf))+(0.0486*day[:radiation]) - 87.03)
			if day[:pe] < 0 then day[:pe] = 0 end
		end
		return climateArray
	end

	def Climate_evap.ppe(climateArray,start,stop)
		# calculates P-PE for a range of julian days
		ppe = 0.0
		for day in climateArray[start-1..stop-1] do
			ppe = ppe + day[:precip] - day[:pe]
		end
		return ppe
	end

	def Climate_evap.ppe_cum(climateArray,start,stop)
		# calculates cumulative P-PE for a range of julian days
		ppe = 0.0
		for day in climateArray[start-1..stop-1] do
			ppe = ppe + day[:precip] - day[:pe]
			day[:ppe_cum] = ppe
		end
		return climateArray
	end

end
