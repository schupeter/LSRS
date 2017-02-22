class MineralFormulas
	
	def MineralFormulas.mineral(soil, ppe, coeff, crop)
    # calculate rating
    # surface moisture factor = Table 4.2
    soil.SurfaceSTP = ( soil.SurfaceSi + soil.SurfaceC ) * ( 1 - soil.SurfaceCF / 100 )
    soil.SurfaceAWHCdeduction1 = ( coeff.AWHCa + ppe ) * -0.2
    if soil.SurfaceSTP < 0 then
      soil.SurfaceAWHCdeduction2 = 60 - 1.5 * soil.SurfaceSTP
    else
      soil.SurfaceAWHCdeduction2 = 28 - ( 1 / Math.sqrt( [-1.0, ppe].min / -100 ) ) * ( soil.SurfaceSTP - 20 )
    end
    soil.SurfaceAWHCdedn1and2 = soil.SurfaceAWHCdeduction1 + [0, soil.SurfaceAWHCdeduction2].max
    soil.SurfaceAWHCdeduction = [0, soil.SurfaceAWHCdedn1and2].max
    # subsurface texture factor = Table 4.3
    soil.SubsurfaceSTP = ( soil.SubsurfaceSi + soil.SubsurfaceC ) * ( 1 - soil.SubsurfaceCF / 100 )
    soil.MSTP = ( soil.SurfaceSTP + soil.SubsurfaceSTP ) / 2
    soil.SubsurfaceAWHCdeduction1 = ( 150 + ppe ) * -0.2
    if soil.MSTP <= 20 then
      soil.SubsurfaceAWHCdeduction2 = 60 - 1.5 * soil.MSTP
    else
      soil.SubsurfaceAWHCdeduction2 = 28 - ( 1 / Math.sqrt( [-1.0, ppe].min / -100 ) ) * ( soil.MSTP - 20 )
    end
    soil.SubsurfaceAWHCdedn1and2 = soil.SubsurfaceAWHCdeduction1 + [0, soil.SubsurfaceAWHCdeduction2].max
    soil.SubsurfaceAWHCdeduction = [0, soil.SubsurfaceAWHCdedn1and2].max
    soil.SubsurfaceAdjustment = soil.SubsurfaceAWHCdeduction - soil.SurfaceAWHCdeduction
    soil.SubtotalTextureDeduction = soil.SurfaceAWHCdeduction + soil.SubsurfaceAdjustment
    # water table deduction = Table 4.4
    if soil.WaterTableDepth == 0 then soil.WTD = 0.000001 else soil.WTD = soil.WaterTableDepth end
    soil.WaterTableDeduction = 100 - soil.WTD * ( Math.log10(soil.WTD) ** 3 ) / ( 6 + ( soil.SurfaceSi + soil.SurfaceC ) / 25 )
    soil.WaterTableDeduction = [[soil.WaterTableDeduction, 0].max, 100].min
    soil.MoistureReductionAmount = (soil.WaterTableDeduction / 100.0 ) * soil.SubtotalTextureDeduction 
    soil.MoistureDeduction = [(soil.SubtotalTextureDeduction - soil.MoistureReductionAmount) , 70].min
    #other surface factors
    # organic (peaty) surface = table 4.11
    if soil.OrganicBD == 0 then organicBD = 0.12 else organicBD = soil.OrganicBD end
    if soil.OrganicDepth - 10 < 0 then soil.OrganicDeductionO = 0 else soil.OrganicDeductionO = (soil.OrganicDepth - 10) * (Math.sqrt(0.12) / Math.sqrt(organicBD)) end
    soil.OrganicDeductionO = Calculate.constrain( (soil.OrganicDeductionO), 0, 100)
    # Surface / Consistence = table 4.5
    soil.SurfaceS = 100 - soil.SurfaceSi - soil.SurfaceC
    surfaceOC = [soil.SurfaceOC, 0.000001].max
    surfaceS = [([soil.SurfaceS, 0].max - 60), 0].max
    surfaceSi = [([soil.SurfaceSi, 0].max - 50), 0].max
    surfaceC = [([soil.SurfaceC, 0].max - 50), 0].max
    if surfaceOC > 2.5 then soil.SurfaceDeductionD = 0 
      elsif soil.OrganicDeductionO > 0 then soil.SurfaceDeductionD = 0  
      else soil.SurfaceDeductionD = [( (2.5 / surfaceOC) + ((surfaceS)/3 * surfaceOC) + ((surfaceSi) / (surfaceOC * coeff.SurDa)) + ((surfaceC) / (surfaceOC * coeff.SurDb)) ).abs, 10].min
    end
    # surface structure / consistence = table 4.6
    if soil.SurfaceOC == 0 then surfaceOC = 0.000001 else surfaceOC = soil.SurfaceOC end
    soil.SurfaceDeductionF = Calculate.constrain( ( 9.9928375 + -7.229321 * Math.log(surfaceOC) ), 0, 15)
    if soil.OrganicDeductionO > 0 then soil.SurfaceDeductionF = 0 end
    # depth of top soil = Table 4.7
    soil.SurfaceDeductionE = [(20 + (-1 * soil.SurfaceDepthTopSoil) ), 20].min
    # reaction - soil pH = Table 4.8
    if soil.SurfaceReaction < coeff.SurV0a then
      soil.SurfaceReactionDeductionInterim = Calculate.constrain( (coeff.SurV1a+ (coeff.SurV1b * soil.SurfaceReaction ) + coeff.SurV1c * soil.SurfaceReaction ** 2 ), 0, 100)
    elsif soil.SurfaceReaction > 7.5 then 
      soil.SurfaceReactionDeductionInterim = Calculate.constrain( ( (-20.543722 + 2.7164411 * soil.SurfaceReaction ) / ( 1 + (-0.07521742 * soil.SurfaceReaction) + (-0.0031859168 * soil.SurfaceReaction ** 2 ) ) ), 0, 100)
    else soil.SurfaceReactionDeductionInterim = 0
    end
    # Surface sodicity - SAR - Table 4.10
    soil.SurfaceSodicityDeductionInterim = Calculate.constrain( ( -6 + 0.71428571 * soil.SurfaceSodicity + 0.17857143 ** soil.SurfaceSodicity ), 0, 100 )
    # Subsurface Sodicity - Table 4.17
    soil.SubsurfaceSodicityDeductionInterim = Calculate.constrain( (-6 + 0.71428571 * soil.SubsurfaceSodicity + 0.17857143 * soil.SubsurfaceSodicity ** 2), 0, 100)
    if soil.SubsurfaceSi + soil.SubsurfaceC > 50 then soil.SubsurfaceSodicityDeductionInterim = 0 end
    # Surface salinity - EC - Table 4.9
