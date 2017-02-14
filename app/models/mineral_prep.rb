 class MineralPrep

  def MineralPrep.inputs(soil)
    # SNF/SLF records retrieved.  Calculate rating inputs.
    # Get "order" from selected record in the SNF file and set the Current order.
    soil.order = soil.name.order3
    # Get the Drainage Class.
    soil.DrainageClass = soil.name.drainage
  end


  def MineralPrep.generalize_layers(soil, ppe)
    # Horizon Processing if MINERAL component.
    # initialize values for horizon processing
    soil.OrganicDepth = 0
    soil.OrganicBD = 0.0
    soil.SurfaceDepth = 20
    soil.SurfaceSi = 0
    soil.SurfaceC = 0
    soil.SurfaceCF = 0
    soil.SurfaceOC = 0.0
    soil.SurfaceReaction = 0.0
    soil.SurfaceSalinity = 0.0
    soil.SurfaceSodicity = 0.0
    soil.SurfaceKP0 = 0.0
    soil.SurfaceWood = 0
    soil.SurfaceDepthTopSoil = -1
    soil.SubsurfaceDepth = 100
    soil.SubsurfaceSi = 0
    soil.SubsurfaceC = 0
    soil.SubsurfaceCF = 0
    soil.SubsurfaceReaction = 0.0
    soil.SubsurfaceSalinity = 0.0
    soil.SubsurfaceSodicity = 0.0
    soil.SubsurfaceKP0 = 0.0
    soil.SubsurfaceWood = 0
    soil.SubsurfaceImpedenceDeduction = 0
    soil.SubsurfaceHighestImpedenceDeduction = -1.0
    soil.SubsurfaceHighestImpedenceBD = -1.0
    soil.SubsurfaceHighestImpedenceUpperDepth = -1
    soil.SubsurfaceImpedenceDepth = -1
    soil.TotalHighestImpedence = -1.0
    soil.TotalHighestImpedenceUpperDepth = 0
    # Get special upper and lower depths
    soil.OrganicDepth = soil.layers[0].udepth.abs
    # If the lower depth is less than 100, then we have to adjust the subsurfacedepth to whatever the lower depth is.
    if (soil.SubsurfaceDepth > soil.layers[-1].ldepth ) then soil.SubsurfaceDepth = soil.layers[-1].ldepth end
    # determine BD value
    soil.bd = soil.layers[-1].bd
    # If HZN_MAS is "R" (Rock) and bd = -9 then set bd to 2.5. This is to take into account NSDB data having no data value for BD and to allow for proper horizon processing.
    if ( soil.layers[-1].hzn_mas == "R" ) then soil.bd = 2.5 end
    if soil.bd > 1.9 then
      if ( soil.layers[-1].udepth > 20 ) then ( soil.SubsurfaceDepth = soil.layers[-1].udepth ) else soil.SubsurfaceDepth = 20 end
    end
    # start processing horizons
    lyrArray = Array.new
    for layer in soil.layers do
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
        lyr.OrganicFactor = ( lyr.udepth.abs - lyr.ldepth.abs ) / soil.OrganicDepth.to_f
      else
        # calc surfaceFactor
        if lyr.udepth < soil.SurfaceDepth then
          lyr.SurfaceFactor = ( [soil.SurfaceDepth, lyr.ldepth].min - lyr.udepth ) / soil.SurfaceDepth.to_f
        end
        # calc subsurfaceFactor
        if lyr.ldepth > soil.SurfaceDepth then
          if soil.SubsurfaceDepth == soil.SurfaceDepth then
            lyr.SubsurfaceFactor = 0.0 # fix bug 46
          else
            lyr.SubsurfaceFactor = ( [soil.SubsurfaceDepth, lyr.ldepth].min - [soil.SurfaceDepth, lyr.udepth].max ) / ( soil.SubsurfaceDepth - soil.SurfaceDepth ).to_f
          end
        end
        if lyr.udepth > soil.SubsurfaceDepth then lyr.SubsurfaceFactor = 0.0 end # fix bug 23
        #if lyr.SubsurfaceFactor.nan? then lyr.SubsurfaceFactor = 0 end # fix bug 46
      end
      # First -- Above surface variables.
      soil.OrganicBD = soil.OrganicBD + lyr.bd * lyr.OrganicFactor # fix bug 343
      # Next -- surface variables.
      soil.SurfaceSi = soil.SurfaceSi + lyr.tsilt * lyr.SurfaceFactor # fix bug 343
      soil.SurfaceC = soil.SurfaceC + lyr.tclay * lyr.SurfaceFactor # fix bug 343
      soil.SurfaceCF = soil.SurfaceCF + lyr.cofrag * lyr.SurfaceFactor # fix bug 343
      soil.SurfaceOC = soil.SurfaceOC + lyr.orgcarb * lyr.SurfaceFactor # fix bug 343
      soil.SurfaceReaction = soil.SurfaceReaction + lyr.ph2 * lyr.SurfaceFactor # fix bug 343
