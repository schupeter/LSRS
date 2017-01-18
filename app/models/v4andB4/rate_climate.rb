class Rate_climate
# LSRS4 way of calling climate calcs, as one large calculation
# Obsolescent - can be removed after v5 is fully functional

  def Rate_climate.params(climateParams)
    climateCoeff = Lsrs_climate_coeff_class.new
    climateCoeff.Aa = climateParams[0].Aa.to_f
    climateCoeff.Ab = climateParams[0].Ab.to_f
    climateCoeff.Ha = climateParams[0].Ha.to_f
    climateCoeff.Hb = climateParams[0].Hb.to_f
    climateCoeff.Hc = climateParams[0].Hc.to_f
    climateCoeff.Hd = climateParams[0].Hd.to_f
    climateCoeff.M1a = climateParams[0].M1a.to_f
    climateCoeff.M1b = climateParams[0].M1b.to_f
    climateCoeff.M2a = climateParams[0].M2a.to_f
    climateCoeff.M2b = climateParams[0].M2b.to_f
    climateCoeff.M3a = climateParams[0].M3a.to_f
    climateCoeff.M3b = climateParams[0].M3b.to_f
    climateCoeff.M4a = climateParams[0].M4a.to_f
    climateCoeff.M4b = climateParams[0].M4b.to_f
    climateCoeff.Ba = climateParams[0].Ba.to_f
    climateCoeff.HF = climateParams[0].HF
    climateCoeff.HF1a = climateParams[0].HF1a.to_f
    climateCoeff.HF1b = climateParams[0].HF1b.to_f
    climateCoeff.HF1c = climateParams[0].HF1c.to_f
    climateCoeff.HF2a = climateParams[0].HF2a.to_f
    climateCoeff.HF2b = climateParams[0].HF2b.to_f
    climateCoeff.HF2c = climateParams[0].HF2c.to_f
    return climateCoeff
  end

  def Rate_climate.calc(poly, coeff)
    climate=Lsrs_climate_class.new

    #Moisture Index
    climate.A_deduct_raw = (coeff.Aa + (coeff.Ab * poly.ppe))
    climate.A_deduct = Calculate.constrain(climate.A_deduct_raw, 0, 70)
    climate.A = 100 - climate.A_deduct
    
    #Temperature Factor 
    if coeff.HF == "CHU" then 
      climate.H_deduct_raw = ( coeff.Ha  +  ( coeff.Hb * poly.chu ) + ( coeff.Hc * poly.chu ** 2 ) )
      climate.H_deduct = Calculate.constrain(climate.H_deduct_raw, 0, 90)
      climate.H = 100 - climate.H_deduct
    elsif coeff.HF == "EGDD" then 
      # EGDD
			if poly.egdd > 1600 then climate.H_deduct = 0 else
				climate.H_deduct_raw = ( coeff.Ha  +  ( coeff.Hb * poly.egdd ) + ( coeff.Hc * poly.egdd ** 2 ) + ( coeff.Hd * poly.egdd ** 3 ))
				climate.H_deduct = Calculate.constrain(climate.H_deduct_raw, 0, 90)
			end
			climate.H = 100 - climate.H_deduct
    elsif coeff.HF == "GDD" then
      # GDD
      climate.HF1_raw = coeff.HF1a + ( coeff.HF1b * poly.gdd ) + ( coeff.HF1c * poly.gdd ** 2 )
      climate.HF1 = Calculate.constrain(climate.HF1_raw, 0, 90)
      # GSL
      climate.HF2_raw = coeff.HF2a + ( coeff.HF2b * poly.gsl ) + ( coeff.HF2c * poly.gsl ** 2 )
      climate.HF2 = Calculate.constrain(climate.HF2_raw, 0, 90)
      # pick higher of GDD or GSL
      climate.H_deduct = Calculate.greater(climate.HF1, climate.HF2)
      climate.H = 100 - climate.H_deduct
    end

    # Basic Climate Rating
    if climate.A < climate.H then
      climate.B = climate.A  else
      climate.B = climate.H
    end

    # Climate Modifiers
    climate.M1_raw = coeff.M1a + (coeff.M1b * poly.esm)
    climate.M1 = Calculate.constrain(climate.M1_raw, 0, 10)
    climate.M2_raw = coeff.M2a + (coeff.M2b * poly.esm)
    climate.M2 = Calculate.constrain(climate.M2_raw, 0, 10)
    climate.M3_raw = coeff.M3a + (coeff.M3b * poly.eff)
    climate.M3 = Calculate.constrain(climate.M3_raw, 0, 10)
    climate.M4_raw = coeff.M4a + (coeff.M4b * poly.rhi)
    climate.M4 = Calculate.constrain(climate.M4_raw, 0, 10)
    climate.SumM = climate.M1 + climate.M2 + climate.M3 + climate.M4
    climate.M = climate.SumM * 0.01 * climate.B

    #canola calc
    if coeff.Ba == 0 then 
      climate.Ba = 0
    else
      climateBa_adjustment_percent_raw = (3 * poly.canhm) - 3
      climate.Ba_adjustment_percent = Calculate.constrain(climateBa_adjustment_percent_raw, 0, 100)
      climate.Ba = climate.B * climate.Ba_adjustment_percent / 100
    end
    climate.Value = (climate.B - climate.Ba - climate.M).round
    climate.Rating = Calculate.rating(climate.Value)
    return climate
  end

end