#    soil.SurfaceSalinityDeductionInterim = Calculate.constrain( ( (-28.704261 * 17.748344 + 278.70426 * soil.SurfaceSalinity ** 0.87021431) / (17.748344 + soil.SurfaceSalinity ** 0.87021431) ), 0, 100) # switched Nov 23 2015 to lookup
		soil.SurfaceSalinityDeductionInterim = Calculate.interpolate(soil.SurfaceSalinity, eval("#{crop}::SURFACESALINITY_DEDUCTIONS"))
    if soil.SurfaceSodicityDeductionInterim > soil.SurfaceSalinityDeductionInterim then soil.SurfaceSalinityDeductionInterim = 0 end
    # Subsurface Salinity - modified from Table 4.16 in LSRS manual
#    soil.SubsurfaceSalinityDeductionInterim = Calculate.constrain( (-20 + 5.375 * soil.SubsurfaceSalinity), 0, 100)# switched Nov 23 2015 to lookup
		soil.SubsurfaceSalinityDeductionInterim = Calculate.interpolate(soil.SubsurfaceSalinity, eval("#{crop}::SUBSURFACESALINITY_DEDUCTIONS"))
    if soil.SubsurfaceSodicityDeductionInterim > soil.SubsurfaceSalinityDeductionInterim then soil.SubsurfaceSalinityDeductionInterim = 0 end
    # Surface sodicity final = Table 4.10
    if (soil.SubsurfaceSodicityDeductionInterim / 100) * (100 - soil.MoistureDeduction) >= soil.SurfaceSodicityDeductionInterim then soil.SurfaceSodicityDeduction = 0 else soil.SurfaceSodicityDeduction = soil.SurfaceSodicityDeductionInterim end
    # Surface salinity final = Table 4.9
    if (soil.SubsurfaceSalinityDeductionInterim / 100) * (100 - soil.MoistureDeduction) >= soil.SurfaceSalinityDeductionInterim then soil.SurfaceSalinityDeduction = 0 else soil.SurfaceSalinityDeduction = soil.SurfaceSalinityDeductionInterim end
    # other subsurface calcs
    # subsurface salinity = Table 4.16 continued
    if soil.SubsurfaceImpedenceDeduction > 30 then soil.SubsurfaceSalinityDeduction = 0 else
      if (soil.SubsurfaceSalinityDeductionInterim / 100) * (100 - soil.MoistureDeduction) < soil.SurfaceSalinityDeductionInterim then 
        soil.SubsurfaceSalinityDeduction  = 0 
        else
        soil.SubsurfaceSalinityDeduction  = soil.SubsurfaceSalinityDeductionInterim
      end
    end
    # subsurface sodicity = Table 4.17
    if soil.SubsurfaceC + soil.SubsurfaceSi > 50 then
      soil.SubsurfaceSodicityDeductionInterim = 0 
      else 
      soil.SubsurfaceSodicityDeductionInterim = Calculate.constrain((-6 + 0.71428571 * soil.SubsurfaceSodicity + 0.17857143 * soil.SubsurfaceSodicity ** 2), 0, 100)
    end
    if ( soil.SubsurfaceSodicityDeductionInterim / 100) * (100 - soil.MoistureDeduction) < soil.SurfaceSodicityDeductionInterim then soil.SubsurfaceSodicityDeduction = 0 else soil.SubsurfaceSodicityDeduction = soil.SubsurfaceSodicityDeductionInterim end
    # subsurface reaction (V) = Table 4.15 - note two different degrees of polynomial are managed with this one equation
    if soil.SubsurfaceReaction >= coeff.SubVpHlimit then soil.SubsurfaceReactionDeductionInterimPre = 0 else
      soil.SubsurfaceReactionDeductionInterimPre = Calculate.constrain( (coeff.SubVa + coeff.SubVb * soil.SubsurfaceReaction + coeff.SubVc * soil.SubsurfaceReaction ** 2 + coeff.SubVd * soil.SubsurfaceReaction ** 3), 0, 100)
    end
    soil.SubsurfaceReactionDeductionInterim = Calculate.constrain(soil.SubsurfaceReactionDeductionInterimPre, 0, 70)
    if soil.SubsurfaceReactionDeductionInterim > 0 and soil.SubsurfaceSalinityDeduction + soil.SubsurfaceSodicityDeduction > 0 then soil.SubsurfaceReactionDeduction =0 else
      if (soil.SubsurfaceReactionDeductionInterim / 100) * (100 - soil.MoistureDeduction) < soil.SurfaceReactionDeductionInterim then soil.SubsurfaceReactionDeduction = 0 else soil.SubsurfaceReactionDeduction =soil.SubsurfaceReactionDeductionInterim end
    end
    # surface reaction = Table 4.8  - calculate after subsurface reaction
    if soil.SurfaceReactionDeductionInterim > 0 and soil.SurfaceSodicityDeduction + soil.SurfaceSalinityDeduction > 0 then
      soil.SurfaceReactionDeduction = 0
    else
      if (soil.SubsurfaceReactionDeductionInterimPre / 100) * (100 - soil.MoistureDeduction) >= soil.SurfaceReactionDeductionInterim then
        soil.SurfaceReactionDeduction = 0
      else
        soil.SurfaceReactionDeduction = soil.SurfaceReactionDeductionInterim
      end
    end
    soil.SurfaceMostLimitingDeduction = [soil.SurfaceReactionDeduction, soil.SurfaceSalinityDeduction, soil.SurfaceSodicityDeduction].max
    soil.SurfaceTotalDeductions = soil.SurfaceDeductionD + soil.SurfaceDeductionF + soil.SurfaceDeductionE + soil.SurfaceMostLimitingDeduction + soil.OrganicDeductionO
    soil.SurfaceInterimSoilRating = Calculate.constrain((100 - soil.MoistureDeduction - soil.SurfaceTotalDeductions), 0, 100)
    # max of subsurface deductions
    soil.SubsurfaceMostLimitingDeduction = [soil.SubsurfaceReactionDeduction, soil.SubsurfaceSalinityDeduction, soil.SubsurfaceSodicityDeduction].max
    soil.SubsurfacePercentReduction = soil.SubsurfaceHighestImpedenceDeduction + soil.SubsurfaceMostLimitingDeduction
    #soil.SubsurfaceDeduction = soil.SubsurfacePercentReduction / 100 * soil.SurfaceInterimSoilRating
    soil.SubsurfaceDeduction = soil.SurfaceInterimSoilRating * soil.SubsurfacePercentReduction / 100
    soil.InterimBasicSoilRating = soil.SurfaceInterimSoilRating - soil.SubsurfaceDeduction
    if soil.InterimBasicSoilRating < 0 then soil.FinalBasicSoilRating = 0 else soil.FinalBasicSoilRating = soil.InterimBasicSoilRating end
# Calculations for Drainage (W) = Tables 4.18, 4.19, 4.20
    if soil.SurfaceSi == 0 then surfaceSi = 0.000001 else surfaceSi = soil.SurfaceSi end
    if soil.SurfaceC == 0 then surfaceC = 0.000001 else surfaceC = soil.SurfaceC end
    soil.DrainagePercentReduction = Calculate.constrain( ( (100 - ((100 + ppe) / -100) * 3) - (soil.WaterTableDepth * (1.65 / Math.log10( surfaceSi + surfaceC))) ), 0, 100)
    soil.DrainageDeduction = ( soil.FinalBasicSoilRating * soil.DrainagePercentReduction ) /100
    soil.FinalSoilRating = (soil.FinalBasicSoilRating - soil.DrainageDeduction).round
    soil.SuitabilityClass = Calculate.rating(soil.FinalSoilRating) 
  end

end