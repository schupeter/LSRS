class Mineral

  def Mineral.params(mineralParams)
    mineralCoeff = LsrsMineralCoeffClass.new
    mineralCoeff.AWHCa = mineralParams[0].AWHCa.to_f 
    mineralCoeff.SurDa = mineralParams[0].SurDa.to_f   # Surface D a 
    mineralCoeff.SurDb = mineralParams[0].SurDb.to_f
    mineralCoeff.SurDc = mineralParams[0].SurDc.to_f 
    mineralCoeff.SurV0a = mineralParams[0].SurV0a.to_f 
    mineralCoeff.SurV1a = mineralParams[0].SurV1a.to_f 
    mineralCoeff.SurV1b = mineralParams[0].SurV1b.to_f 
    mineralCoeff.SurV1c = mineralParams[0].SurV1c.to_f 
    mineralCoeff.SubVpHlimit = mineralParams[0].SubVpHlimit.to_f 
    mineralCoeff.SubVa = mineralParams[0].SubVa.to_f 
    mineralCoeff.SubVb = mineralParams[0].SubVb.to_f 
    mineralCoeff.SubVc = mineralParams[0].SubVc.to_f 
    mineralCoeff.SubVd = mineralParams[0].SubVd.to_f 
    return mineralCoeff
  end

  def Mineral.inputsSLC(cmp, component, name)
    # SNF/SLF records retrieved.  Calculate rating inputs.
    # Get "order" from selected record in the SNF file and set the Current order.
    cmp.order = name.order3
    # Get the Drainage Class.
    cmp.DrainageClass = name.drainage
    return cmp
  end

  def Mineral.inputsFake(cmp)
    # When name record is missing, add some fake values to prevent crashes.
    cmp.order = "-"
    cmp.DrainageClass = "-"
    return cmp
  end

  def Mineral.horizonsSLC(cmp, layerRecords, climatePoly)
    # Horizon Processing if MINERAL component.
    # initialize values for horizon processing
    cmp.OrganicDepth = 0
    cmp.OrganicBD = 0.0
    cmp.SurfaceDepth = 20
    cmp.SurfaceSi = 0
    cmp.SurfaceC = 0
    cmp.SurfaceCF = 0
    cmp.SurfaceOC = 0.0
    cmp.SurfaceReaction = 0.0
    cmp.SurfaceSalinity = 0.0
    cmp.SurfaceSodicity = 0.0
    cmp.SurfaceKP0 = 0.0
    cmp.SurfaceDepthTopSoil = -1
    cmp.SubsurfaceDepth = 100
    cmp.SubsurfaceSi = 0
    cmp.SubsurfaceC = 0
    cmp.SubsurfaceCF = 0
    cmp.SubsurfaceReaction = 0.0
    cmp.SubsurfaceSalinity = 0.0
    cmp.SubsurfaceSodicity = 0.0
    cmp.SubsurfaceKP0 = 0.0
    cmp.SubsurfaceImpedenceDeduction = 0
    cmp.SubsurfaceHighestImpedenceDeduction = -1.0
    cmp.SubsurfaceHighestImpedenceBD = -1.0
    cmp.SubsurfaceHighestImpedenceUpperDepth = -1
    cmp.SubsurfaceImpedenceDepth = -1
    cmp.TotalHighestImpedence = -1.0
    cmp.TotalHighestImpedenceUpperDepth = 0
    # Get special upper and lower depths
    cmp.OrganicDepth = layerRecords[0].udepth.abs
    # If the lower depth is less than 100, then we have to adjust the subsurfacedepth to whatever the lower depth is.
    if (cmp.SubsurfaceDepth > layerRecords[-1].ldepth ) then cmp.SubsurfaceDepth = layerRecords[-1].ldepth end
    # determine BD value
    cmp.bd = layerRecords[-1].bd
    # If HZN_MAS is "R" (Rock) and bd = -9 then set bd to 2.5. This is to take into account NSDB data having no data value for BD and to allow for proper horizon processing.
    if ( layerRecords[-1].hzn_mas == "R" ) then cmp.bd = 2.5 end
    if cmp.bd > 1.9 then
      if ( layerRecords[-1].udepth > 20 ) then ( cmp.SubsurfaceDepth = layerRecords[-1].udepth ) else cmp.SubsurfaceDepth = 20 end
    end
    # start processing horizons
    lyrArray = Array.new
    for layer in layerRecords do
      lyr = LsrsLyrMineralClass.new
      if layer.udepth == nil then lyr.udepth = 0 else lyr.udepth = layer.udepth end 
      lyr.ldepth = layer.ldepth
      lyr.bd = layer.bd
      if layer.cofrag == -9 then lyr.cofrag = 0 else lyr.cofrag = layer.cofrag end # fix bug 46
      if layer.tsilt == -9 then lyr.tsilt = 0 else lyr.tsilt = layer.tsilt end # fix bug 46
      if layer.tclay == -9 then lyr.tclay = 0 else lyr.tclay = layer.tclay end # fix bug 46
      if layer.orgcarb == -9.0 then lyr.orgcarb = 0.0 else lyr.orgcarb = layer.orgcarb end # fix bug 46
      if layer.ph2 == -9.0 then lyr.ph2 = 0.0 else lyr.ph2 = layer.ph2 end # fix bug 46
      if layer.ec == -9 then lyr.ec = 0 else lyr.ec = layer.ec end # fix bug 46
      if layer.kp0 == -9 then lyr.kp0 = 0 else lyr.kp0 = layer.kp0 end # fix bug 46
      lyr.hznmas = layer.hzn_mas
      #determine horizon assignment factors
      lyr.OrganicFactor = lyr.SurfaceFactor = lyr.SubsurfaceFactor = 0.0
      # For SLC / NSDB there is no Texture field.  We need this to determine Surface Organic Depth.  For the purposes of our calculation we will proxy a ORG texture for the horizon if the UpperDepth < 0.
      if ( lyr.udepth < 0) then 
        lyr.texture = "ORG" 
        lyr.OrganicFactor = ( lyr.udepth.abs - lyr.ldepth.abs ) / cmp.OrganicDepth.to_f
      else
        # calc surfaceFactor
        if lyr.udepth < cmp.SurfaceDepth then
          lyr.SurfaceFactor = ( [cmp.SurfaceDepth, lyr.ldepth].min - lyr.udepth ) / cmp.SurfaceDepth.to_f
        end
        # calc subsurfaceFactor
        if lyr.ldepth > cmp.SurfaceDepth then
          if cmp.SubsurfaceDepth == cmp.SurfaceDepth then
            lyr.SubsurfaceFactor = 0.0 # fix bug 46
          else
            lyr.SubsurfaceFactor = ( [cmp.SubsurfaceDepth, lyr.ldepth].min - [cmp.SurfaceDepth, lyr.udepth].max ) / ( cmp.SubsurfaceDepth - cmp.SurfaceDepth ).to_f
          end
        end
        if lyr.udepth > cmp.SubsurfaceDepth then lyr.SubsurfaceFactor = 0.0 end # fix bug 23
        #if lyr.SubsurfaceFactor.nan? then lyr.SubsurfaceFactor = 0 end # fix bug 46
      end
      # First -- Above surface variables.
      cmp.OrganicBD = cmp.OrganicBD + lyr.bd * lyr.OrganicFactor # fix bug 343
      # Next -- surface variables.
      cmp.SurfaceSi = cmp.SurfaceSi + lyr.tsilt * lyr.SurfaceFactor # fix bug 343
      cmp.SurfaceC = cmp.SurfaceC + lyr.tclay * lyr.SurfaceFactor # fix bug 343
      cmp.SurfaceCF = cmp.SurfaceCF + lyr.cofrag * lyr.SurfaceFactor # fix bug 343
      cmp.SurfaceOC = cmp.SurfaceOC + lyr.orgcarb * lyr.SurfaceFactor # fix bug 343
      cmp.SurfaceReaction = cmp.SurfaceReaction + lyr.ph2 * lyr.SurfaceFactor # fix bug 343
