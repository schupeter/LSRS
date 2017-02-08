class CropBromeController < ApplicationController

	# rate a climate
	def climate
		@crop = "brome"
		@site = AccessorsSite.new
		#Rate_climate.validate_parameters(params, @site.climate, @site.errors)
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Brome.rate_climate(params, @site.climate)
			render "climate.#{params[:view]}" 
		else 
			render "/crop/error" 
		end
	end

end
