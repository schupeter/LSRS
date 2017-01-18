class CropSssgrainController < ApplicationController

	# rate a climate
	def climate
		@crop = "sssgrain"
		@site = AccessorsSite.new
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Sssgrain.rate_climate(params, @site.climate)
			#render "/crop/climate_egdd.#{params[:view]}" 
			render "climate.#{params[:view]}" 
		else 
			render "/crop/error" 
		end
	end


end