#      cmp.SurfaceSalinity = cmp.SurfaceSalinity + layer.ec * lyr.SurfaceFactor
      if layer.ec > 0 then cmp.SurfaceSalinity = cmp.SurfaceSalinity + lyr.ec * lyr.SurfaceFactor end # fix bug 46 # fix bug 343
      cmp.SurfaceKP0 = cmp.SurfaceKP0 + lyr.kp0 * lyr.SurfaceFactor # fix bug 343
      # Finally -- subsurface variables.
      cmp.SubsurfaceSi = cmp.SubsurfaceSi + lyr.tsilt * lyr.SubsurfaceFactor # fix bug 343
      cmp.SubsurfaceC = cmp.SubsurfaceC + lyr.tclay * lyr.SubsurfaceFactor # fix bug 343
      cmp.SubsurfaceCF = cmp.SubsurfaceCF + lyr.cofrag * lyr.SubsurfaceFactor # fix bug 343
      cmp.SubsurfaceReaction = cmp.SubsurfaceReaction + lyr.ph2 * lyr.SubsurfaceFactor # fix bug 343
      cmp.SubsurfaceSalinity = cmp.SubsurfaceSalinity + lyr.ec * lyr.SubsurfaceFactor # fix bug 343
      cmp.SubsurfaceKP0 = cmp.SubsurfaceKP0 + lyr.kp0 * lyr.SubsurfaceFactor # fix bug 343
      # Depth of TopSoil
      # impedenceValue = ((layer.bd - 1.60)*200.0) + (0.15 * layer.tclay ** 1.33) # DELETED 20100914
      # impedenceValue = ((layer.bd - 1.60) * 200.0) + layer.tclay # DELETED 20100920
      lyr.ImpedenceClayDeduction = Calculate.constrain( ( (lyr.bd - 1.60) * 200.0 + lyr.tclay), 0, 90)
			#lyr.ImpedenceClayDeduction = Calculate.constrain( ( (lyr.bd - 1.60) * 200.0 + (0.15 * layer.tclay ** 1.33)), 0, 90) # this could be applied in region 1 only
      # set MineralSurfaceDepthTopSoil if it has not been determined.
      # if ( (cmp.SurfaceDepthTopSoil == -1) and (impedenceValue > 25.0) ) then cmp.SurfaceDepthTopSoil = lyr.udepth end # DELETED 20100914
      #if ( (cmp.SurfaceDepthTopSoil == -1) and (impedenceValue > 20.0) ) then cmp.SurfaceDepthTopSoil = lyr.udepth end # DELETED 20100920
      if ( (cmp.SurfaceDepthTopSoil == -1) and (lyr.ImpedenceClayDeduction > 20.0) ) then cmp.SurfaceDepthTopSoil = lyr.udepth end
      # Determine the layer impedence using Table 4.12
      lyr.ImpedenceModificationDeduction = Calculate.constrain( ((100 - (((350 + climatePoly.ppe) / 100) * 3)) - ((lyr.udepth - 20) * (Math.log10(10 + 2 * (350 + climatePoly.ppe) / 100)))), 0, 100)
      lyr.ImpedenceDeduction = lyr.ImpedenceModificationDeduction / 100 * lyr.ImpedenceClayDeduction
      
      # Determine the highest impedence value in or partially in the Subsurface, and its upper depth.
      if ( (lyr.udepth <= cmp.SubsurfaceDepth) and (lyr.ldepth > cmp.SurfaceDepth) and (lyr.ImpedenceDeduction > cmp.SubsurfaceHighestImpedenceDeduction) ) then
        cmp.SubsurfaceHighestImpedenceUpperDepth = lyr.udepth
        cmp.SubsurfaceHighestImpedenceBD = lyr.bd
        cmp.SubsurfaceHighestImpedenceClay = lyr.tclay
        cmp.SubsurfaceHighestImpedenceClayDeduction = lyr.ImpedenceClayDeduction
        cmp.SubsurfaceHighestImpedenceModificationDeduction = lyr.ImpedenceModificationDeduction
        cmp.SubsurfaceHighestImpedenceDeduction = lyr.ImpedenceDeduction
      end
      # Similarly, now determine the highest impedence value in the entire profile and its upper depth.
      if (lyr.bd > cmp.TotalHighestImpedence) then
        cmp.TotalHighestImpedence = lyr.ImpedenceDeduction
        cmp.TotalHighestImpedenceUpperDepth = lyr.udepth
      end
      lyrArray.push lyr
    end # layer
    #populate cmp with layers
    cmp.layers = lyrArray
    return cmp
  end

  def Mineral.validateHorizons(cmp)
    # check content of mineral data
    # Check and set %Si and %C values. If -9 (no value) then set to zero.  FIX THIS EARLIER - MAY FIND MISSING VALUES FOR ONLY A FEW LAYERS - WAS FIXED SO SHOULD BE SAFE TO REMOVE
    if (cmp.SurfaceSi == -9) then cmp.SurfaceSi = 0 end
    if (cmp.SurfaceC == -9) then cmp.SurfaceC = 0 end
    if (cmp.SubsurfaceSi == -9) then cmp.SubsurfaceSi = 0 end
    if (cmp.SubsurfaceC == -9) then cmp.SubsurfaceC = 0 end
    # Proxy the water table depth from the drainage class.
    cmp.WaterTableDepth = -1
    if (cmp.DrainageClass == 'VP') then cmp.WaterTableDepth = 0 end
    if (cmp.DrainageClass == 'P')  then cmp.WaterTableDepth = 25 end
    if (cmp.DrainageClass == 'PI') then cmp.WaterTableDepth = 50 end
    if (cmp.DrainageClass == 'I')  then cmp.WaterTableDepth = 75 end
    if (cmp.DrainageClass == 'MW') then cmp.WaterTableDepth = 100 end
    if (cmp.DrainageClass == 'W')  then cmp.WaterTableDepth = 125 end
    if (cmp.DrainageClass == '-')  then cmp.WaterTableDepth = 100 end
    if (cmp.DrainageClass == 'R')  then cmp.WaterTableDepth = 150 end
    # "V", "VR", and "M" added for slc/NSDB.
    if (cmp.DrainageClass == 'V')  then cmp.WaterTableDepth = 0 end
    if (cmp.DrainageClass == 'VR') then cmp.WaterTableDepth = 150 end
    if (cmp.DrainageClass == 'M')  then cmp.WaterTableDepth = 100 end
    if (cmp.WaterTableDepth < 0) then cmp.WaterTableDepth = 100 end
    # Check and set Topsoil depth for correct range [ 0 to 20 ].
    if (cmp.SurfaceDepthTopSoil < 0) then cmp.SurfaceDepthTopSoil = cmp.SurfaceDepth end
    if (cmp.SurfaceDepthTopSoil > cmp.SurfaceDepth) then cmp.SurfaceDepthTopSoil = cmp.SurfaceDepth end
    # Do extra checking for -9 values -- this means no value.
    if (cmp.SurfaceReaction == -9) then cmp.SurfaceReaction = 7 end
    if (cmp.SurfaceSalinity == -9) then cmp.SurfaceSalinity = 0 end
    # Proxy surface KP0 -- saturation % -- to SAR 
    if (cmp.SurfaceKP0 == -9) then cmp.SurfaceSodicity = 0 else
      cmp.SurfaceSodicity = (-1.6517633e11 + 3.6390917e9 * cmp.SurfaceKP0) / (1 + 2.454059e8 * cmp.SurfaceKP0 + -509457.85 * cmp.SurfaceKP0 ** 2)
    end
    # If the proxy calculations produce a negative number for surface sodicity we set it to 0. 
    if (cmp.SurfaceSodicity < 0 ) then cmp.SurfaceSodicity = 0 end
    # Check and set Subsurface Impeding Depth to correct range [ 20 - 100 ].
    #NOTE: Check for the Surface value after checking SubsurfaceDepth to properly catch layers with upperdepth less than 20.  Make sure that Highest Subsurface Impedence Value is set right.
    if (cmp.SubsurfaceHighestImpedenceDeduction > -1) then
      cmp.SubsurfaceImpedenceDepth = cmp.SubsurfaceHighestImpedenceUpperDepth
    else
      cmp.SubsurfaceImpedenceDepth = cmp.SurfaceDepth
      cmp.SubsurfaceHighestImpedenceDeduction = cmp.TotalHighestImpedence
    end
    # Again do extra checking for -9 values -- this means no value.
    if (cmp.SubsurfaceReaction == -9) then cmp.SubsurfaceReaction = 7 end
    if (cmp.SubsurfaceSalinity == -9) then cmp.SubsurfaceSalinity = 0 end
    #Proxy subsurface KP0 - saturation % - to SAR
    if (cmp.SubsurfaceKP0 == -9) then cmp.SubsurfaceSodicity = 0 else
      cmp.SubsurfaceSodicity = (-1.6517633e11 + 3.6390917e9 * cmp.SubsurfaceKP0) / (1 + 2.454059e8 * cmp.SubsurfaceKP0 + -509457.85 * cmp.SubsurfaceKP0 ** 2)
    end
    # If the proxy calculations produce a negative number for subsurface sodicity we set it to 0.
    if (cmp.SubsurfaceSodicity < 0 ) then cmp.SubsurfaceSodicity = 0 end
    return cmp
  end

  def Mineral.management(cmp, manageByCrop)
		# adjust values based on soil management practices
		# set all water table depths to assume tile drainage
		if cmp.WaterTableDepth < 100 then 
			cmp.WaterTableDepth = 100
			cmp.ManagedWaterTableDepth = cmp.WaterTableDepth
		end
		#assume ability to apply required amounts of lime
		if cmp.SurfaceReaction < manageByCrop.ph then 
			cmp.SurfaceReaction = manageByCrop.ph
			cmp.ManagedReaction = manageByCrop.ph
		end
    return cmp
	end

  def Mineral.NotSoil(cmp)
    #This was set up to handle components included in Agrasid which were not true Mineral or Organic. It is carried over for SLC/NSDB data.
    #This has no ORDER but it still needs to be processed in order to get proper ratings.
    cmp.SurfaceSTP = 0
    cmp.SurfaceAWHCdeduction1 = 0
    cmp.SurfaceAWHCdeduction2 = 0
    cmp.SurfaceAWHCdedn1and2 = 0
    cmp.SurfaceAWHCdeduction = 0
    cmp.SubsurfaceSTP = 0
    cmp.MSTP = 0
    cmp.SubsurfaceAWHCdeduction1 = 0
    cmp.SubsurfaceAWHCdeduction2 = 0
    cmp.SubsurfaceAWHCdedn1and2 = 0
    cmp.SubsurfaceAWHCdeduction = 0
    cmp.SubsurfaceAdjustment = 0
    cmp.SubtotalTextureDeduction = 0
    cmp.WaterTableDeduction = 0
    cmp.MoistureReductionAmount = 0
    cmp.MoistureDeduction = 0
    cmp.OrganicDeductionO = 0
    cmp.SurfaceS = 0
    cmp.SurfaceDeductionD = 0  
    cmp.SurfaceDeductionF = 0
    cmp.SurfaceDeductionE = 0
    cmp.SurfaceReactionDeductionInterim = 0
    cmp.SurfaceSodicityDeductionInterim = 0
    cmp.SubsurfaceSodicityDeductionInterim = 0
    cmp.SurfaceSalinityDeductionInterim = 0
    cmp.SubsurfaceSalinityDeductionInterim = 0
    cmp.SurfaceSodicityDeduction = 0
    cmp.SurfaceSalinityDeduction = 0
    cmp.SubsurfaceClayDeduction = 0
    cmp.SubsurfaceHighestImpedenceModificationDeduction = 0
    cmp.SubsurfaceHighestImpedenceDeduction = 0
    cmp.SubsurfaceSalinityDeduction  = 0 
    cmp.SubsurfaceSodicityDeductionInterim = 0 
    cmp.SubsurfaceReactionDeductionInterimPre = 0
    cmp.SubsurfaceReactionDeductionInterim = 0
    cmp.SubsurfaceReactionDeduction = 0
    cmp.SurfaceReactionDeduction = 0
    cmp.SurfaceMostLimitingDeduction = 0
    cmp.SurfaceTotalDeductions = 0
    cmp.SurfaceInterimSoilRating = 0
    cmp.SubsurfaceMostLimitingDeduction = 0
    cmp.SubsurfacePercentReduction = 0
    cmp.SubsurfaceDeduction = 0
    cmp.InterimBasicSoilRating = 0
    cmp.DrainagePercentReduction = 0
    cmp.DrainageDeduction = 0
    cmp.FinalSoilRating = 0
    cmp.FinalBasicSoilRating = 0
    cmp.SoilClass = "NotRated"
    case cmp.SoilCode
      when "ZZZ" then type = "Water"
      when "ZWA" then type = "Water"
      else type = "Rock"
    end
    if type == "Water" then
      cmp.DrainagePercentReduction = 100
      cmp.DrainageDeduction = 100
    else # Rock
      cmp.SubsurfaceImpedenceDeduction = 100
      cmp.SubsurfacePercentReduction = 100
      cmp.SubsurfaceDeduction = 100
    end
    return cmp
  end

  def Mineral.calc(cmp, climatePoly, coeff, deductions)
    # calculate rating
    # surface moisture factor = Table 4.2
    cmp.SurfaceSTP = ( cmp.SurfaceSi + cmp.SurfaceC ) * ( 1 - cmp.SurfaceCF / 100 )
    cmp.SurfaceAWHCdeduction1 = ( coeff.AWHCa + climatePoly.ppe ) * -0.2
    if cmp.SurfaceSTP < 0 then
      cmp.SurfaceAWHCdeduction2 = 60 - 1.5 * cmp.SurfaceSTP
    else
      cmp.SurfaceAWHCdeduction2 = 28 - ( 1 / Math.sqrt( [-1.0, climatePoly.ppe].min / -100 ) ) * ( cmp.SurfaceSTP - 20 )
    end
    cmp.SurfaceAWHCdedn1and2 = cmp.SurfaceAWHCdeduction1 + [0, cmp.SurfaceAWHCdeduction2].max
    cmp.SurfaceAWHCdeduction = [0, cmp.SurfaceAWHCdedn1and2].max
    # subsurface texture factor = Table 4.3
    cmp.SubsurfaceSTP = ( cmp.SubsurfaceSi + cmp.SubsurfaceC ) * ( 1 - cmp.SubsurfaceCF / 100 )
    cmp.MSTP = ( cmp.SurfaceSTP + cmp.SubsurfaceSTP ) / 2
    cmp.SubsurfaceAWHCdeduction1 = ( 150 + climatePoly.ppe ) * -0.2
    if cmp.MSTP <= 20 then
      cmp.SubsurfaceAWHCdeduction2 = 60 - 1.5 * cmp.MSTP
    else
      cmp.SubsurfaceAWHCdeduction2 = 28 - ( 1 / Math.sqrt( [-1.0, climatePoly.ppe].min / -100 ) ) * ( cmp.MSTP - 20 )
    end
    cmp.SubsurfaceAWHCdedn1and2 = cmp.SubsurfaceAWHCdeduction1 + [0, cmp.SubsurfaceAWHCdeduction2].max
    cmp.SubsurfaceAWHCdeduction = [0, cmp.SubsurfaceAWHCdedn1and2].max
    cmp.SubsurfaceAdjustment = cmp.SubsurfaceAWHCdeduction - cmp.SurfaceAWHCdeduction
    cmp.SubtotalTextureDeduction = cmp.SurfaceAWHCdeduction + cmp.SubsurfaceAdjustment
    # water table deduction = Table 4.4
    if cmp.WaterTableDepth == 0 then cmp.WTD = 0.000001 else cmp.WTD = cmp.WaterTableDepth end
    cmp.WaterTableDeduction = 100 - cmp.WTD * ( Math.log10(cmp.WTD) ** 3 ) / ( 6 + ( cmp.SurfaceSi + cmp.SurfaceC ) / 25 )
    cmp.WaterTableDeduction = [[cmp.WaterTableDeduction, 0].max, 100].min
    cmp.MoistureReductionAmount = (cmp.WaterTableDeduction / 100.0 ) * cmp.SubtotalTextureDeduction 
    cmp.MoistureDeduction = [(cmp.SubtotalTextureDeduction - cmp.MoistureReductionAmount) , 70].min
    #other surface factors
    # organic (peaty) surface = table 4.11
    if cmp.OrganicBD == 0 then organicBD = 0.12 else organicBD = cmp.OrganicBD end
    if cmp.OrganicDepth - 10 < 0 then cmp.OrganicDeductionO = 0 else cmp.OrganicDeductionO = (cmp.OrganicDepth - 10) * (Math.sqrt(0.12) / Math.sqrt(organicBD)) end
    cmp.OrganicDeductionO = Calculate.constrain( (cmp.OrganicDeductionO), 0, 100)
    # Surface / Consistence = table 4.5
    cmp.SurfaceS = 100 - cmp.SurfaceSi - cmp.SurfaceC
    surfaceOC = [cmp.SurfaceOC, 0.000001].max
    surfaceS = [([cmp.SurfaceS, 0].max - 60), 0].max
    surfaceSi = [([cmp.SurfaceSi, 0].max - 50), 0].max
    surfaceC = [([cmp.SurfaceC, 0].max - 50), 0].max
    if surfaceOC > 2.5 then cmp.SurfaceDeductionD = 0 
      elsif cmp.OrganicDeductionO > 0 then cmp.SurfaceDeductionD = 0  
      else cmp.SurfaceDeductionD = [( (2.5 / surfaceOC) + ((surfaceS)/3 * surfaceOC) + ((surfaceSi) / (surfaceOC * coeff.SurDa)) + ((surfaceC) / (surfaceOC * coeff.SurDb)) ).abs, 10].min
    end
    # surface structure / consistence = table 4.6
    if cmp.SurfaceOC == 0 then surfaceOC = 0.000001 else surfaceOC = cmp.SurfaceOC end
    cmp.SurfaceDeductionF = Calculate.constrain( ( 9.9928375 + -7.229321 * Math.log(surfaceOC) ), 0, 15)
    if cmp.OrganicDeductionO > 0 then cmp.SurfaceDeductionF = 0 end
    # depth of top soil = Table 4.7
    cmp.SurfaceDeductionE = [(20 + (-1 * cmp.SurfaceDepthTopSoil) ), 20].min
    # reaction - soil pH = Table 4.8
    if cmp.SurfaceReaction < coeff.SurV0a then
      cmp.SurfaceReactionDeductionInterim = Calculate.constrain( (coeff.SurV1a+ (coeff.SurV1b * cmp.SurfaceReaction ) + coeff.SurV1c * cmp.SurfaceReaction ** 2 ), 0, 100)
    elsif cmp.SurfaceReaction > 7.5 then 
      cmp.SurfaceReactionDeductionInterim = Calculate.constrain( ( (-20.543722 + 2.7164411 * cmp.SurfaceReaction ) / ( 1 + (-0.07521742 * cmp.SurfaceReaction) + (-0.0031859168 * cmp.SurfaceReaction ** 2 ) ) ), 0, 100)
    else cmp.SurfaceReactionDeductionInterim = 0
    end
    # Surface sodicity - SAR - Table 4.10
    cmp.SurfaceSodicityDeductionInterim = Calculate.constrain( ( -6 + 0.71428571 * cmp.SurfaceSodicity + 0.17857143 ** cmp.SurfaceSodicity ), 0, 100 )
    # Subsurface Sodicity - Table 4.17
    cmp.SubsurfaceSodicityDeductionInterim = Calculate.constrain( (-6 + 0.71428571 * cmp.SubsurfaceSodicity + 0.17857143 * cmp.SubsurfaceSodicity ** 2), 0, 100)
    if cmp.SubsurfaceSi + cmp.SubsurfaceC > 50 then cmp.SubsurfaceSodicityDeductionInterim = 0 end
    # Surface salinity - EC - Table 4.9
