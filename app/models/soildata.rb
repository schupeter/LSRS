class Soildata

	def Soildata.get(id)
		# return ag soil if it exists, else return native soil
			snt = "Soil_name_"+id[0..1].downcase+"_v2"
			slt = "Soil_layer_"+id[0..1].downcase+"_v2"
			soil = AccessorsSoil.new
			soil.layers = []
			# try ag soil first
			soil_id = id[0..9] + "A"
			soil.name= eval(snt).where(:soil_id => soil_id).first
      if soil.name != nil then
				# ag soil exists
        #soil[:nameData] = true
        soil.layers = eval(slt).where(:soil_id => soil_id).order(:layer_no)
        #if soil.layers.size > 0 then soil[:layerData] = true else soil[:layerData] = false end
			else
				# no ag soil
				#soil[:nameData] = false
      end
			# if no layer data then try native soil 
      #if not soil[:layerData] then
      if soil.layers.size == 0 then
        soil_id = id[0..9] + "N"
        soil.layers = eval(slt).where(:soil_id => soil_id).order(:layer_no)
        if soil.layers.size > 0 then
					# native layers exist
          #soil[:layerData] = true
					soil.name = eval(snt).where(:soil_id => soil_id).first
					#soil[:nameData] = true
				else
					# native layers don't exist
					#soil[:layerData] = false
					if soil.name == nil then
						#ag name data is missing so use native soil
						soil.name = eval(snt).where(:soil_id => soil_id).first
						if soil.name != nil then
							# native soil exists
							#soil[:nameData] = true
						end
					end
				end
      end
		return soil
	end

end