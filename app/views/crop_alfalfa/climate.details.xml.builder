# return results 
xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone=>"no"
if @response == "Details" then xml.instruct! :'xml-stylesheet', :type=>"text/xsl", :href=>"/schemas/lsrs/1.0/stylesheets/lsrsDetails.xsl" 
elsif @response == "Summary" then xml.instruct! :'xml-stylesheet', :type=>"text/xsl", :href=>"/schemas/lsrs/1.0/stylesheets/lsrsSummary.xsl" 
end
xml.LSRS do
  xml.Request do
    xml.FrameworkName(@frameworkName)
    xml.Database(@databaseTitle)
    xml.Polygon(@polyId)
    xml.Crop(@crop)
    xml.Climate(@climateTitle)
    xml.ClimateTable(@climateTableName)
		xml.Management(@management)
  end
  xml.NameTable("@cmpTableMetadata.NameTable")
  xml.LayerTable("@cmpTableMetadata.LayerTable")
  # climate
  xml.Climate do
    xml.Sl(@sl)
    if @response == "Debug" then
      xml.Coefficients do
        xml.Moisture do
          xml.Coeff_Aa(@climateCoeff.Aa)
          xml.Coeff_Ab(@climateCoeff.Ab)
        end
        xml.Temperature do
          xml.Uses(@climateCoeff.HF)
          xml.Coeff_Ha(@climateCoeff.Ha)
          xml.Coeff_Hb(@climateCoeff.Hb)
          xml.Coeff_Hc(@climateCoeff.Hc)
          xml.Coeff_Hd(@climateCoeff.Hd)
          xml.GDD do
            xml.Coeff_HF1a(@climateCoeff.HF1a)
            xml.Coeff_HF1b(@climateCoeff.HF1b)
            xml.Coeff_HF1c(@climateCoeff.HF1c)
          end
          xml.GSL do
            xml.Coeff_HF2a(@climateCoeff.HF2a)
            xml.Coeff_HF2b(@climateCoeff.HF2b)
            xml.Coeff_HF2c(@climateCoeff.HF2c)
          end
        end
        xml.Modifiers do
          xml.ESM do
            xml.Coeff_M1a(@climateCoeff.M1a)
            xml.Coeff_M1b(@climateCoeff.M1b)
          end
          xml.EFM do
            xml.Coeff_M2a(@climateCoeff.M2a)
            xml.Coeff_M2b(@climateCoeff.M2b)
          end
          xml.EFF do
            xml.Coeff_M3a(@climateCoeff.M3a)
            xml.Coeff_M3b(@climateCoeff.M3b)
          end
          xml.RHI do
            xml.Coeff_M4a(@climateCoeff.M4a)
            xml.Coeff_M4b(@climateCoeff.M4b)
          end
        end
      end
    end
    xml.Moisture do
      xml.PPE(@soil[:climate][:ppe])
      xml.DeductionRaw("@climate.A_deduct_raw")
      xml.DeductionUsed(@soil[:climate_rating][:A_deduct])
      xml.Value(@soil[:climate_rating][:A])
    end
    xml.Temperature do
      xml.HF do
=begin
        if @climateCoeff.HF == "CHU" then
          xml.CHU do
            xml.CHU(@climatePoly.chu)
            xml.DeductionRaw(@climate.H_deduct_raw)
            xml.DeductionUsed(@climate.H_deduct)
          end
        end
        if @climateCoeff.HF == "EGDD" then
					xml.EGDD do
						xml.EGDD(@climatePoly.egdd)
						xml.DeductionRaw(@climate.H_deduct_raw)
						xml.DeductionUsed(@climate.H_deduct)
					end
        end
        if @climateCoeff.HF == "GDD" then
