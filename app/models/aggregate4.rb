class Aggregate4
# functions to aggregate individual component ratings into a single rating for the polygon. 
# category = drainage, water, dominant, subdominant
# factor = climate, mineral/organic, landscape
# subfactor = A, H, W etc

  def Aggregate4.AddWater(lsrsArray)
    cmp = Lsrs_cmp_class.new
#    cmp.percent = area of water / area of land + area of water
  end
  
  def Aggregate4.Categorize(lsrsArray)
    # sort components into categories: NotRated, Drainage, Dominant and Dissimilar
    category = Lsrs_aggregate_class.new
    category.NotRated = Array.new
    category.Drainage = Array.new
    domplusArray = Array.new
    for cmp in lsrsArray do
      if cmp.SoilClass == "NotRated" then # step 1.1
        # Populate water bodies category by adding to existing percent
        category.NotRated.push cmp
      elsif cmp.DrainagePercentReduction > 60 then # step 1.2 - drainage component
        category.Drainage.push cmp
      else # dominant or dissimilar component
        domplusArray.push cmp
      end
    end
    # step 1.3 determine the dominant component characteristics
    domPercent = 0
    for cmp in domplusArray do
      if cmp.percent > domPercent then 
        domPercent = cmp.percent
        domSoilRating = cmp.FinalSoilRating
        domLandscapeRating = cmp.LandscapeFinalRating
        domSoilType = cmp.soil_id
      elsif cmp.percent == domPercent then # if there is more than one with the largest area then use highest soil rating
        if cmp.FinalSoilRating > domSoilRating then 
          domSoilRating = cmp.FinalSoilRating
          domLandscapeRating = cmp.LandscapeFinalRating
          domSoilType = cmp.soil_id
        elsif cmp.FinalSoilRating == domSoilRating then # if there is still a tie then use highest landscape rating
          #deal with landscape rating
          if cmp.LandscapeFinalRating > domLandscapeRating then
            domLandscapeRating = cmp.LandscapeFinalRating
            domSoilType = cmp.soil_id
          end
        end
      end
    end
    # step 1.4 populate the dominant similar and dissimilar categories
    category.Dominant = Array.new
    category.Dissimilar = Array.new
    for cmp in domplusArray
      if cmp.FinalSoilRating  >  domSoilRating - 15 and domLandscapeRating - 30  <  cmp.LandscapeFinalRating and  cmp.LandscapeFinalRating <  domLandscapeRating  + 30 then
        category.Dominant.push cmp
      else
        category.Dissimilar.push cmp
      end
    end
    return category
  end
  
  def Aggregate4.NotRated(notRatedArray)
    # Step 2.1: aggregate water component
    percent = 0
    for cmp in notRatedArray do
      percent = percent + cmp.percent
    end
    return percent
  end
  
  def Aggregate4.Soil(soilArray)
    # Step 3:  aggregate normal components
    factorHash = Hash.new
    factorHash['Percent'] = 0
    if soilArray != []
      soilRatingSum = landscapeRatingSum = 0
      for cmp in soilArray
        factorHash['Percent'] = factorHash['Percent'] + cmp.percent
        soilRatingSum = soilRatingSum + cmp.FinalSoilRating * cmp.percent
        landscapeRatingSum = landscapeRatingSum + cmp.LandscapeFinalRating * cmp.percent
      end
      factorHash['SoilRating'] = soilRatingSum  / factorHash['Percent']
      factorHash['LandscapeRating'] = landscapeRatingSum / factorHash['Percent']
    else
      factorHash['SoilRating'] = 0
      factorHash['LandscapeRating'] = 0
    end
    return factorHash
  end

  def Aggregate4.MostLimitingFactor(factorHash)
    # Step 4.1
    # assumes climate is more important than soil which is more important than landscape
    factorHash['MostLimitingFactor'] = "Climate"
    if factorHash['SoilRating'] < factorHash['ClimateRating'] then factorHash['MostLimitingFactor'] = "Soil" end
    if factorHash['LandscapeRating'] < factorHash['ClimateRating'] and factorHash['LandscapeRating'] < factorHash['SoilRating'] then factorHash['MostLimitingFactor'] = "Landscape" end
    factorHash['Class'] = Calculate.rating(factorHash[factorHash["MostLimitingFactor"] + "Rating"])
    return factorHash
  end
  
  def Aggregate4.SummarizeSubfactors(category, sumPercent)
    if sumPercent > 0 then
      # initialize summary values for this category
      subfactorHash = Hash.new
      subfactorHash.store('landscapeT', 0)
      subfactorHash.store('landscapeP', 0)
      subfactorHash.store('landscapeJ', 0)
      subfactorHash.store('landscapeK', 0)
      subfactorHash.store('landscapeI', 0)
      subfactorHash.store('organicM', 0)
      subfactorHash.store('organicZ', 0)
      subfactorHash.store('organicW', 0)
      subfactorHash.store('organicN', 0)
      subfactorHash.store('organicB', 0)
      subfactorHash.store('organicV', 0)
      subfactorHash.store('organicG', 0)
      subfactorHash.store('mineralM', 0)
      subfactorHash.store('mineralW', 0)
      subfactorHash.store('mineralD', 0)
      subfactorHash.store('mineralF', 0)
      subfactorHash.store('mineralE', 0)
      subfactorHash.store('mineralN', 0)
      subfactorHash.store('mineralV', 0)
      subfactorHash.store('mineralO', 0)
      subfactorHash.store('mineralY', 0)
      # assign summarized values to subfactorHash components
      for cmp in category do
        if cmp.LandscapeSlopeDeduction != nil then subfactorHash['landscapeT'] += cmp.LandscapeSlopeDeduction * cmp.percent end
        if cmp.LandscapeStoninessPercentReduction != nil then subfactorHash['landscapeP'] += cmp.LandscapeStoninessPercentReduction * cmp.percent end
        if cmp.LandscapeGravelPercentReduction != nil then subfactorHash['landscapeP'] += cmp.LandscapeGravelPercentReduction * cmp.percent end # add Gravel to Stoniness to create P summary
        if cmp.LandscapeWoodContentPercentReduction != nil then subfactorHash['landscapeJ'] += cmp.LandscapeWoodContentPercentReduction * cmp.percent end
        if cmp.LandscapePatternPercentReduction != nil then subfactorHash['landscapeK'] += cmp.LandscapePatternPercentReduction * cmp.percent end
        if cmp.LandscapeFloodingPercentReduction != nil then subfactorHash['landscapeI'] += cmp.LandscapeFloodingPercentReduction * cmp.percent end
        if cmp.MoistureDeficitDeduction != nil then subfactorHash['organicM'] += cmp.MoistureDeficitDeduction * cmp.percent end
        if cmp.TemperatureDeduction != nil then subfactorHash['organicZ'] += cmp.TemperatureDeduction * cmp.percent end
        if cmp.DrainagePercentReduction != nil then subfactorHash['organicW'] += cmp.DrainagePercentReduction * cmp.percent end
        maxDeduction= [cmp.SurfaceSalinityDeduction, cmp.SubsurfaceSalinityDeduction].compact.max
        if maxDeduction != nil then subfactorHash['organicN'] += maxDeduction * cmp.percent end
        maxDeduction= [cmp.SurfaceStructureDeduction,cmp.SubsurfaceStructureDeduction].compact.max
        if maxDeduction != nil then subfactorHash['organicB'] += maxDeduction * cmp.percent end
        maxDeduction = [cmp.SurfaceReactionDeduction,cmp.SubsurfaceReactionDeduction].compact.max
        if maxDeduction != nil then subfactorHash['organicV'] += maxDeduction * cmp.percent end
        if cmp.SubsurfaceSubstrateDeduction != nil then subfactorHash['organicG'] += cmp.SubsurfaceSubstrateDeduction * cmp.percent end
        if cmp.MoistureDeduction != nil then subfactorHash['mineralM'] += cmp.MoistureDeduction * cmp.percent end
        if cmp.DrainagePercentReduction != nil then subfactorHash['mineralW'] += cmp.DrainagePercentReduction * cmp.percent end
        maxDeduction = [cmp.SurfaceDeductionD,cmp.SubsurfaceImpedenceDeduction].compact.max
        if maxDeduction != nil then subfactorHash['mineralD'] += maxDeduction * cmp.percent end
        if cmp.SurfaceDeductionF != nil then subfactorHash['mineralF'] += cmp.SurfaceDeductionF * cmp.percent end
        if cmp.SurfaceDeductionE != nil then subfactorHash['mineralE'] += cmp.SurfaceDeductionE * cmp.percent end
        maxDeduction = [cmp.SurfaceSalinityDeduction,cmp.SubsurfaceSalinityDeductionInterim].compact.max
        if maxDeduction != nil then subfactorHash['mineralN'] += maxDeduction * cmp.percent end
        maxDeduction = [cmp.SurfaceReactionDeduction,cmp.SubsurfaceReactionDeduction].compact.max
        if maxDeduction != nil then subfactorHash['mineralV'] += maxDeduction * cmp.percent end
        if cmp.OrganicDeductionO != nil then subfactorHash['mineralO'] += cmp.OrganicDeductionO * cmp.percent end
        maxDeduction = [cmp.SurfaceSodicityDeduction,cmp.SubsurfaceSodicityDeduction].compact.max
        if maxDeduction != nil then subfactorHash['mineralY'] += maxDeduction * cmp.percent end
        
      end
      #reduce sum of percents to a weighted average
      subfactorHash['landscapeT'] = (subfactorHash['landscapeT'] / sumPercent).round
      subfactorHash['landscapeP'] = (subfactorHash['landscapeP'] / sumPercent).round
      subfactorHash['landscapeJ'] = (subfactorHash['landscapeJ'] / sumPercent).round
      subfactorHash['landscapeK'] = (subfactorHash['landscapeK'] / sumPercent).round
      subfactorHash['landscapeI'] = (subfactorHash['landscapeI'] / sumPercent).round
      subfactorHash['organicM'] = (subfactorHash['organicM'] / sumPercent).round
      subfactorHash['organicZ'] = (subfactorHash['organicZ'] / sumPercent).round
      subfactorHash['organicW'] = (subfactorHash['organicW'] / sumPercent).round
      subfactorHash['organicN'] = (subfactorHash['organicN'] / sumPercent).round
      subfactorHash['organicB'] = (subfactorHash['organicB'] / sumPercent).round
      subfactorHash['organicV'] = (subfactorHash['organicV'] / sumPercent).round
      subfactorHash['organicG'] = (subfactorHash['organicG'] / sumPercent).round
      subfactorHash['mineralM'] = (subfactorHash['mineralM'] / sumPercent).round
      subfactorHash['mineralW'] = (subfactorHash['mineralW'] / sumPercent).round
      subfactorHash['mineralD'] = (subfactorHash['mineralD'] / sumPercent).round
      subfactorHash['mineralF'] = (subfactorHash['mineralF'] / sumPercent).round
      subfactorHash['mineralE'] = (subfactorHash['mineralE'] / sumPercent).round
      subfactorHash['mineralN'] = (subfactorHash['mineralN'] / sumPercent).round
      subfactorHash['mineralV'] = (subfactorHash['mineralV'] / sumPercent).round
      subfactorHash['mineralO'] = (subfactorHash['mineralO'] / sumPercent).round
      subfactorHash['mineralY'] = (subfactorHash['mineralY'] / sumPercent).round
      # add ranking weights as fractions for sorting ties and drop zero values while renaming subfactors
      subfactorHash2 = Hash.new
      if subfactorHash['landscapeT'] > 0 then subfactorHash2['T'] = subfactorHash['landscapeT'] += 0.0550 end
      if subfactorHash['landscapeP'] > 0 then subfactorHash2['P'] = subfactorHash['landscapeP'] += 0.0435 end
      if subfactorHash['landscapeJ'] > 0 then subfactorHash2['J'] = subfactorHash['landscapeJ'] += 0.0425 end
      if subfactorHash['landscapeK'] > 0 then subfactorHash2['K'] = subfactorHash['landscapeK'] += 0.0422 end
      if subfactorHash['landscapeI'] > 0 then subfactorHash2['I'] = subfactorHash['landscapeI'] += 0.0415 end
      if subfactorHash['organicM'] > 0 then subfactorHash2['organicM'] = subfactorHash['organicM'] += 0.0709 else subfactorHash2['organicM'] = 0 end
      if subfactorHash['organicZ'] > 0 then subfactorHash2['Z'] = subfactorHash['organicZ'] += 0.0610 end
      if subfactorHash['organicW'] > 0 then subfactorHash2['organicW'] = subfactorHash['organicW'] += 0.0495 else subfactorHash2['organicW'] = 0 end
      if subfactorHash['organicN'] > 0 then subfactorHash2['organicN'] = subfactorHash['organicN'] += 0.0475 else subfactorHash2['organicN'] = 0 end
      if subfactorHash['organicB'] > 0 then subfactorHash2['B'] = subfactorHash['organicB'] += 0.0465 end
      if subfactorHash['organicV'] > 0 then subfactorHash2['organicV'] = subfactorHash['organicV'] += 0.0455 else subfactorHash2['organicV'] = 0 end
      if subfactorHash['organicG'] > 0 then subfactorHash2['G'] = subfactorHash['organicG'] += 0.0445 end
      if subfactorHash['mineralM'] > 0 then subfactorHash2['mineralM'] = subfactorHash['mineralM'] += 0.0710 else subfactorHash2['mineralM'] = 0 end
      if subfactorHash['mineralW'] > 0 then subfactorHash2['mineralW'] = subfactorHash['mineralW'] += 0.0496 else subfactorHash2['mineralW'] = 0 end
      if subfactorHash['mineralD'] > 0 then subfactorHash2['D'] = subfactorHash['mineralD'] += 0.0485 end
      if subfactorHash['mineralF'] > 0 then subfactorHash2['F'] = subfactorHash['mineralF'] += 0.0480 end
      if subfactorHash['mineralE'] > 0 then subfactorHash2['E'] = subfactorHash['mineralE'] += 0.0478 end
      if subfactorHash['mineralN'] > 0 then subfactorHash2['mineralN'] = subfactorHash['mineralN'] += 0.0476 else subfactorHash2['mineralN'] = 0 end
      if subfactorHash['mineralV'] > 0 then subfactorHash2['mineralV'] = subfactorHash['mineralV'] += 0.0456 else subfactorHash2['mineralV'] = 0 end
      if subfactorHash['mineralO'] > 0 then subfactorHash2['O'] = subfactorHash['mineralO'] += 0.0405 end
      if subfactorHash['mineralY'] > 0 then subfactorHash2['Y'] = subfactorHash['mineralY'] += 0.0400 end
      # remove duplicates and rename remaining subfactors
      subfactorHash2['M'] = [subfactorHash2['organicM'],subfactorHash2['mineralM']].max
      subfactorHash2.delete('organicM')
      subfactorHash2.delete('mineralM')
      if subfactorHash2['M'] == 0 then subfactorHash2.delete('M') end
      subfactorHash2['W'] = [subfactorHash2['organicW'],subfactorHash2['mineralW']].max
      subfactorHash2.delete('organicW')
      subfactorHash2.delete('mineralW')
      if subfactorHash2['W'] == 0 then subfactorHash2.delete('W') end
      subfactorHash2['N'] = [subfactorHash2['organicN'],subfactorHash2['mineralN']].max
      subfactorHash2.delete('organicN')
      subfactorHash2.delete('mineralN')
      if subfactorHash2['N'] == 0 then subfactorHash2.delete('N') end
      subfactorHash2['V'] = [subfactorHash2['organicV'],subfactorHash2['mineralV']].max
      subfactorHash2.delete('organicV')
      subfactorHash2.delete('mineralV')
      if subfactorHash2['V'] == 0 then subfactorHash2.delete('V') end
    else
      subfactorHash2 = Hash.new
    end
    return subfactorHash2
  end
  
  def Aggregate4.DropBelow20(subfactorHash)
    # delete subfactor values below 20
    if subfactorHash['A'] != nil and subfactorHash['A'] <= 20 then subfactorHash.delete('A') end
    if subfactorHash['H'] != nil and subfactorHash['H'] <= 20 then subfactorHash.delete('H') end
    if subfactorHash['T'] != nil and subfactorHash['T'] <= 20 then subfactorHash.delete('T') end
    if subfactorHash['P'] != nil and subfactorHash['P'] <= 20 then subfactorHash.delete('P') end
    if subfactorHash['J'] != nil and subfactorHash['J'] <= 20 then subfactorHash.delete('J') end
    if subfactorHash['K'] != nil and subfactorHash['K'] <= 20 then subfactorHash.delete('K') end
    if subfactorHash['I'] != nil and subfactorHash['I'] <= 20 then subfactorHash.delete('I') end
    if subfactorHash['M'] != nil and subfactorHash['M'] <= 20 then subfactorHash.delete('M') end
    if subfactorHash['Z'] != nil and subfactorHash['Z'] <= 20 then subfactorHash.delete('Z') end
    if subfactorHash['W'] != nil and subfactorHash['W'] <= 20 then subfactorHash.delete('W') end
    if subfactorHash['N'] != nil and subfactorHash['N'] <= 20 then subfactorHash.delete('N') end
    if subfactorHash['B'] != nil and subfactorHash['B'] <= 20 then subfactorHash.delete('B') end
    if subfactorHash['V'] != nil and subfactorHash['V'] <= 20 then subfactorHash.delete('V') end
    if subfactorHash['G'] != nil and subfactorHash['G'] <= 20 then subfactorHash.delete('G') end
    if subfactorHash['D'] != nil and subfactorHash['D'] <= 20 then subfactorHash.delete('D') end
    if subfactorHash['F'] != nil and subfactorHash['F'] <= 20 then subfactorHash.delete('F') end
    if subfactorHash['E'] != nil and subfactorHash['E'] <= 20 then subfactorHash.delete('E') end
    if subfactorHash['O'] != nil and subfactorHash['O'] <= 20 then subfactorHash.delete('O') end
    if subfactorHash['Y'] != nil and subfactorHash['Y'] <= 20 then subfactorHash.delete('Y') end
    return subfactorHash
  end
  
  def Aggregate4.DropAH(subfactorHash, rating)
    # Step 5.2 drop A and H if climate is not the most limiting factor
    if rating['MostLimitingFactor'] != "Climate" then
      subfactorHash.delete('A')
      subfactorHash.delete('H')
    end
    return subfactorHash
  end

  def Aggregate4.DropAM(subfactorHash)
    # Step 5.3  drop A or M if both are present
    if (subfactorHash['A'] != nil) and (subfactorHash['M'] != nil) then
      if subfactorHash['M'] >= subfactorHash['A'] + 5 then 
        subfactorHash.delete('A')
      else
        subfactorHash.delete('M')
      end
    end
    return subfactorHash
  end
  
  def Aggregate4.DeleteSubfactors(subfactorHash, allSubfactorKeys)
    # part of Step 5.4.1
    keysArray = allSubfactorKeys & subfactorHash.keys
    if keysArray.size > 1 then
      valuesArray = Array.new
      keysArray.each { |key| valuesArray.push subfactorHash[key]}
      threshold = valuesArray.max * 0.4
      for key in keysArray do
        if subfactorHash[key] < threshold then subfactorHash.delete(key) end
      end
    end
    return subfactorHash
  end    
    
  def Aggregate4.DropWithinFactor(subfactorHash)
    # Step 5.4.1  within factor comparison
    if subfactorHash != {} then
      # Climate Factor
      subfactorHash = Aggregate4.DeleteSubfactors(subfactorHash, ['A','H'])
      # Landscape Factor
      subfactorHash = Aggregate4.DeleteSubfactors(subfactorHash, ['T','P','J','K','I'])
      # Soil Factor
      subfactorHash = Aggregate4.DeleteSubfactors(subfactorHash, ['M','Z','W','N','B','V','G','D','F','E','O','Y'])
    end
    return subfactorHash
  end
  
  def Aggregate4.DropWithinFactorOLD(subfactorHash)
    # Step 5.4.1  within factor comparison
    if subfactorHash != {} then
      # Climate Factor
      threshold = [subfactorHash['A'],subfactorHash['H']].max * 0.4
      if subfactorHash['A'] < threshold then subfactorHash.delete('A') end
      if subfactorHash['H'] < threshold then subfactorHash.delete('H') end
      # Landscape Factor
      threshold = [subfactorHash["T"],subfactorHash["P"],subfactorHash["J"],subfactorHash["K"],subfactorHash["I"]].max * 0.4
      if subfactorHash['T'] < threshold then subfactorHash.delete('T') end
      if subfactorHash['P'] < threshold then subfactorHash.delete('P') end
      if subfactorHash['J'] < threshold then subfactorHash.delete('J') end
      if subfactorHash['K'] < threshold then subfactorHash.delete('K') end
      if subfactorHash['I'] < threshold then subfactorHash.delete('I') end
      # Soil Factor
      threshold = [subfactorHash['M'],subfactorHash['Z'],subfactorHash['W'],subfactorHash['N'],subfactorHash['B'],subfactorHash['V'],subfactorHash['G'],subfactorHash['D'],subfactorHash['F'],subfactorHash['E'],subfactorHash['O'],subfactorHash['Y']].max * 0.4
      if subfactorHash['M'] < threshold then subfactorHash.delete('M') end
      if subfactorHash['Z'] < threshold then subfactorHash.delete('Z') end
      if subfactorHash['W'] < threshold then subfactorHash.delete('W') end
      if subfactorHash['N'] < threshold then subfactorHash.delete('N') end
      if subfactorHash['B'] < threshold then subfactorHash.delete('B') end
      if subfactorHash['V'] < threshold then subfactorHash.delete('V') end
      if subfactorHash['G'] < threshold then subfactorHash.delete('G') end
      if subfactorHash['D'] < threshold then subfactorHash.delete('D') end
      if subfactorHash['F'] < threshold then subfactorHash.delete('F') end
      if subfactorHash['E'] < threshold then subfactorHash.delete('E') end
      if subfactorHash['O'] < threshold then subfactorHash.delete('O') end
      if subfactorHash['Y'] < threshold then subfactorHash.delete('Y') end
    end
    return subfactorHash
  end

  def Aggregate4.DropOtherFactors(subfactorHash, category)
    # Step 5.4.2  between factor comparison
