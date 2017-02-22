class Landscape

  def Landscape.model(crop, region, landscape)
		# LSRSv4
    if crop == "alfalfa" or crop == "brome" then
      model = "perennial" 
    else # crop is: canola, corn, soybeans, sssgrain
      if region == "1" then 
        model = "annual1" 
      else # region is: 2
        if landscape == "simple" then
          model = "annual1"
        else # landscape is: complex
          model = "annual2"
        end
      end
    end
    return model
  end

	def Landscape.model_v5(crop, landscape)
		# LSRSv5
   	if (landscape.SlopeLength <= 200) then landscape.Complexity = "complex" else landscape.Complexity = "simple" end
    if crop == "alfalfa" or crop == "brome" then
      landscape.Model = "perennial" 
    else # crop is: canola, corn, soybeans, sssgrain
      if landscape.ErosivityRegion == "1" then  
        landscape.Model = "annual1" 
      else # erosivity region is: 2
        if landscape.Complexity == "simple" then
          landscape.Model = "annual1"
        else # landscape is: complex
          landscape.Model = "annual2"
        end
      end
    end
	end

  def Landscape.inputsSLC(component)
		# LSRSv4
    # Calculate rating inputs.
    cmp = Lsrs_cmp_class.new
    cmp.soil_id = component.soil_id
    cmp.cmp = component.cmp
    cmp.percent = component.percent
    # Determine SLP50
    cmp.slopeClass = component.slope
    #slp50
    if (cmp.slopeClass == "A") then cmp.slp50 = 1 end
    if (cmp.slopeClass == "B") then cmp.slp50 = 6 end
    if (cmp.slopeClass == "C") then cmp.slp50 = 12 end
    if (cmp.slopeClass == "D") then cmp.slp50 = 20 end
    if (cmp.slopeClass == "E") then cmp.slp50 = 40 end
    if (cmp.slopeClass == "F") then cmp.slp50 = 70 end
    # Determine slopeLength for NSDB. Use this to set Simple or Complex landform.
    cmp.locsf = component.locsf
    cmp.slopeLength = 300
    if (component.locsf == "H") then cmp.slopeLength = 100 end
    if (component.locsf == "K") then cmp.slopeLength = 100 end
    if (component.locsf == "R") then cmp.slopeLength = 100 end
    if (component.locsf == "U") then cmp.slopeLength = 100 end
   	if (cmp.slopeLength <= 200) then cmp.LandscapeComplexity = "complex" else cmp.LandscapeComplexity = "simple" end
    # Determine StoninessValue.
    cmp.stoninessValue = 0.00
    if (component.stone == "S") then cmp.stoninessValue = 0.20 end
    if (component.stone == "V") then cmp.stoninessValue = 0.60 end

    if (cmp.order != "OR") then
      cmp.SurfaceWood = 0
      cmp.SubsurfaceWood = 0
    end
    cmp.LandscapePattern = 0
    cmp.LandscapeFloodingFreq = 1
    cmp.LandscapeFloodingPeriod = 1
    return cmp
  end
  
  def Landscape.inputsDSS(component)
		# LSRSv4
    # Calculate rating inputs.
    cmp = Lsrs_cmp_class.new
    cmp.soil_id = component.soil_id
    cmp.cmp = component.cmp
    cmp.percent = component.percent
    # Determine SLP50
    cmp.slp50 = component.slope_p
    # SlopeLength
    cmp.slopeLength = component.slope_len
   	if (cmp.slopeLength <= 200) then cmp.LandscapeComplexity = "complex" else cmp.LandscapeComplexity = "simple" end
    # Determine StoninessValue.
