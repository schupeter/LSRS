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

	# rate a site (soil + landscape)
	def site
		@site = AccessorsSite.new
		@site.crop = "brome"
		Validate.site_params(params, @site.climate, @site.soil, @site.landscape, @site.errors)
		if @site.errors == [] then 
			@site.soil = Soildata.get(params[:soil_id])
			Fieldcrop1.rate_soil(params, @site)
			Fieldcrop1.rate_landscape(params, @site)
			render "site.#{params[:view]}" 
		else
			render "/crop/error" 
		end
	end

end
