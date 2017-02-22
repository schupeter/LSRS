class OrganicPrep

  def OrganicPrep.inputs(soil)
    # SNF/SLF records retrieved.  Calculate rating inputs.
    # Proxy the water table depth from the drainage class.
    soil.WaterTableDepth = -1
    if soil.name.drainage == "VP" then soil.WaterTableDepth = 0 end
    if soil.name.drainage == "P"  then soil.WaterTableDepth = 25 end
    if soil.name.drainage == "PI" then soil.WaterTableDepth = 50 end # not used in NSDB
    if soil.name.drainage == "I"  then soil.WaterTableDepth = 75 end
    if soil.name.drainage == "MW" then soil.WaterTableDepth = 100 end
    if soil.name.drainage == "W"  then soil.WaterTableDepth = 125 end
    if soil.name.drainage == "-"  then	soil.WaterTableDepth = 25 end    # Use 25 instead of 100 as in Mineral Component.
    if soil.name.drainage == "R"  then soil.WaterTableDepth = 150 end  
    if soil.name.drainage == "V"  then soil.WaterTableDepth = 0 end       # "V", "VR", and "M" added for slc/NSDB.
    if soil.name.drainage == "VR" then soil.WaterTableDepth = 150 end 
    if soil.name.drainage == "M"  then soil.WaterTableDepth = 100 end 
    if soil.WaterTableDepth < 0 then soil.WaterTableDepth = 25 end # Again, use 25 here instead of 100 as in Mineral.
    soil.order = soil.name.order3
  end 

  def OrganicPrep.generalize_layers(soil)
    # Horizon Processing if ORGANIC component.
    # initialize values for horizon processing
    soil.OrganicDepth = 0
    soil.SurfaceCF = 0
    soil.SurfaceDepth = 40
    soil.SurfaceBD = 0.0
    soil.SurfaceFibre = 0
    soil.SurfaceReaction = 0.0
    soil.SurfaceSalinity = 0.0
    soil.SurfaceWood = 0
    soil.SubsurfaceDepth = 120
    soil.SubsurfaceBD = 0.0
    soil.SubsurfaceFibre = 0
    soil.SubsurfaceReaction = 0.0
    soil.SubsurfaceSalinity = 0.0
