class CropFieldcropController < ApplicationController

	# rate a site (soil + landscape)
	def site
		@site = AccessorsSite.new		
		Validate.site_params(params, @site, @site.climate, @site.soil, @site.landscape, @site.errors)
		if @site.errors == [] then 
			@site.soil = Soildata.get(params[:soil_id])
			Fieldcrop1.rate_soil(params, @site)
			Fieldcrop1.rate_landscape(params, @site)
			if @site.soil.SuitabilityClass == "NotRated" then render "not_rated"
			elsif @site.soil.name.order3 == "OR" then 	render "site.organic.#{params[:view]}" 
			else render "site.mineral.#{params[:view]}" 
			end
		else
			render "/crop/error" 
		end
	end

end