#    cmp.SurfaceSalinityDeductionInterim = Calculate.constrain( ( (-28.704261 * 17.748344 + 278.70426 * cmp.SurfaceSalinity ** 0.87021431) / (17.748344 + cmp.SurfaceSalinity ** 0.87021431) ), 0, 100) # switched Nov 23 2015 to lookup
		cmp.SurfaceSalinityDeductionInterim = Calculate.lookup(cmp.SurfaceSalinity, deductions[:surfaceSalinity])
    if cmp.SurfaceSodicityDeductionInterim > cmp.SurfaceSalinityDeductionInterim then cmp.SurfaceSalinityDeductionInterim = 0 end
    # Subsurface Salinity - modified from Table 4.16 in LSRS manual
#    cmp.SubsurfaceSalinityDeductionInterim = Calculate.constrain( (-20 + 5.375 * cmp.SubsurfaceSalinity), 0, 100)# switched Nov 23 2015 to lookup
		cmp.SubsurfaceSalinityDeductionInterim = Calculate.lookup(cmp.SubsurfaceSalinity, deductions[:subsurfaceSalinity])
    if cmp.SubsurfaceSodicityDeductionInterim > cmp.SubsurfaceSalinityDeductionInterim then cmp.SubsurfaceSalinityDeductionInterim = 0 end
    # Surface sodicity final = Table 4.10
    if (cmp.SubsurfaceSodicityDeductionInterim / 100) * (100 - cmp.MoistureDeduction) >= cmp.SurfaceSodicityDeductionInterim then cmp.SurfaceSodicityDeduction = 0 else cmp.SurfaceSodicityDeduction = cmp.SurfaceSodicityDeductionInterim end
    # Surface salinity final = Table 4.9
    if (cmp.SubsurfaceSalinityDeductionInterim / 100) * (100 - cmp.MoistureDeduction) >= cmp.SurfaceSalinityDeductionInterim then cmp.SurfaceSalinityDeduction = 0 else cmp.SurfaceSalinityDeduction = cmp.SurfaceSalinityDeductionInterim end
    # other subsurface calcs
    # subsurface salinity = Table 4.16 continued
    if cmp.SubsurfaceImpedenceDeduction > 30 then cmp.SubsurfaceSalinityDeduction = 0 else
      if (cmp.SubsurfaceSalinityDeductionInterim / 100) * (100 - cmp.MoistureDeduction) < cmp.SurfaceSalinityDeductionInterim then 
        cmp.SubsurfaceSalinityDeduction  = 0 
        else
        cmp.SubsurfaceSalinityDeduction  = cmp.SubsurfaceSalinityDeductionInterim
      end
    end
    # subsurface sodicity = Table 4.17
    if cmp.SubsurfaceC + cmp.SubsurfaceSi > 50 then
      cmp.SubsurfaceSodicityDeductionInterim = 0 
      else 
      cmp.SubsurfaceSodicityDeductionInterim = Calculate.constrain((-6 + 0.71428571 * cmp.SubsurfaceSodicity + 0.17857143 * cmp.SubsurfaceSodicity ** 2), 0, 100)
    end
    if ( cmp.SubsurfaceSodicityDeductionInterim / 100) * (100 - cmp.MoistureDeduction) < cmp.SurfaceSodicityDeductionInterim then cmp.SubsurfaceSodicityDeduction = 0 else cmp.SubsurfaceSodicityDeduction = cmp.SubsurfaceSodicityDeductionInterim end
    # subsurface reaction (V) = Table 4.15 - note two different degrees of polynomial are managed with this one equation
    if cmp.SubsurfaceReaction >= coeff.SubVpHlimit then cmp.SubsurfaceReactionDeductionInterimPre = 0 else
      cmp.SubsurfaceReactionDeductionInterimPre = Calculate.constrain( (coeff.SubVa + coeff.SubVb * cmp.SubsurfaceReaction + coeff.SubVc * cmp.SubsurfaceReaction ** 2 + coeff.SubVd * cmp.SubsurfaceReaction ** 3), 0, 100)
    end
    cmp.SubsurfaceReactionDeductionInterim = Calculate.constrain(cmp.SubsurfaceReactionDeductionInterimPre, 0, 70)
    if cmp.SubsurfaceReactionDeductionInterim > 0 and cmp.SubsurfaceSalinityDeduction + cmp.SubsurfaceSodicityDeduction > 0 then cmp.SubsurfaceReactionDeduction =0 else
      if (cmp.SubsurfaceReactionDeductionInterim / 100) * (100 - cmp.MoistureDeduction) < cmp.SurfaceReactionDeductionInterim then cmp.SubsurfaceReactionDeduction = 0 else cmp.SubsurfaceReactionDeduction =cmp.SubsurfaceReactionDeductionInterim end
    end
    # surface reaction = Table 4.8  - calculate after subsurface reaction
    if cmp.SurfaceReactionDeductionInterim > 0 and cmp.SurfaceSodicityDeduction + cmp.SurfaceSalinityDeduction > 0 then
      cmp.SurfaceReactionDeduction = 0
    else
      if (cmp.SubsurfaceReactionDeductionInterimPre / 100) * (100 - cmp.MoistureDeduction) >= cmp.SurfaceReactionDeductionInterim then
        cmp.SurfaceReactionDeduction = 0
      else
        cmp.SurfaceReactionDeduction = cmp.SurfaceReactionDeductionInterim
      end
    end
    cmp.SurfaceMostLimitingDeduction = [cmp.SurfaceReactionDeduction, cmp.SurfaceSalinityDeduction, cmp.SurfaceSodicityDeduction].max
    cmp.SurfaceTotalDeductions = cmp.SurfaceDeductionD + cmp.SurfaceDeductionF + cmp.SurfaceDeductionE + cmp.SurfaceMostLimitingDeduction + cmp.OrganicDeductionO
    cmp.SurfaceInterimSoilRating = Calculate.constrain((100 - cmp.MoistureDeduction - cmp.SurfaceTotalDeductions), 0, 100)
    # max of subsurface deductions
    cmp.SubsurfaceMostLimitingDeduction = [cmp.SubsurfaceReactionDeduction, cmp.SubsurfaceSalinityDeduction, cmp.SubsurfaceSodicityDeduction].max
    cmp.SubsurfacePercentReduction = cmp.SubsurfaceHighestImpedenceDeduction + cmp.SubsurfaceMostLimitingDeduction
    #cmp.SubsurfaceDeduction = cmp.SubsurfacePercentReduction / 100 * cmp.SurfaceInterimSoilRating
    cmp.SubsurfaceDeduction = cmp.SurfaceInterimSoilRating * cmp.SubsurfacePercentReduction / 100
    cmp.InterimBasicSoilRating = cmp.SurfaceInterimSoilRating - cmp.SubsurfaceDeduction
    if cmp.InterimBasicSoilRating < 0 then cmp.FinalBasicSoilRating = 0 else cmp.FinalBasicSoilRating = cmp.InterimBasicSoilRating end
# Calculations for Drainage (W) = Tables 4.18, 4.19, 4.20
    if cmp.SurfaceSi == 0 then surfaceSi = 0.000001 else surfaceSi = cmp.SurfaceSi end
    if cmp.SurfaceC == 0 then surfaceC = 0.000001 else surfaceC = cmp.SurfaceC end
    cmp.DrainagePercentReduction = Calculate.constrain( ( (100 - ((100 + climatePoly.ppe) / -100) * 3) - (cmp.WaterTableDepth * (1.65 / Math.log10( surfaceSi + surfaceC))) ), 0, 100)
    cmp.DrainageDeduction = ( cmp.FinalBasicSoilRating * cmp.DrainagePercentReduction ) /100
    cmp.FinalSoilRating = (cmp.FinalBasicSoilRating - cmp.DrainageDeduction).round
    cmp.SoilClass = Calculate.rating(cmp.FinalSoilRating) 

# End of Horizon processing for MINERAL component.
    return cmp
  end
end

