class CropSoybeanController < ApplicationController

	# rate a climate
	def climate
		@crop = "soybean"
		@site = AccessorsSite.new
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Soybean.rate_climate(params, @site.climate)
			render "/crop/climate_chu.#{params[:view]}" 
		else 
			render "/crop/error" 
		end
	end

end
