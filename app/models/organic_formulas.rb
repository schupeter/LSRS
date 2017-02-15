class OrganicFormulas
	
  def OrganicFormulas.calc(soil, climate, coeff)
    # calculate rating
    # soil climate (Z)
    soil.TemperatureDeduction = Calculate.constrain( (coeff.Za + coeff.Zb * climate.EGDD), 0, 25)
    soil.OrganicBaseRating = 100 - soil.TemperatureDeduction
    # moisture deficit factor (M)
    soil.WaterCapacityDeduction = [(40 * ( [soil.SurfaceFibre,0].max / 80) ) - (((250 + climate.PPE) / 50) * 5), 0].max
    if soil.SubsurfaceFibre < 0 then subsurfaceFibre = 0.01 else subsurfaceFibre = soil.SubsurfaceFibre end
    soil.WaterTableAdjustment = soil.WaterCapacityDeduction * (100 - ((soil.WaterTableDepth ** 2) / 12) / (5 + (10 / (0.1 * subsurfaceFibre))) ) / -100
    soil.MoistureDeficitDeduction = soil.WaterCapacityDeduction + soil.WaterTableAdjustment
    soil.InterimRating = soil.OrganicBaseRating -  soil.MoistureDeficitDeduction
    # surface factors (sf)
    # surface structure deduction (B)
    soil.SurfaceStructureDeduction = [(40.00873619 + -2.3912966 * soil.SurfaceFibre + 0.213398324 * climate.PPE + 0.045354094 * soil.SurfaceFibre ** 2 + 0.000614069 * climate.PPE ** 2 + -0.009623 * soil.SurfaceFibre * climate.PPE + -0.0002331 * soil.SurfaceFibre ** 3 +2.78E-07 * climate.PPE ** 3 + -3.53E-06 * soil.SurfaceFibre * climate.PPE ** 2 + 7.33E-05 * soil.SurfaceFibre ** 2 * climate.PPE),0].max
    # surface reaction deduction (V)
    if soil.SurfaceReaction < 5.5 then
      soil.SurfaceReactionDeduction = [(40*((Math.sqrt(soil.SurfaceFibre)) / 8.9)) + (((5.5 - soil.SurfaceReaction) / 0.1) * ( 1 + ((Math.sqrt( 100 / (soil.SurfaceFibre+0.1))) * 0.1))),0].max 
      else 
      soil.SurfaceReactionDeduction = [(40 * ((Math.sqrt(soil.SurfaceFibre)) / 8.9)),0].max
    end
    # surface salinity deduction (N) - Table 5.7
    soil.SurfaceSalinityDeductionInterim = (-13.230275*22.752925 + 94.480275 * soil.SurfaceSalinity ** 1.67181) / (22.752925 + soil.SurfaceSalinity ** 1.67181) 
    soil.SurfaceSalinityDeduction = Calculate.constrain(soil.SurfaceSalinityDeductionInterim,0,100).to_f
    soil.SurfaceMostLimitingDeduction = [soil.SurfaceReactionDeduction,soil.SurfaceSalinityDeduction].max
    soil.SurfaceTotalDeductions = Calculate.constrain(soil.SurfaceStructureDeduction + soil.SurfaceMostLimitingDeduction,0,100)
    soil.SurfaceFinalDeduction = (soil.SurfaceTotalDeductions.to_f / 100) * soil.InterimRating
    soil.BasicOrganicRating = soil.InterimRating - soil.SurfaceFinalDeduction
    # subsurface factors
    # subsurface structure deduction (B) - Table 5.8
    #subsurfaceFibre = [soil.SubsurfaceFibre,0].max # removed Jan 26 2010 to eliminate error - should be OK because of line 169
    if subsurfaceFibre >= 40 then
      soil.SubsurfaceStructureDeduction = -20 + 0.5 * subsurfaceFibre
      elsif subsurfaceFibre > 20
      soil.SubsurfaceStructureDeduction = 0
      else
      soil.SubsurfaceStructureDeduction = (20 + -1 * subsurfaceFibre ) / (1 + 0.1 *  subsurfaceFibre)
    end
    # subsurface substrate deduction (G) - Table 5.9
    soil.SubsurfaceSubstrateDeduction = 0 # force zero to start with to prevent errors (not in prototype)
    if soil.OrganicDepth >= 140 then soil.SubsurfaceSubstrateDeduction = 0 
      else
      if soil.SubSubsurfaceHZNMAS == "R" then soil.SubsurfaceSubstrateDeduction = ((120 - soil.OrganicDepth) * 0.8) + (10 + ((climate.PPE) / -15)) end
      if soil.SubSubsurfaceHZNMAS == "CO" then soil.SubsurfaceSubstrateDeduction = ((120 - soil.OrganicDepth) * 0.7) + ( 5 + ((climate.PPE) / -15)) end
      if soil.SubSubsurfaceHZNMAS == ("C" or "A") then 
        if soil.SubSubsurfaceCofrag >= 20 then 
          soil.SubsurfaceSubstrateDeduction = ((120-D)*0.6)+((climate.PPE)/-15) 
          else
          soil.SubsurfaceSubstrateDeduction = (((100 - soil.OrganicDepth) * 0.6) * ((soil.SubSubsurfaceTsilt + soil.SubSubsurfaceTclay) / 80)) + ((climate.PPE)/-15) 
        end
      end
    end
    soil.SubsurfaceSubstrateDeduction = [soil.SubsurfaceSubstrateDeduction,0].max
    # subsurface reaction deduction (V) - Table 5.10
    soil.SubsurfaceReactionDeduction = [((6.0 - soil.SubsurfaceReaction) * 10),0].max
    # subsurface salinity deduction (N) - Table 5.11
    soil.SubsurfaceSalinityDeduction = [(-13.333333 + 3.75 * soil.SubsurfaceSalinity + -0.10416667 * soil.SubsurfaceSalinity ** 2),0].max
    soil.SubsurfaceMostLimitingDeduction = [soil.SubsurfaceReactionDeduction,soil.SubsurfaceSalinityDeduction].max
    soil.SubsurfaceTotalDeductions = soil.SubsurfaceStructureDeduction + soil.SubsurfaceSubstrateDeduction + soil.SubsurfaceMostLimitingDeduction
    soil.SubsurfaceFinalDeduction = (soil.SubsurfaceTotalDeductions.to_f / 100) * soil.BasicOrganicRating
    soil.InterimFinalRating = soil.BasicOrganicRating - soil.SubsurfaceFinalDeduction
    # drainage deduction (W) Tables 5.12, 5.13, 5.14
    subsurfaceFibre = [soil.SubsurfaceFibre,0].max
    waterTableDepth = [soil.WaterTableDepth,0].max
    if climate.PPE < 150 then
      soil.DrainagePercentDeduction = Calculate.constrain((100 - (((((climate.PPE) - 150) / -150) ** 2) * (Math.sqrt(subsurfaceFibre / 10))) - (waterTableDepth * Math.sqrt(((climate.PPE) - 150) / -300))),0,100)
    else # bug 46
      soil.DrainagePercentDeduction = 100
    end
    soil.DrainageDeduction = (soil.DrainagePercentDeduction / 100) * soil.InterimFinalRating
    soil.FinalSoilRating = (soil.InterimFinalRating - soil.DrainageDeduction).round
    soil.SuitabilityClass = Calculate.rating(soil.FinalSoilRating) 
  end 
	
end
