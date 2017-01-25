class CropFieldcropController < ApplicationController

	# rate a site (soil + landscape)
	def site
		@site = AccessorsSite.new		
		Validate.site_params(params, @site, @site.climate, @site.soil, @site.landscape, @site.errors)
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