#      soil.SurfaceSalinity = soil.SurfaceSalinity + layer.ec * lyr.SurfaceFactor
      if layer.ec > 0 then soil.SurfaceSalinity = soil.SurfaceSalinity + lyr.ec * lyr.SurfaceFactor end # fix bug 46 # fix bug 343
      soil.SurfaceKP0 = soil.SurfaceKP0 + lyr.kp0 * lyr.SurfaceFactor # fix bug 343
      # Finally -- subsurface variables.
      soil.SubsurfaceSi = soil.SubsurfaceSi + lyr.tsilt * lyr.SubsurfaceFactor # fix bug 343
      soil.SubsurfaceC = soil.SubsurfaceC + lyr.tclay * lyr.SubsurfaceFactor # fix bug 343
      soil.SubsurfaceCF = soil.SubsurfaceCF + lyr.cofrag * lyr.SubsurfaceFactor # fix bug 343
      soil.SubsurfaceReaction = soil.SubsurfaceReaction + lyr.ph2 * lyr.SubsurfaceFactor # fix bug 343
      soil.SubsurfaceSalinity = soil.SubsurfaceSalinity + lyr.ec * lyr.SubsurfaceFactor # fix bug 343
      soil.SubsurfaceKP0 = soil.SubsurfaceKP0 + lyr.kp0 * lyr.SubsurfaceFactor # fix bug 343
      # Depth of TopSoil
      # impedenceValue = ((layer.bd - 1.60)*200.0) + (0.15 * layer.tclay ** 1.33) # DELETED 20100914
      # impedenceValue = ((layer.bd - 1.60) * 200.0) + layer.tclay # DELETED 20100920
      lyr.ImpedenceClayDeduction = Calculate.constrain( ( (lyr.bd - 1.60) * 200.0 + lyr.tclay), 0, 90)
			#lyr.ImpedenceClayDeduction = Calculate.constrain( ( (lyr.bd - 1.60) * 200.0 + (0.15 * layer.tclay ** 1.33)), 0, 90) # this could be applied in region 1 only
      # set MineralSurfaceDepthTopSoil if it has not been determined.
      # if ( (soil.SurfaceDepthTopSoil == -1) and (impedenceValue > 25.0) ) then soil.SurfaceDepthTopSoil = lyr.udepth end # DELETED 20100914
      #if ( (soil.SurfaceDepthTopSoil == -1) and (impedenceValue > 20.0) ) then soil.SurfaceDepthTopSoil = lyr.udepth end # DELETED 20100920
      if ( (soil.SurfaceDepthTopSoil == -1) and (lyr.ImpedenceClayDeduction > 20.0) ) then soil.SurfaceDepthTopSoil = lyr.udepth end
      # Determine the layer impedence using Table 4.12
      lyr.ImpedenceModificationDeduction = Calculate.constrain( ((100 - (((350 + ppe) / 100) * 3)) - ((lyr.udepth - 20) * (Math.log10(10 + 2 * (350 + ppe) / 100)))), 0, 100)
      lyr.ImpedenceDeduction = lyr.ImpedenceModificationDeduction / 100 * lyr.ImpedenceClayDeduction
      
      # Determine the highest impedence value in or partially in the Subsurface, and its upper depth.
      if ( (lyr.udepth <= soil.SubsurfaceDepth) and (lyr.ldepth > soil.SurfaceDepth) and (lyr.ImpedenceDeduction > soil.SubsurfaceHighestImpedenceDeduction) ) then
        soil.SubsurfaceHighestImpedenceUpperDepth = lyr.udepth
        soil.SubsurfaceHighestImpedenceBD = lyr.bd
        soil.SubsurfaceHighestImpedenceClay = lyr.tclay
        soil.SubsurfaceHighestImpedenceClayDeduction = lyr.ImpedenceClayDeduction
        soil.SubsurfaceHighestImpedenceModificationDeduction = lyr.ImpedenceModificationDeduction
        soil.SubsurfaceHighestImpedenceDeduction = lyr.ImpedenceDeduction
      end
      # Similarly, now determine the highest impedence value in the entire profile and its upper depth.
      if (lyr.bd > soil.TotalHighestImpedence) then
        soil.TotalHighestImpedence = lyr.ImpedenceDeduction
        soil.TotalHighestImpedenceUpperDepth = lyr.udepth
      end
      lyrArray.push lyr
    end # layer
    #populate soil with layer values
    soil.layers = lyrArray
  end


	def MineralPrep.validate_values(soil)
    # check content of mineral data
    # Check and set %Si and %C values. If -9 (no value) then set to zero.  FIX THIS EARLIER - MAY FIND MISSING VALUES FOR ONLY A FEW LAYERS - WAS FIXED SO SHOULD BE SAFE TO REMOVE
    if (soil.SurfaceSi == -9) then soil.SurfaceSi = 0 end
    if (soil.SurfaceC == -9) then soil.SurfaceC = 0 end
    if (soil.SubsurfaceSi == -9) then soil.SubsurfaceSi = 0 end
    if (soil.SubsurfaceC == -9) then soil.SubsurfaceC = 0 end
    # Proxy the water table depth from the drainage class.
    soil.WaterTableDepth = -1
    if (soil.DrainageClass == 'VP') then soil.WaterTableDepth = 0 end
    if (soil.DrainageClass == 'P')  then soil.WaterTableDepth = 25 end
    if (soil.DrainageClass == 'PI') then soil.WaterTableDepth = 50 end
    if (soil.DrainageClass == 'I')  then soil.WaterTableDepth = 75 end
    if (soil.DrainageClass == 'MW') then soil.WaterTableDepth = 100 end
    if (soil.DrainageClass == 'W')  then soil.WaterTableDepth = 125 end
    if (soil.DrainageClass == '-')  then soil.WaterTableDepth = 100 end
    if (soil.DrainageClass == 'R')  then soil.WaterTableDepth = 150 end
    # "V", "VR", and "M" added for slc/NSDB.
    if (soil.DrainageClass == 'V')  then soil.WaterTableDepth = 0 end
    if (soil.DrainageClass == 'VR') then soil.WaterTableDepth = 150 end
    if (soil.DrainageClass == 'M')  then soil.WaterTableDepth = 100 end
    if (soil.WaterTableDepth < 0) then soil.WaterTableDepth = 100 end
    # Check and set Topsoil depth for correct range [ 0 to 20 ].
    if (soil.SurfaceDepthTopSoil < 0) then soil.SurfaceDepthTopSoil = soil.SurfaceDepth end
    if (soil.SurfaceDepthTopSoil > soil.SurfaceDepth) then soil.SurfaceDepthTopSoil = soil.SurfaceDepth end
    # Do extra checking for -9 values -- this means no value.
    if (soil.SurfaceReaction == -9) then soil.SurfaceReaction = 7 end
    if (soil.SurfaceSalinity == -9) then soil.SurfaceSalinity = 0 end
    # Proxy surface KP0 -- saturation % -- to SAR 
    if (soil.SurfaceKP0 == -9) then soil.SurfaceSodicity = 0 else
      soil.SurfaceSodicity = (-1.6517633e11 + 3.6390917e9 * soil.SurfaceKP0) / (1 + 2.454059e8 * soil.SurfaceKP0 + -509457.85 * soil.SurfaceKP0 ** 2)
    end
    # If the proxy calculations produce a negative number for surface sodicity we set it to 0. 
    if (soil.SurfaceSodicity < 0 ) then soil.SurfaceSodicity = 0 end
    # Check and set Subsurface Impeding Depth to correct range [ 20 - 100 ].
    #NOTE: Check for the Surface value after checking SubsurfaceDepth to properly catch layers with upperdepth less than 20.  Make sure that Highest Subsurface Impedence Value is set right.
    if (soil.SubsurfaceHighestImpedenceDeduction > -1) then
      soil.SubsurfaceImpedenceDepth = soil.SubsurfaceHighestImpedenceUpperDepth
    else
      soil.SubsurfaceImpedenceDepth = soil.SurfaceDepth
      soil.SubsurfaceHighestImpedenceDeduction = soil.TotalHighestImpedence
    end
    # Again do extra checking for -9 values -- this means no value.
    if (soil.SubsurfaceReaction == -9) then soil.SubsurfaceReaction = 7 end
    if (soil.SubsurfaceSalinity == -9) then soil.SubsurfaceSalinity = 0 end
    #Proxy subsurface KP0 - saturation % - to SAR
    if (soil.SubsurfaceKP0 == -9) then soil.SubsurfaceSodicity = 0 else
      soil.SubsurfaceSodicity = (-1.6517633e11 + 3.6390917e9 * soil.SubsurfaceKP0) / (1 + 2.454059e8 * soil.SubsurfaceKP0 + -509457.85 * soil.SubsurfaceKP0 ** 2)
    end
    # If the proxy calculations produce a negative number for subsurface sodicity we set it to 0.
    if (soil.SubsurfaceSodicity < 0 ) then soil.SubsurfaceSodicity = 0 end
	end

end