#    cmp.stoninessValue = component.stoniness
    cmp.stoninessValue = 0.00
    if component.stoniness == "1" then cmp.stoninessValue = 0.01 end 
    if component.stoniness == "2" then cmp.stoninessValue = 0.20 end 
    if component.stoniness == "3" then cmp.stoninessValue = 0.40 end 
    if component.stoniness == "4" then cmp.stoninessValue = 0.80 end 
    if component.stoniness == "5" then cmp.stoninessValue = 1.60 end 
    # other
    if (cmp.order != "OR") then
      cmp.SurfaceWood = 0
      cmp.SubsurfaceWood = 0
    end
    cmp.LandscapePattern = 0
    cmp.LandscapeFloodingFreq = 1
    cmp.LandscapeFloodingPeriod = 1
    return cmp
  end
  
  def Landscape.calc(cmp, poly, slopeFactorModel, crop)
		# LSRSv4
    #Slope Factor
    case slopeFactorModel
      when "perennial" then 
        cmp.LandscapeSlopeDeductionRaw = (-0.0398 * cmp.slp50 ** 2) + (4.1717 * cmp.slp50) - 17.356  # quadratic equation
      when "annual1" then
        cmp.LandscapeSlopeDeductionRaw = (0.0005 * cmp.slp50 ** 3) - (0.0886 * cmp.slp50 ** 2) + (4.898 * cmp.slp50)
      when "annual2" then
        cmp.LandscapeSlopeDeductionRaw = (0.0014 * cmp.slp50 ** 3) - (0.1519 * cmp.slp50 ** 2) + (5.9183 * cmp.slp50)
        # cmp.LandscapeSlopeDeductionRaw = (-0.0003 * cmp.slp50 ** 4) + (0.0202 * cmp.slp50 ** 3) - (0.5738 * cmp.slp50 ** 2) + (9.7283 * cmp.slp50) - 0.7624 # removed October 31, 2012
        # cmp.LandscapeSlopeDeductionRaw = coeff.Sa + coeff.Sb * cmp.slp50 - Math.sqrt((coeff.Sc + coeff.Sb * cmp.slp50) ** 2 + coeff.Sd ** 2) # removed April 16, 2012
    end
    cmp.LandscapeSlopeDeduction = Calculate.constrain(cmp.LandscapeSlopeDeductionRaw, 0, 100)
    cmp.LandscapeBasicRating = 100 - cmp.LandscapeSlopeDeduction
    #Coarse Fragment modifier
    # Stoniness