#    threshold = 100 - (100 - category[category['MostLimitingFactor'] + "Rating"]) * 0.33
    threshold = category[category['MostLimitingFactor'] + "Rating"] * 0.33
    if category['ClimateRating'] < threshold then
      subfactorHash.delete('A')
      subfactorHash.delete('H')
    end
    if category['LandscapeRating'] < threshold then
      subfactorHash.delete('T')
      subfactorHash.delete('P')
      subfactorHash.delete('J')
      subfactorHash.delete('K')
      subfactorHash.delete('I')
    end
    if category['SoilRating'] < threshold then
      subfactorHash.delete('M')
      subfactorHash.delete('Z')
      subfactorHash.delete('W')
      subfactorHash.delete('N')
      subfactorHash.delete('B')
      subfactorHash.delete('V')
      subfactorHash.delete('G')
      subfactorHash.delete('D')
      subfactorHash.delete('F')
      subfactorHash.delete('E')
      subfactorHash.delete('O')
      subfactorHash.delete('Y')
    end
    return subfactorHash
  end
 
  def Aggregate4.PrimarySubclass(subfactorHash, category)
    # Step 5.5 determine primary subclass
    factorSummary = Hash.new
    if category['MostLimitingFactor'] == 'Climate' then
      if subfactorHash['A'] != nil then factorSummary.store('A', subfactorHash['A']) end
      if subfactorHash['H'] != nil then factorSummary.store('H', subfactorHash['H']) end
    end
    if category['MostLimitingFactor'] == 'Landscape' then
      if subfactorHash['T'] != nil then factorSummary.store('T', subfactorHash['T']) end
      if subfactorHash['P'] != nil then factorSummary.store('P', subfactorHash['P']) end
      if subfactorHash['J'] != nil then factorSummary.store('J', subfactorHash['J']) end
      if subfactorHash['K'] != nil then factorSummary.store('K', subfactorHash['K']) end
      if subfactorHash['I'] != nil then factorSummary.store('I', subfactorHash['I']) end
    end
    if category['MostLimitingFactor'] == 'Soil' then
      if subfactorHash['M'] != nil then factorSummary.store('M', subfactorHash['M']) end
      if subfactorHash['Z'] != nil then factorSummary.store('Z', subfactorHash['Z']) end
      if subfactorHash['W'] != nil then factorSummary.store('W', subfactorHash['W']) end
      if subfactorHash['N'] != nil then factorSummary.store('N', subfactorHash['N']) end
      if subfactorHash['B'] != nil then factorSummary.store('B', subfactorHash['B']) end
      if subfactorHash['V'] != nil then factorSummary.store('V', subfactorHash['V']) end
      if subfactorHash['G'] != nil then factorSummary.store('G', subfactorHash['G']) end
      if subfactorHash['D'] != nil then factorSummary.store('D', subfactorHash['D']) end
      if subfactorHash['F'] != nil then factorSummary.store('F', subfactorHash['F']) end
      if subfactorHash['E'] != nil then factorSummary.store('E', subfactorHash['E']) end
      if subfactorHash['O'] != nil then factorSummary.store('O', subfactorHash['O']) end
      if subfactorHash['Y'] != nil then factorSummary.store('Y', subfactorHash['Y']) end
    end
    if factorSummary != {} then
      primarySubfactor = factorSummary.sort { |l, r| l[1]<=>r[1] }[-1][0] 
    else
      primarySubfactor = nil
    end
    category.store('PrimarySubfactor', primarySubfactor)
    return category
  end

  def Aggregate4.AdditionalSubclasses(subfactorHash, factorHash)
    # Step 5.5b determine additional subclasses
    if subfactorHash != {} then
      summary2 = subfactorHash
      summary2.delete(factorHash['PrimarySubfactor'])
      if summary2 != {} then
        remainingSubfactorArray = summary2.sort { |l, r| l[1]<=>r[1] }
        else
        remainingSubfactorArray = []
      end
    else
      remainingSubfactorArray = []
    end
    factorHash.store('remainingSubfactorArray', remainingSubfactorArray)
    return factorHash
  end
  
  def Aggregate4.FinalClass(subfactorHash, factorHash)
    # Step 6 Final class and subclasses
    if factorHash['Percent'] != 0 then
      subfactors =  factorHash['PrimarySubfactor']
      if subfactors == nil then subfactors = "" end
      for subfactor in factorHash['remainingSubfactorArray']
        subfactors = subfactors + subfactor[0]
      end
    else
    end
    if subfactors == nil then subfactors = "" end
    factorHash.store('Subfactors', subfactors[0..2])
    return factorHash
  end

  def Aggregate4.rating(drainageFactorHash,dominantFactorHash,dissimilarFactorHash,perdecimNotRated)
    # create a new set of arrays for processing
    factorArray = [drainageFactorHash,dominantFactorHash,dissimilarFactorHash]
    # get rid of zero perdecim 
    factorArray.delete_if{|x| x["PerDecim"]==0}
    #add combined class rating to each hash
    factorArray.map {|x| x['Rating'] = x['Class'].to_s + x['Subfactors']}
    # combine categories where class and subclass are identical
    completeRatingArray = factorArray.map {|x| x['Rating']}
    if completeRatingArray.uniq.size < completeRatingArray.size 
    uniqueRatingArray = completeRatingArray.uniq.map { |x| {:rating => x, :perdecim=> 0, :order=> 0} }
    factorArray.each do |rating|
    uniqueRatingArray.each do |x|
    if x[:rating] == rating["Rating"] then x[:perdecim] += rating["PerDecim"] end
    end
    end
    else
    uniqueRatingArray = factorArray.map { |x| {:rating => x["Rating"], :perdecim=> x["PerDecim"], :order=> 0} }
    end
    # present the highest percent first
    # if subclass the same and percent the same, present the best class first
    # if class and proportion are the same, present the fewest subclasses first
    # if class and proportion and number of subclasses are the same, present in alphabetical order
    uniqueRatingArray.each {|e| e[:order] = (10 - e[:perdecim]).to_s + e[:rating][0,1] + e[:rating].size.to_s + e[:rating]}
    uniqueRatingArray.sort! {|hash_a,hash_b| hash_a[:order] <=> hash_b[:order]}
    # concatenate ratings
    lsrsRating = String.new
    for rating in uniqueRatingArray do
      lsrsRating += rating[:rating] + "(" + rating[:perdecim].to_s + ") - "
    end
    3.times {lsrsRating.chop!} # get rid of trailing dash
    # present waterbody first if it is highest percentage, otherwise present last
    if perdecimNotRated > 0 then
      if perdecimNotRated == 10 then
        lsrsRating = "NR(10)"
      else
        if perdecimNotRated > uniqueRatingArray[0][:perdecim] then
          lsrsRating = "NR(" + perdecimNotRated.to_s + ") - " + lsrsRating
        else
          lsrsRating = lsrsRating + " - NR(" + perdecimNotRated.to_s + ")"
        end
      end
    end
    return lsrsRating
  end

end

