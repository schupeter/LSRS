class CropAlfalfaController < ApplicationController

	#make separate services for each crop, starting with alfalfa
	# pass everything around in one hash called @rating
	# do only one soil as part of request.
	# params = {:ppe=>"-161", :gdd=>"1749", :gsl=>"194", :esm=>"-40", :efm=>"-50"}

	# rate a climate
	def climate
		@crop = "alfalfa"
		@site = AccessorsSite.new
		Validate.climate_params(params, @site.climate, @site.errors)
		if @site.errors == [] then 
			Alfalfa.rate_climate(params, @site.climate)
			render "climate.#{params[:view]}" 
		else 
			render "/crop/error" 
		end
	end

	# rate a site (soil + landscape)
	def site
		@site = AccessorsSite.new
		@site.crop = "alfalfa"
		Validate.site_params(params, @site.climate, @site.soil, @site.landscape, @site.errors)
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