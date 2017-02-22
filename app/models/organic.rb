class Organic

  def Organic.params(organicParams)
    organicCoeff = LsrsOrganicCoeffClass.new
    organicCoeff.Za = organicParams[0].Za.to_f
    organicCoeff.Zb = organicParams[0].Zb.to_f
    return organicCoeff
  end

  def Organic.inputsSLC(cmp, name)
    # SNF/SLF records retrieved.  Calculate rating inputs.
    # Proxy the water table depth from the drainage class.
    cmp.WaterTableDepth = -1
    if name.drainage == "VP" then cmp.WaterTableDepth = 0 end
    if name.drainage == "P"  then cmp.WaterTableDepth = 25 end
    if name.drainage == "PI" then cmp.WaterTableDepth = 50 end # not used in NSDB
    if name.drainage == "I"  then cmp.WaterTableDepth = 75 end
    if name.drainage == "MW" then cmp.WaterTableDepth = 100 end
    if name.drainage == "W"  then cmp.WaterTableDepth = 125 end
    if name.drainage == "-"  then	cmp.WaterTableDepth = 25 end    # Use 25 instead of 100 as in Mineral Component.
    if name.drainage == "R"  then cmp.WaterTableDepth = 150 end  
    if name.drainage == "V"  then cmp.WaterTableDepth = 0 end       # "V", "VR", and "M" added for slc/NSDB.
    if name.drainage == "VR" then cmp.WaterTableDepth = 150 end 
    if name.drainage == "M"  then cmp.WaterTableDepth = 100 end 
    if cmp.WaterTableDepth < 0 then cmp.WaterTableDepth = 25 end # Again, use 25 here instead of 100 as in Mineral.
    cmp.order = name.order3
    return cmp
  end # def Organic.inputsSLC

  def Organic.horizonsSLC(cmp, layerRecords)
    # Horizon Processing if ORGANIC component.
    # initialize values for horizon processing
    cmp.OrganicDepth = 0
    cmp.SurfaceCF = 0
    cmp.SurfaceDepth = 40
    cmp.SurfaceBD = 0.0
    cmp.SurfaceFibre = 0
    cmp.SurfaceReaction = 0.0
    cmp.SurfaceSalinity = 0.0
    cmp.SurfaceWood = 0
    cmp.SubsurfaceDepth = 120
    cmp.SubsurfaceBD = 0.0
    cmp.SubsurfaceFibre = 0
    cmp.SubsurfaceReaction = 0.0
    cmp.SubsurfaceSalinity = 0.0
