class Fieldcrop1

 	def Fieldcrop1.rate_soil(params, site)
		MineralPrep.inputsSLC(site.soil)
		MineralPrep.generalize_layers(site.soil, site.climate.PPE)
		MineralPrep.validate_values(site.soil)
		@cropHash = Hash.new
		@cropHash.store("CROP", site.crop)
		mineralParams = LsrsMineralparam.where(@cropHash)
		@mineralCoeff = Mineral.params(mineralParams)
		MineralFormulas.mineral(site.soil, site.climate.PPE, @mineralCoeff, DEDUCTIONS[site.crop])
	end

	def Fieldcrop1.rate_landscape(params, site)
		Landscape.model_v5(site.crop, site.landscape)
		Landscape.slopeFactor(site.crop, site.landscape)
		Landscape.fragmentsFactor(site.crop, site.soil, site.landscape)
		Landscape.otherFactors(site.crop, site.landscape)
	end

end
