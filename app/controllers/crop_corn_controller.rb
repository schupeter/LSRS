class CropCornController < ApplicationController

	# rate a climate
	def climate
		@crop = "corn"
		@site = AccessorsSite.new
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Corn.rate_climate(params, @site.climate)
			render "climate.#{params[:view]}"
		else 
			render "/crop/error" 
		end
	end

end