#    cmp.SubsurfaceTexture = 0
    cmp.SubsurfaceWood = 0
    cmp.SubSubsurfaceExists = false
    cmp.SubSubsurfaceTsilt = 0
    cmp.SubSubsurfaceTclay = 0
    cmp.SubSubsurfaceCofrag = 0  
    # start processing horizons
    lyrArray = Array.new
    for layer in layerRecords do
      lyr = LsrsLyrOrganicClass.new
      # Get the HZN_MAS value and generalize it for subsequent processing. 
      lyr.hznmasClass = layer.hzn_mas
      if lyr.hznmasClass == "AB"  then lyr.hznmasClass = "A" end
      if lyr.hznmasClass == "AC"  then lyr.hznmasClass = "A" end
      if lyr.hznmasClass == "B"   then lyr.hznmasClass = "A" end
      if lyr.hznmasClass == "BA"  then lyr.hznmasClass = "A" end
      if lyr.hznmasClass == "BC"  then lyr.hznmasClass = "A" end
      if lyr.hznmasClass == "C+H" then lyr.hznmasClass = "C" end
      if lyr.hznmasClass == "CA"  then lyr.hznmasClass = "C" end
      if lyr.hznmasClass == "CB"  then lyr.hznmasClass = "C" end
      if lyr.hznmasClass == "W"   then lyr.hznmasClass = "R" end
      if (lyr.hznmasClass == "O" and cmp.SubSubsurfaceExists == false) then cmp.OrganicDepth = layer.ldepth end
    	if (lyr.hznmasClass == ("R" or "CO") and cmp.SubSubsurfaceExists == false) then
        cmp.SubSubsurfaceExists = true
        cmp.SubSubsurfaceUpperDepth = layer.udepth
        cmp.SubSubsurfaceLowerDepth = layer.ldepth
        cmp.SubSubsurfaceHZNMAS = lyr.hznmasClass
      end
      if (lyr.hznmasClass == ("A" or "C") and cmp.SubSubsurfaceExists == false) then
        cmp.SubSubsurfaceExists = true
        cmp.SubSubsurfaceUpperDepth = layer.udepth
        cmp.SubSubsurfaceLowerDepth = layer.ldepth
        cmp.SubSubsurfaceHZNMAS = lyr.hznmasClass
        cmp.SubSubsurfaceTsilt = layer.tsilt
        cmp.SubSubsurfaceTclay = layer.tclay
        cmp.SubSubsurfaceCofrag = layer.cofrag
      end
      # add calculated layer to array of layers
      lyrArray.push lyr
    end # for layer
    # Now let's adjust depth numbers.
    if cmp.OrganicDepth < cmp.SubsurfaceDepth then cmp.SubsurfaceDepth = cmp.OrganicDepth end
    if cmp.SubsurfaceDepth > 120 then cmp.SubsurfaceDepth = 120 end
    if cmp.SurfaceDepth > cmp.SubsurfaceDepth then cmp.SurfaceDepth = cmp.SubsurfaceDepth end
    # Now continue processing for each horizon
    layerRecords.each_with_index do | layer, i |
      if layer.udepth == nil then
        lyrArray[i].udepth = 0
        else
        lyrArray[i].udepth = layer.udepth
      end
      if layer.ldepth == nil then
        lyrArray[i].ldepth = 120
        else
        lyrArray[i].ldepth = layer.ldepth
      end
      #lyrArray[i].bd = layer.bd
      if layer.hzn_mas == "R" and layer.bd == -9 then lyrArray[i].bd = 3.2 else lyrArray[i].bd = layer.bd end # bug 19
      lyrArray[i].cofrag = layer.cofrag
      lyrArray[i].tsilt = layer.tsilt
      lyrArray[i].tclay = layer.tclay
      lyrArray[i].orgcarb = layer.orgcarb
      lyrArray[i].ph2 = layer.ph2
      lyrArray[i].ec = layer.ec
      lyrArray[i].kp0 = layer.kp0
      lyrArray[i].vonpost = layer.vonpost
      lyrArray[i].wood = layer.wood
      lyrArray[i].hznmas = layer.hzn_mas
      # Proxy the value for % Fibre 
      if layer.vonpost != -9 then
        lyrArray[i].fibre = 109.3 + -21.228788 * layer.vonpost + 1.0378788 * layer.vonpost ** 2
        elsif layer.bd != -9 then
        lyrArray[i].fibre = (155.47688 * 0.032419017 +-22.457452 * layer.bd ** 1.2332106) / (0.032419017 + layer.bd ** 1.2332106)
        else
        lyrArray[i].fibre = 0   # updated Oct 5 2009 to control for missing bd values
      end
      if lyrArray[i].fibre < 0 then lyrArray[i].fibre = 0 end # updated Oct 5 2009 because statement was missing an action
      #determine horizon assignment factors
      lyrArray[i].SurfaceFactor = 0.0
      lyrArray[i].SubsurfaceFactor = 0.0 # updated Feb 13, 2012 because of faulty assignment
      # calc surfaceFactor
      if lyrArray[i].udepth < cmp.SurfaceDepth then
        lyrArray[i].SurfaceFactor = ( [cmp.SurfaceDepth, lyrArray[i].ldepth].min - lyrArray[i].udepth ) / cmp.SurfaceDepth.to_f
      end
      # calc subsurfaceFactor
      if lyrArray[i].ldepth > cmp.SurfaceDepth then
        lyrArray[i].SubsurfaceFactor = ( [cmp.SubsurfaceDepth, lyrArray[i].ldepth].min - [cmp.SurfaceDepth, lyrArray[i].udepth].max ) / ( cmp.SubsurfaceDepth - cmp.SurfaceDepth ).to_f
        if lyrArray[i].SubsurfaceFactor.nan? then lyrArray[i].SubsurfaceFactor = 0.0 end # fix bug 19
        if lyrArray[i].SubsurfaceFactor.infinite? then lyrArray[i].SubsurfaceFactor = 0.0 end # fix bug 19
        if lyrArray[i].SubsurfaceFactor < 0 then lyrArray[i].SubsurfaceFactor = 0.0 end # fix bug Feb 13, 2012
      end
      # First -- Surface variables
      cmp.SurfaceBD = cmp.SurfaceBD + layer.bd * lyrArray[i].SurfaceFactor;
      cmp.SurfaceFibre = cmp.SurfaceFibre + lyrArray[i].fibre * lyrArray[i].SurfaceFactor
      # Surface Reaction
      cmp.SurfaceReaction = cmp.SurfaceReaction + layer.ph2 * lyrArray[i].SurfaceFactor
      # Surface Salinity
      if layer.ec == -9 then organic_SurfaceSalinityEC_Value = 0.1 else organic_SurfaceSalinityEC_Value = layer.ec end
      cmp.SurfaceSalinity = cmp.SurfaceSalinity + organic_SurfaceSalinityEC_Value * lyrArray[i].SurfaceFactor
      # Subsurface BD
      cmp.SubsurfaceBD = cmp.SubsurfaceBD + layer.bd * lyrArray[i].SubsurfaceFactor
      # Subsurface Fibre
      cmp.SubsurfaceFibre = cmp.SubsurfaceFibre + lyrArray[i].fibre * lyrArray[i].SubsurfaceFactor
      # Subsurface Reaction
      if layer.ph2 != -9 then cmp.SubsurfaceReaction = cmp.SubsurfaceReaction + layer.ph2 * lyrArray[i].SubsurfaceFactor end  # added condition Jan 26 2010 to fix missing values for rock
      # Subsurface Salinity
      if layer.ec == -9 then organic_SubsurfaceSalinityEC_Value = 0.1 else organic_SubsurfaceSalinityEC_Value = layer.ec end
      cmp.SubsurfaceSalinity = cmp.SubsurfaceSalinity + organic_SubsurfaceSalinityEC_Value * lyrArray[i].SubsurfaceFactor
      # Surface and Subsurface Wood
      if layer.wood == -9 then woodValue = 0 else woodValue = layer.wood end 
      cmp.SurfaceWood = cmp.SurfaceWood + woodValue * lyrArray[i].SurfaceFactor
      cmp.SubsurfaceWood = cmp.SubsurfaceWood + woodValue * lyrArray[i].SubsurfaceFactor
    end # layerRecords.each
    #populate cmp with layers
    cmp.layers = lyrArray
    # Set defaults for Subsubsurface
    if cmp.SubSubsurfaceExists == false then 
      cmp.SubSubsurfaceHZNMAS = "-"
      cmp.SubSubsurfaceTsilt = 0
      cmp.SubSubsurfaceTclay = 0
      cmp.SubSubsurfaceCofrag = 0
    end
    return cmp
  end # def Organic.horizonsSLC

  def Organic.management(cmp)
		# adjust values based on soil management practices
		# set all water table depths to assume tile drainage
		if cmp.WaterTableDepth < 100 then 
			cmp.WaterTableDepth = 100 
			cmp.ManagedWaterTableDepth = cmp.WaterTableDepth
		end
		# control pH
		if cmp.SurfaceReaction < 5.6  then 
			cmp.SurfaceReaction = 5.6
			cmp.ManagedReaction = 5.6
		end
    return cmp
	end
		
  def Organic.calc(cmp, climatePoly, coeff)
    # calculate rating
    # soil climate (Z)
    cmp.TemperatureDeduction = Calculate.constrain( (coeff.Za + coeff.Zb * climatePoly.egdd), 0, 25)
    cmp.OrganicBaseRating = 100 - cmp.TemperatureDeduction
    # moisture deficit factor (M)
    cmp.WaterCapacityDeduction = [(40 * ( [cmp.SurfaceFibre,0].max / 80) ) - (((250 + climatePoly.ppe) / 50) * 5), 0].max
    if cmp.SubsurfaceFibre < 0 then subsurfaceFibre = 0.01 else subsurfaceFibre = cmp.SubsurfaceFibre end
    cmp.WaterTableAdjustment = cmp.WaterCapacityDeduction * (100 - ((cmp.WaterTableDepth ** 2) / 12) / (5 + (10 / (0.1 * subsurfaceFibre))) ) / -100
    cmp.MoistureDeficitDeduction = cmp.WaterCapacityDeduction + cmp.WaterTableAdjustment
    cmp.InterimRating = cmp.OrganicBaseRating -  cmp.MoistureDeficitDeduction
    # surface factors (sf)
    # surface structure deduction (B)
    cmp.SurfaceStructureDeduction = [(40.00873619 + -2.3912966 * cmp.SurfaceFibre + 0.213398324 * climatePoly.ppe + 0.045354094 * cmp.SurfaceFibre ** 2 + 0.000614069 * climatePoly.ppe ** 2 + -0.009623 * cmp.SurfaceFibre * climatePoly.ppe + -0.0002331 * cmp.SurfaceFibre ** 3 +2.78E-07 * climatePoly.ppe ** 3 + -3.53E-06 * cmp.SurfaceFibre * climatePoly.ppe ** 2 + 7.33E-05 * cmp.SurfaceFibre ** 2 * climatePoly.ppe),0].max
    # surface reaction deduction (V)
    if cmp.SurfaceReaction < 5.5 then
      cmp.SurfaceReactionDeduction = [(40*((Math.sqrt(cmp.SurfaceFibre)) / 8.9)) + (((5.5 - cmp.SurfaceReaction) / 0.1) * ( 1 + ((Math.sqrt( 100 / (cmp.SurfaceFibre+0.1))) * 0.1))),0].max 
      else 
      cmp.SurfaceReactionDeduction = [(40 * ((Math.sqrt(cmp.SurfaceFibre)) / 8.9)),0].max
    end
    # surface salinity deduction (N) - Table 5.7
    cmp.SurfaceSalinityDeductionInterim = (-13.230275*22.752925 + 94.480275 * cmp.SurfaceSalinity ** 1.67181) / (22.752925 + cmp.SurfaceSalinity ** 1.67181) 
    cmp.SurfaceSalinityDeduction = Calculate.constrain(cmp.SurfaceSalinityDeductionInterim,0,100).to_f
    cmp.SurfaceMostLimitingDeduction = [cmp.SurfaceReactionDeduction,cmp.SurfaceSalinityDeduction].max
    cmp.SurfaceTotalDeductions = Calculate.constrain(cmp.SurfaceStructureDeduction + cmp.SurfaceMostLimitingDeduction,0,100)
    cmp.SurfaceFinalDeduction = (cmp.SurfaceTotalDeductions.to_f / 100) * cmp.InterimRating
    cmp.BasicOrganicRating = cmp.InterimRating - cmp.SurfaceFinalDeduction
    # subsurface factors
    # subsurface structure deduction (B) - Table 5.8
    #subsurfaceFibre = [cmp.SubsurfaceFibre,0].max # removed Jan 26 2010 to eliminate error - should be OK because of line 169
    if subsurfaceFibre >= 40 then
      cmp.SubsurfaceStructureDeduction = -20 + 0.5 * subsurfaceFibre
      elsif subsurfaceFibre > 20
      cmp.SubsurfaceStructureDeduction = 0
      else
      cmp.SubsurfaceStructureDeduction = (20 + -1 * subsurfaceFibre ) / (1 + 0.1 *  subsurfaceFibre)
    end
    # subsurface substrate deduction (G) - Table 5.9
    cmp.SubsurfaceSubstrateDeduction = 0 # force zero to start with to prevent errors (not in prototype)
    if cmp.OrganicDepth >= 140 then cmp.SubsurfaceSubstrateDeduction = 0 
      else
      if cmp.SubSubsurfaceHZNMAS == "R" then cmp.SubsurfaceSubstrateDeduction = ((120 - cmp.OrganicDepth) * 0.8) + (10 + ((climatePoly.ppe) / -15)) end
      if cmp.SubSubsurfaceHZNMAS == "CO" then cmp.SubsurfaceSubstrateDeduction = ((120 - cmp.OrganicDepth) * 0.7) + ( 5 + ((climatePoly.ppe) / -15)) end
      if cmp.SubSubsurfaceHZNMAS == ("C" or "A") then 
        if cmp.SubSubsurfaceCofrag >= 20 then 
          cmp.SubsurfaceSubstrateDeduction = ((120-D)*0.6)+((climatePoly.ppe)/-15) 
          else
          cmp.SubsurfaceSubstrateDeduction = (((100 - cmp.OrganicDepth) * 0.6) * ((cmp.SubSubsurfaceTsilt + cmp.SubSubsurfaceTclay) / 80)) + ((climatePoly.ppe)/-15) 
        end
      end
    end
    cmp.SubsurfaceSubstrateDeduction = [cmp.SubsurfaceSubstrateDeduction,0].max
    # subsurface reaction deduction (V) - Table 5.10
    cmp.SubsurfaceReactionDeduction = [((6.0 - cmp.SubsurfaceReaction) * 10),0].max
    # subsurface salinity deduction (N) - Table 5.11
    cmp.SubsurfaceSalinityDeduction = [(-13.333333 + 3.75 * cmp.SubsurfaceSalinity + -0.10416667 * cmp.SubsurfaceSalinity ** 2),0].max
    cmp.SubsurfaceMostLimitingDeduction = [cmp.SubsurfaceReactionDeduction,cmp.SubsurfaceSalinityDeduction].max
    cmp.SubsurfaceTotalDeductions = cmp.SubsurfaceStructureDeduction + cmp.SubsurfaceSubstrateDeduction + cmp.SubsurfaceMostLimitingDeduction
    cmp.SubsurfaceFinalDeduction = (cmp.SubsurfaceTotalDeductions.to_f / 100) * cmp.BasicOrganicRating
    cmp.InterimFinalRating = cmp.BasicOrganicRating - cmp.SubsurfaceFinalDeduction
    # drainage deduction (W) Tables 5.12, 5.13, 5.14
    subsurfaceFibre = [cmp.SubsurfaceFibre,0].max
    waterTableDepth = [cmp.WaterTableDepth,0].max
    if climatePoly.ppe < 150 then
      cmp.DrainagePercentReduction = Calculate.constrain((100 - (((((climatePoly.ppe) - 150) / -150) ** 2) * (Math.sqrt(subsurfaceFibre / 10))) - (waterTableDepth * Math.sqrt(((climatePoly.ppe) - 150) / -300))),0,100)
    else # bug 46
      cmp.DrainagePercentReduction = 100
    end
    cmp.DrainageDeduction = (cmp.DrainagePercentReduction / 100) * cmp.InterimFinalRating
    cmp.FinalSoilRating = (cmp.InterimFinalRating - cmp.DrainageDeduction).round
    cmp.SoilClass = Calculate.rating(cmp.FinalSoilRating) 
    # End of Horizon processing for ORGANIC component.
    return cmp
  end # def Organic.calc
  
end

