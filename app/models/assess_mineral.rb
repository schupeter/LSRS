class Assess_mineral
# generic mineral soil rating calculations, called by each crop.
# =====================

	# Aridity Factor
	def Assess_mineral.moisture(ppe, ppe_deduct)
		
  end


# ===
# need at least 4 levels of calls, where ** = web interface
# 1 - **  given a polygon id, figure out the components, which calls
# 2 - given a component, figure out the soil_ids, which calls
# 3 - **  given a soil_id (Crop_alfalfa.soil), standardize into the LSRS layers (Convert_mineral.cmp2standardlayers), and then call
# 4 - single calculations, like moisture, which are found right here 
#

	def Assess_mineral.triage(soil)
		
	end
	
end
