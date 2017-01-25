class CropCanolaController < ApplicationController

	# rate a climate
	def climate
		@crop = "canola"
		@site = AccessorsSite.new
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Canola.rate_climate(params, @site.climate)
			#render "/crop/climate_egdd.#{params[:view]}"
			render "climate.#{params[:view]}"
		else 
			render "/crop/error" 
		end
	end

	# rate a site (soil + landscape)
	def site
		@site = AccessorsSite.new
		@site.crop = "canola"
		Validate.site_params(params, @site.crop, @site.climate, @site.soil, @site.landscape, @site.errors)
		if @site.errors == [] then 
			@site.soil = Soildata.get(params[:soil_id])
			Fieldcrop1.rate_soil(params, @site)
			Fieldcrop1.rate_landscape(params, @site)
			#console
			render "site.#{params[:view]}" 
		else
			render "/crop/error" 
		end
	end

end
