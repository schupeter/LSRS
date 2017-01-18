class Assess_climate
# generic climate rating calculations, called by each crop.  Suitable_climate.rate_ppe
# =====================
# new way of calling climate calcs, by factor using a lookup hash

	# Aridity Factor
	def Assess_climate.aridity(ppe, ppe_deduct)
		aridity = AccessorsClimateAridity.new
    aridity.A = Calculate.interpolate(ppe, ppe_deduct)
    aridity.Rating = 100 - aridity.A
		return aridity
	end

	# Heat Factor (GDD + GSL)
	def Assess_climate.gdd_gsl(gdd, gdd_deduct, gsl, gsl_deduct)
		heat = AccessorsClimateHeat.new
    heat.HF1 = Calculate.interpolate(gdd, gdd_deduct)
    heat.HF2 = Calculate.interpolate(gsl, gsl_deduct)
		heat.H = Calculate.greater(heat.HF1, heat.HF2)
    heat.Rating = 100 - heat.H
		return heat
	end

	# Heat Factor (EGDD)
	def Assess_climate.egdd(egdd, egdd_deduct)
		heat = AccessorsClimateHeat.new
    heat.H = Calculate.interpolate(egdd, egdd_deduct)
    heat.Rating = 100 - heat.H
		return heat
	end

	# Heat Factor (CHU)
	def Assess_climate.chu(chu, chu_deduct)
		heat = AccessorsClimateHeat.new
		heat.H = Calculate.interpolate(chu, chu_deduct)
		heat.Rating = 100 - heat.H
		return heat
	end

	def Assess_climate.esm(esm, esm_deductions)
		Calculate.interpolate(esm, esm_deductions)
	end

	def Assess_climate.efm(efm, efm_deductions)
		Calculate.interpolate(efm, efm_deductions)
	end

	#Canola Adjustment
	def Assess_climate.canola(canhm, canhm_deductions)
		Calculate.interpolate(canhm, canhm_deductions)
	end

end