#    cmp.LandscapeStoninessPercentReduction = Calculate.constrain((cmp.stoninessValue * 53.333333), 0, 100) ## replaced July 2009
#    cmp.LandscapeStoninessPercentReduction = Calculate.constrain(((74.584 * cmp.stoninessValue ) + (-13.985 * cmp.stoninessValue ** 2)), 0, 100) ## replaced Jan 6, 2010 to make database driven
#    cmp.LandscapeStoninessPercentReduction = Calculate.constrain(((coeff.Pa + coeff.Pb * cmp.stoninessValue ) + (coeff.Pc * cmp.stoninessValue ** 2)), 0, 100) # replaced April 16 2012 
    case slopeFactorModel
      when "perennial" then
        cmp.LandscapeStoninessPercentReduction = Calculate.constrain((-9.1851 + (77.356 * cmp.stoninessValue ) + (-11.499 * cmp.stoninessValue ** 2)), 0, 100)
      else
        cmp.LandscapeStoninessPercentReduction = Calculate.constrain(((74.584 * cmp.stoninessValue ) + (-13.985 * cmp.stoninessValue ** 2)), 0, 100)
    end
    # Gravel - Figure 6.5
    if cmp.SurfaceCF != nil then
      if crop == "alfalfa" or crop == "brome" then
        cmp.LandscapeGravelPercentReduction = 0
      else
        cmp.LandscapeGravelPercentReduction = Calculate.constrain((-9 + cmp.SurfaceCF * 0.96285714 + (-0.0057142857 * cmp.SurfaceCF ** 2 )), 0, 100) 
      end
    else 
      cmp.LandscapeGravelPercentReduction = 0
    end
    # Wood
    if cmp.order == "OR" then
      cmp.LandscapeWoodContentPercentReduction = Calculate.constrain((cmp.SurfaceWood * 2 + cmp.SubsurfaceWood), 0, 25)
    else
      cmp.LandscapeWoodContentPercentReduction = 0
    end
    cmp.LandscapeTotalCFPercentReduction = cmp.LandscapeStoninessPercentReduction + cmp.LandscapeGravelPercentReduction + cmp.LandscapeWoodContentPercentReduction
    cmp.LandscapeCFDeduction = cmp.LandscapeBasicRating * cmp.LandscapeTotalCFPercentReduction / 100
    cmp.LandscapeInterimRating = cmp.LandscapeBasicRating - cmp.LandscapeCFDeduction
    #Other deductions
    cmp.LandscapePatternPercentReduction = Calculate.constrain(cmp.LandscapePattern, 0, 10)
    # flooding
    inundation = [nil,[nil,0,5,5,10],[nil,0,5,10,20],[nil,10,30,65,75],[nil,30,65,70,90]]
    cmp.LandscapeFloodingPercentReduction = inundation[cmp.LandscapeFloodingFreq][cmp.LandscapeFloodingPeriod]
    cmp.LandscapeTotalOtherPercentReductions = cmp.LandscapePatternPercentReduction + cmp.LandscapeFloodingPercentReduction
    cmp.LandscapeOtherDeduction = cmp.LandscapeInterimRating * cmp.LandscapeTotalOtherPercentReductions / 100
    cmp.LandscapeFinalRating = (cmp.LandscapeInterimRating - cmp.LandscapeOtherDeduction).round
    cmp.LandscapeClass = Calculate.rating(cmp.LandscapeFinalRating)
    return cmp
  end

  def Landscape.slopeFactor(crop, landscape)
		# LSRSv5
    case landscape.Model
      when "perennial" then 
        landscape.SlopeDeductionRaw = (-0.0398 * landscape.SlopePercent ** 2) + (4.1717 * landscape.SlopePercent) - 17.356  # quadratic equation
      when "annual1" then
        landscape.SlopeDeductionRaw = (0.0005 * landscape.SlopePercent ** 3) - (0.0886 * landscape.SlopePercent ** 2) + (4.898 * landscape.SlopePercent)
      when "annual2" then
        landscape.SlopeDeductionRaw = (0.0014 * landscape.SlopePercent ** 3) - (0.1519 * landscape.SlopePercent ** 2) + (5.9183 * landscape.SlopePercent)
    end
    landscape.SlopeDeduction = Calculate.constrain(landscape.SlopeDeductionRaw, 0, 100)
    landscape.BasicRating = 100 - landscape.SlopeDeduction
  end

  def Landscape.fragmentsFactor(crop, soil, landscape)
		# LSRSv5
    # Stoniness
    case landscape.Model
      when "perennial" then
        landscape.StoninessPercentReduction = Calculate.constrain((-9.1851 + (77.356 * landscape.Stoniness ) + (-11.499 * landscape.Stoniness ** 2)), 0, 100)
      else
        landscape.StoninessPercentReduction = Calculate.constrain(((74.584 * landscape.Stoniness ) + (-13.985 * landscape.Stoniness ** 2)), 0, 100)
			end
    # Gravel - Figure 6.5
    if soil.SurfaceCF != nil then
      if crop == "alfalfa" or crop == "brome" then
        landscape.CoarseFragmentPercentReduction = 0
      else
        landscape.CoarseFragmentPercentReduction = Calculate.constrain((-9 + soil.SurfaceCF * 0.96285714 + (-0.0057142857 * soil.SurfaceCF ** 2 )), 0, 100) 
      end
    else 
      landscape.CoarseFragmentPercentReduction = 0
    end
    # Wood
    if soil.order == "OR" then
      landscape.WoodPercentReduction = Calculate.constrain((soil.SurfaceWood * 2 + soil.SubsurfaceWood), 0, 25)
    else
      landscape.WoodPercentReduction = 0
    end
    landscape.TotalCFPercentReduction = landscape.StoninessPercentReduction + landscape.CoarseFragmentPercentReduction + landscape.WoodPercentReduction
    landscape.CFDeduction = landscape.BasicRating * landscape.TotalCFPercentReduction / 100
    landscape.InterimRating = landscape.BasicRating - landscape.CFDeduction
	end

	def Landscape.otherFactors(crop, landscape)
		# LSRSv5
    # surface features
    landscape.Pattern = 0
    landscape.PatternPercentReduction = Calculate.constrain(landscape.Pattern, 0, 10)
    # flooding
    landscape.FloodingFrequency = 1
    landscape.InundationPeriod = 1
    inundation = [nil,[nil,0,5,5,10],[nil,0,5,10,20],[nil,10,30,65,75],[nil,30,65,70,90]]
    landscape.FloodingPercentReduction = inundation[landscape.FloodingFrequency][landscape.InundationPeriod]
		# sum up
    landscape.TotalOtherPercentReduction = landscape.PatternPercentReduction + landscape.FloodingPercentReduction
    landscape.OtherDeduction = landscape.InterimRating * landscape.TotalOtherPercentReduction/ 100
    landscape.FinalRating = (landscape.InterimRating - landscape.OtherDeduction).round
    landscape.SuitabilityClass = Calculate.rating(landscape.FinalRating)
	end

end