#    soil.SubsurfaceTexture = 0
    soil.SubsurfaceWood = 0
    soil.SubSubsurfaceExists = false
    soil.SubSubsurfaceTsilt = 0
    soil.SubSubsurfaceTclay = 0
    soil.SubSubsurfaceCofrag = 0  
    # start processing horizons
    lyrArray = Array.new
    for layer in soil.layers do
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
      if (lyr.hznmasClass == "O" and soil.SubSubsurfaceExists == false) then soil.OrganicDepth = layer.ldepth end
    	if (lyr.hznmasClass == ("R" or "CO") and soil.SubSubsurfaceExists == false) then
        soil.SubSubsurfaceExists = true
        soil.SubSubsurfaceUpperDepth = layer.udepth
        soil.SubSubsurfaceLowerDepth = layer.ldepth
        soil.SubSubsurfaceHZNMAS = lyr.hznmasClass
      end
      if (lyr.hznmasClass == ("A" or "C") and soil.SubSubsurfaceExists == false) then
        soil.SubSubsurfaceExists = true
        soil.SubSubsurfaceUpperDepth = layer.udepth
        soil.SubSubsurfaceLowerDepth = layer.ldepth
        soil.SubSubsurfaceHZNMAS = lyr.hznmasClass
        soil.SubSubsurfaceTsilt = layer.tsilt
        soil.SubSubsurfaceTclay = layer.tclay
        soil.SubSubsurfaceCofrag = layer.cofrag
      end
      # add calculated layer to array of layers
      lyrArray.push lyr
    end # for layer
    # Now let's adjust depth numbers.
    if soil.OrganicDepth < soil.SubsurfaceDepth then soil.SubsurfaceDepth = soil.OrganicDepth end
    if soil.SubsurfaceDepth > 120 then soil.SubsurfaceDepth = 120 end
    if soil.SurfaceDepth > soil.SubsurfaceDepth then soil.SurfaceDepth = soil.SubsurfaceDepth end
    # Now continue processing for each horizon
    soil.layers.each_with_index do | layer, i |
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
      if lyrArray[i].udepth < soil.SurfaceDepth then
        lyrArray[i].SurfaceFactor = ( [soil.SurfaceDepth, lyrArray[i].ldepth].min - lyrArray[i].udepth ) / soil.SurfaceDepth.to_f
      end
      # calc subsurfaceFactor
      if lyrArray[i].ldepth > soil.SurfaceDepth then
        lyrArray[i].SubsurfaceFactor = ( [soil.SubsurfaceDepth, lyrArray[i].ldepth].min - [soil.SurfaceDepth, lyrArray[i].udepth].max ) / ( soil.SubsurfaceDepth - soil.SurfaceDepth ).to_f
        if lyrArray[i].SubsurfaceFactor.nan? then lyrArray[i].SubsurfaceFactor = 0.0 end # fix bug 19
        if lyrArray[i].SubsurfaceFactor.infinite? then lyrArray[i].SubsurfaceFactor = 0.0 end # fix bug 19
        if lyrArray[i].SubsurfaceFactor < 0 then lyrArray[i].SubsurfaceFactor = 0.0 end # fix bug Feb 13, 2012
      end
      # First -- Surface variables
      soil.SurfaceBD = soil.SurfaceBD + layer.bd * lyrArray[i].SurfaceFactor;
      soil.SurfaceFibre = soil.SurfaceFibre + lyrArray[i].fibre * lyrArray[i].SurfaceFactor
      # Surface Reaction
      soil.SurfaceReaction = soil.SurfaceReaction + layer.ph2 * lyrArray[i].SurfaceFactor
      # Surface Salinity
      if layer.ec == -9 then organic_SurfaceSalinityEC_Value = 0.1 else organic_SurfaceSalinityEC_Value = layer.ec end
      soil.SurfaceSalinity = soil.SurfaceSalinity + organic_SurfaceSalinityEC_Value * lyrArray[i].SurfaceFactor
      # Subsurface BD
      soil.SubsurfaceBD = soil.SubsurfaceBD + layer.bd * lyrArray[i].SubsurfaceFactor
      # Subsurface Fibre
      soil.SubsurfaceFibre = soil.SubsurfaceFibre + lyrArray[i].fibre * lyrArray[i].SubsurfaceFactor
      # Subsurface Reaction
      if layer.ph2 != -9 then soil.SubsurfaceReaction = soil.SubsurfaceReaction + layer.ph2 * lyrArray[i].SubsurfaceFactor end  # added condition Jan 26 2010 to fix missing values for rock
      # Subsurface Salinity
      if layer.ec == -9 then organic_SubsurfaceSalinityEC_Value = 0.1 else organic_SubsurfaceSalinityEC_Value = layer.ec end
      soil.SubsurfaceSalinity = soil.SubsurfaceSalinity + organic_SubsurfaceSalinityEC_Value * lyrArray[i].SubsurfaceFactor
      # Surface and Subsurface Wood
      if layer.wood == -9 then woodValue = 0 else woodValue = layer.wood end 
      soil.SurfaceWood = soil.SurfaceWood + woodValue * lyrArray[i].SurfaceFactor
      soil.SubsurfaceWood = soil.SubsurfaceWood + woodValue * lyrArray[i].SubsurfaceFactor
    end # layerRecords.each
    #populate cmp with layers
    soil.layers = lyrArray
    # Set defaults for Subsubsurface
    if soil.SubSubsurfaceExists == false then 
      soil.SubSubsurfaceHZNMAS = "-"
      soil.SubSubsurfaceTsilt = 0
      soil.SubSubsurfaceTclay = 0
      soil.SubSubsurfaceCofrag = 0
    end
  end

end
