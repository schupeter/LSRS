class CropCanolaController < ApplicationController

	# rate a climate
	def climate
		@crop = "canola"
		@site = AccessorsSite.new
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Canola.rate_climate(params, @site.climate)
			render "climate.#{params[:view]}"
		else 
			render "/crop/error" 
		end
	end

end