=end
          xml.GDD do
            xml.HF1 do
              xml.GDD(@climatePoly.gdd)
              xml.DeductionRaw(@climate.HF1_raw)
              xml.DeductionUsed(@climate.HF1)
            end
            xml.HF2 do
              xml.GSL(@climatePoly.gsl)
              xml.DeductionRaw(@climate.HF2_raw)
              xml.DeductionUsed(@climate.HF2)
            end
          end
          xml.Value(@climate.H_deduct)
        end
      end
      xml.Value(@climate.H)
    end
    xml.BasicRating do
      xml.Value(@climate.B)
    end
    xml.Modifiers do
      xml.M1 do
        xml.ESM(@climatePoly.esm)
        xml.ValueRaw(@climate.M1_raw)
        xml.Value(@climate.M1)
      end
      xml.M2 do
        xml.EFM(@climatePoly.efm)
        xml.ValueRaw(@climate.M2_raw)
        xml.Value(@climate.M2)
      end
      xml.M3 do
        xml.EFF(@climatePoly.eff)
        xml.ValueRaw(@climate.M3_raw)
        xml.Value(@climate.M3)
      end
      xml.M4 do
        xml.RHI(@climatePoly.rhi)
        xml.ValueRaw(@climate.M4_raw)
        xml.Value(@climate.M4)
      end
      xml.SumM(@climate.SumM)
      xml.Value(@climate.M)
    end
    xml.Ba do
      xml.Apply(@climateCoeff.Ba)
      xml.CANHM(@climatePoly.canhm)
      xml.Percent(@climate.Ba_adjustment_percent)
      xml.Value(@climate.Ba)
    end
    xml.Value(@climate.Value)
    xml.Rating(@climate.Rating)
  end
  # SoilLandscape
  xml.SoilLandscape do
    xml.ErosivityRegion(@landscapePoly.ErosivityRegion)
    for cmp in @lsrsArray do
      xml.Cmp do
        xml.Number(cmp.cmp)
        xml.Percent(cmp.percent)
        xml.SoilName(cmp.SoilName)
        xml.Modifier(cmp.Modifier)
        xml.Profile(cmp.Profile)
        xml.Kind(cmp.Kind)
        xml.WaterTable(cmp.WaterTable)
        xml.RootRestrictingLayer(cmp.RootRestrictingLayer)
        xml.RestrictionType(cmp.RestrictionType)
        xml.Drainage(cmp.Drainage)
        xml.PMtex1(cmp.PMtex1)
        xml.PMtex2(cmp.PMtex2)
        xml.PMtex3(cmp.PMtex3)
        xml.PMchem1(cmp.PMchem1)
        xml.PMchem2(cmp.PMchem2)
        xml.PMchem3(cmp.PMchem3)
        xml.Mdep1(cmp.Mdep1)
        xml.Mdep2(cmp.Mdep2)
        xml.Mdep3(cmp.Mdep3)
        xml.Order3(cmp.Order3)
        xml.SubGroup3(cmp.SubGroup3)
        xml.GreatGroup3(cmp.GreatGroup3)
        xml.Soil_id(cmp.soil_id)
        xml.SlopeClass(cmp.slopeClass)
        xml.Slp50(cmp.slp50)
        xml.Locsf(cmp.locsf)
        xml.SlopeLength(cmp.slopeLength)
        xml.StoninessClass(cmp.stoninessClass)
        xml.StoninessValue(cmp.stoninessValue)
        xml.SNFrecords(cmp.nameData)
        xml.SLFrecords(cmp.layerData)
        xml.Order(cmp.order)
        xml.DrainageClass(cmp.DrainageClass)
        xml.WaterTableDepth(cmp.WaterTableDepth)
        xml.DepthTopSoil(cmp.SurfaceDepthTopSoil)
        xml.BD(cmp.bd)
        xml.TotalHighestImpedence(cmp.TotalHighestImpedence)
        xml.TotalHighestImpedenceUpperDepth(cmp.TotalHighestImpedenceUpperDepth)
        xml.OrganicDepth(cmp.OrganicDepth)
        xml.SubstrateMasterHorizon(cmp.SubSubsurfaceHZNMAS)
        xml.SubstrateCoarseFragments(cmp.SubSubsurfaceCofrag)
        xml.SubstrateSilt(cmp.SubSubsurfaceTsilt)
        xml.SubstrateClay(cmp.SubSubsurfaceTclay)
				if @management == "improved" then
				xml.Managements do
					if cmp.ManagedWaterTableDepth then xml.WaterTableDepth(cmp.ManagedWaterTableDepth) end
					xml.Reaction(cmp.ManagedReaction)
				end
				end
        xml.LSRS_Layers do
          xml.Organic do
            xml.Depth(cmp.OrganicDepth)
            xml.BD(cmp.OrganicBD)
          end
          xml.Surface do
            xml.Depth(cmp.SurfaceDepth)
            xml.Si(cmp.SurfaceSi)
            xml.C(cmp.SurfaceC)
            xml.CF(cmp.SurfaceCF)
            xml.OC(cmp.SurfaceOC)
            xml.Reaction(cmp.SurfaceReaction)
            xml.Salinity(cmp.SurfaceSalinity)
            xml.Sodicity(cmp.SurfaceSodicity)
            xml.KP0(cmp.SurfaceKP0)
            xml.Fibre(cmp.SurfaceFibre)
            xml.Wood(cmp.SurfaceWood)
          end
          xml.Subsurface do
            xml.Depth(cmp.SubsurfaceDepth)
            xml.Si(cmp.SubsurfaceSi)
            xml.C(cmp.SubsurfaceC)
            xml.CF(cmp.SubsurfaceCF)
            xml.Reaction(cmp.SubsurfaceReaction)
            xml.Salinity(cmp.SubsurfaceSalinity)
            xml.Sodicity(cmp.SubsurfaceSodicity)
            xml.KP0(cmp.SubsurfaceKP0)
            xml.HighestImpedence(cmp.SubsurfaceHighestImpedenceDeduction)
            xml.HighestImpedenceUpperDepth(cmp.SubsurfaceHighestImpedenceUpperDepth)
            xml.ImpedingDepth(cmp.SubsurfaceImpedenceDepth)
            xml.Fibre(cmp.SubsurfaceFibre)
            xml.Wood(cmp.SubsurfaceWood)
          end
        end
        if cmp.layerData == true then 
          xml.SLF_Layers do
            for lyr in cmp.layers do
              xml.Layer do
                xml.UpperDepth(lyr.udepth)
                xml.LowerDepth(lyr.ldepth)
                xml.OrganicFactor(lyr.OrganicFactor)
                xml.SurfaceFactor(lyr.SurfaceFactor)
                xml.SubSurfaceFactor(lyr.SubsurfaceFactor)
                xml.hznmas(lyr.hznmas)
                xml.bd(lyr.bd)
                xml.cofrag(lyr.cofrag)
                xml.tsilt(lyr.tsilt)
                xml.tclay(lyr.tclay)
                xml.orgcarb(lyr.orgcarb)
                xml.ph2(lyr.ph2)
                xml.ec(lyr.ec)
                xml.kp0(lyr.kp0)
              end # Layer
            end # for lyr
          end #if cmp.layerData
        end # SLF_Layers
        if cmp.order == "OR" then
          xml.OrganicSoil do
            xml.Coefficients do
              xml.Coeff_Za(@organicCoeff.Za)
              xml.Coeff_Zb(@organicCoeff.Zb)
            end
            xml.SoilClimate do
              xml.TemperatureDeduction(cmp.TemperatureDeduction)
              xml.OrganicBaseRating(cmp.OrganicBaseRating)
            end
            xml.MoistureFactor do
              xml.WaterCapacityDeduction(cmp.WaterCapacityDeduction)
              xml.WaterTableAdjustment(cmp.WaterTableAdjustment)
              xml.MoistureDeficitDeduction(cmp.MoistureDeficitDeduction)
              xml.InterimRating(cmp.InterimRating)
            end
            xml.SurfaceFactors do
              xml.StructureDeduction(cmp.SurfaceStructureDeduction)
              xml.ReactionDeduction(cmp.SurfaceReactionDeduction)
              xml.SalinityDeduction(cmp.SurfaceSalinityDeduction)
              xml.MostLimitingDeduction(cmp.SurfaceMostLimitingDeduction)
              xml.TotalDeductions(cmp.SurfaceTotalDeductions)
              xml.FinalDeduction(cmp.SurfaceFinalDeduction)
              xml.BasicOrganicRating(cmp.BasicOrganicRating)
            end
            xml.SubsurfaceFactors do
              xml.StructureDeduction(cmp.SubsurfaceStructureDeduction)
              xml.SubstrateDeduction(cmp.SubsurfaceSubstrateDeduction)
              xml.ReactionDeduction(cmp.SubsurfaceReactionDeduction)
              xml.SalinityDeduction(cmp.SubsurfaceSalinityDeduction)
              xml.MostLimitingDeduction(cmp.SubsurfaceMostLimitingDeduction)
              xml.TotalDeductions(cmp.SubsurfaceTotalDeductions)
              xml.FinalDeduction(cmp.SubsurfaceFinalDeduction)
              xml.InterimFinalRating(cmp.InterimFinalRating)
            end
            xml.DrainageFactor do
              xml.PercentDeduction(cmp.DrainagePercentDeduction)
              xml.Deduction(cmp.DrainageDeduction)
            end
            xml.Rating(cmp.FinalSoilRating)
            xml.Class(cmp.SoilClass)
          end # Organic soil
        else
          xml.MineralSoil do
            xml.Coefficients do
              xml.Coeff_SurDa(@mineralCoeff.SurDa)
              xml.Coeff_SurDb(@mineralCoeff.SurDb)
              xml.Coeff_SurDc(@mineralCoeff.SurDc)
              xml.Coeff_SurV0a(@mineralCoeff.SurV0a)
              xml.Coeff_SurV1a(@mineralCoeff.SurV1a)
              xml.Coeff_SurV1b(@mineralCoeff.SurV1b)
              xml.Coeff_SurV1c(@mineralCoeff.SurV1c)
              xml.Coeff_SurVpLHlimit(@mineralCoeff.SubVpHlimit)
              xml.Coeff_SurVa(@mineralCoeff.SubVa)
              xml.Coeff_SurVb(@mineralCoeff.SubVb) 
              xml.Coeff_SurVc(@mineralCoeff.SubVc) 
              xml.Coeff_SurVd(@mineralCoeff.SubVd)
            end
            xml.MoistureFactor do
              xml.Surface do
                xml.Si(cmp.SurfaceSi)
                xml.C(cmp.SurfaceC)
                xml.CF(cmp.SurfaceCF)
                xml.STP(cmp.SurfaceSTP)
                xml.AWHCdeduction1(cmp.SurfaceAWHCdeduction1)
                xml.AWHCdeduction2(cmp.SurfaceAWHCdeduction2)
                xml.AWHCdedn1and2(cmp.SurfaceAWHCdedn1and2)
                xml.AWHCdeduction(cmp.SurfaceAWHCdeduction)
              end
              xml.Subsurface do
                xml.Si(cmp.SubsurfaceSi)
                xml.C(cmp.SubsurfaceC)
                xml.CF(cmp.SubsurfaceCF)
                xml.STP(cmp.SubsurfaceSTP)
                xml.MSTP(cmp.MSTP)
                xml.AWHCdeduction1(cmp.SubsurfaceAWHCdeduction1)
                xml.AWHCdeduction2(cmp.SubsurfaceAWHCdeduction2)
                xml.AWHCdedn1and2(cmp.SubsurfaceAWHCdedn1and2)
                xml.AWHCdeduction(cmp.SubsurfaceAWHCdeduction)
                xml.Adjustment(cmp.SubsurfaceAdjustment)
              end
              xml.SubtotalTextureDeduction(cmp.SubtotalTextureDeduction)
              xml.WaterTableDepth(cmp.WaterTableDepth)
              xml.WaterTableDeduction(cmp.WaterTableDeduction)
              xml.ReductionAmount(cmp.MoistureReductionAmount)
              xml.Deduction(cmp.MoistureDeduction)
            end
            xml.SurfaceFactors do
              xml.OC(cmp.SurfaceOC)
              xml.S(cmp.SurfaceS)
              xml.ConsistenceDeductionD(cmp.SurfaceDeductionD)
              xml.OMContext
              xml.OMContextDeductionF(cmp.SurfaceDeductionF)
              xml.DepthOfTopSoil(cmp.SurfaceDepthTopSoil)
              xml.DepthOfTopSoilDeductionE(cmp.SurfaceDeductionE)
              xml.Reaction(cmp.SurfaceReaction)
              xml.ReactionDeductionInterim(cmp.SurfaceReactionDeductionInterim)
              xml.ReactionDeduction(cmp.SurfaceReactionDeduction)
              xml.Salinity(cmp.SurfaceSalinity)
              xml.SalinityDeductionInterim(cmp.SurfaceSalinityDeductionInterim)
              xml.SalinityDeduction(cmp.SurfaceSalinityDeduction)
              xml.Sodicity(cmp.SurfaceSodicity)
              xml.SodicityDeductionInterim(cmp.SurfaceSodicityDeductionInterim)
              xml.SodicityDeduction(cmp.SurfaceSodicityDeduction)
              xml.MostLimitingDeduction(cmp.SurfaceMostLimitingDeduction)
              xml.DepthOrganicHorizons(cmp.OrganicDepth)
              xml.BulkDensityOrganicHorizons(cmp.OrganicBD)
              xml.OrganicSurfaceDeduction(cmp.OrganicDeductionO)
              xml.TotalDeductions(cmp.SurfaceTotalDeductions)
              xml.InterimSoilRatingD(cmp.SurfaceInterimSoilRating)
            end
            xml.SubsurfaceFactors do
              xml.HighestImpedenceBD(cmp.SubsurfaceHighestImpedenceBD)
              xml.HighestImpedenceClay(cmp.SubsurfaceHighestImpedenceClay)
              xml.HighestImpedenceClayDeduction(cmp.SubsurfaceHighestImpedenceClayDeduction)
              xml.ImpedingDepth(cmp.SubsurfaceHighestImpedenceUpperDepth)
              xml.PPE(@climatePoly.ppe)
              xml.ImpedenceModificationDeduction(cmp.SubsurfaceHighestImpedenceModificationDeduction)
              xml.ImpedenceDeduction(cmp.SubsurfaceHighestImpedenceDeduction)
              xml.Reaction(cmp.SubsurfaceReaction)
              xml.ReactionDeductionInterim(cmp.SubsurfaceReactionDeductionInterim)
              xml.ReactionDeduction(cmp.SubsurfaceReactionDeduction)
              xml.Salinity(cmp.SubsurfaceSalinity)
              xml.SalinityDeductionInterim(cmp.SubsurfaceSalinityDeductionInterim)
              xml.SalinityDeduction(cmp.SubsurfaceSalinityDeduction)
              xml.Sodicity(cmp.SubsurfaceSodicity)
              xml.SodicityDeductionInterim(cmp.SubsurfaceSodicityDeductionInterim)
              xml.SodicityDeduction(cmp.SubsurfaceSodicityDeduction)
              xml.MostLimitingDeduction(cmp.SubsurfaceMostLimitingDeduction)
              xml.PercentDeduction(cmp.SubsurfacePercentDeduction)
              xml.PercentReduction(cmp.SubsurfaceDeduction)
            end
            xml.InterimBasicSoilRating(cmp.InterimBasicSoilRating)
            xml.FinalBasicSoilRating(cmp.FinalBasicSoilRating)
            xml.DrainageFactor do
              xml.WaterTableDepth(cmp.WaterTableDepth)
              xml.PPE(@climatePoly.ppe)
              xml.PercentSi(cmp.SurfaceSi)
              xml.PercentC(cmp.SurfaceC)
              xml.PercentDeduction(cmp.DrainagePercentDeduction)
              xml.Deduction(cmp.DrainageDeduction)
            end
            xml.Rating(cmp.FinalSoilRating)
            xml.Class(cmp.SoilClass)
          end # MineralSoil
        end # if cmp.order
        # landscape
        xml.Landscape do
          xml.ErosivityRegion(@landscapePoly.ErosivityRegion)
          xml.Complexity(cmp.LandscapeComplexity)
					xml.CropLandscapeModel(@cropLandscapeModel)
          xml.Pattern(cmp.LandscapePattern)
          xml.FloodingFreq(cmp.LandscapeFloodingFreq)
          xml.FloodingPeriod(cmp.LandscapeFloodingPeriod)
          xml.Slope do
            xml.DeductionRaw(cmp.LandscapeSlopeDeductionRaw)
            xml.Deduction(cmp.LandscapeSlopeDeduction)
            xml.BasicRating(cmp.LandscapeBasicRating)
          end
          xml.CoarseFragment do
            xml.StoninessPercentDeduction(cmp.LandscapeStoninessPercentDeduction)
            xml.GravelPercentDeduction(cmp.LandscapeGravelPercentDeduction)
            xml.WoodContentPercentDeduction(cmp.LandscapeWoodContentPercentDeduction)
            xml.TotalCFPercentDeduction(cmp.LandscapeTotalCFPercentDeduction)
            xml.CFDeduction(cmp.LandscapeCFDeduction)
            xml.InterimRating(cmp.LandscapeInterimRating)
          end
          xml.Other do
            xml.PatternPercentDeduction(cmp.LandscapePatternPercentDeduction)
            xml.FloodingPercentDeduction(cmp.LandscapeFloodingPercentDeduction)
            xml.TotalPercentDeductions(cmp.LandscapeTotalOtherPercentDeductions)
            xml.Deduction(cmp.LandscapeOtherDeduction)
          end
          xml.Rating(cmp.LandscapeFinalRating)
          xml.Class(cmp.LandscapeClass)
        end
      end # Cmp
    end # for cmp
  end
  xml.Rating do
    xml.FinalCombinedRating(@lsrsRating)
  end
end