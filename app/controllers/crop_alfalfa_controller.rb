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
#			render "/crop/climate_gddgsl.#{params[:view]}" 
			render "climate.#{params[:view]}" 
		else 
			render "/crop/error" 
		end
	end

	# rate a soil (OBSOLETE)
	def soil
		@site = AccessorsSite.new
		@site.crop = "alfalfa"
		Validate.soil_params(params, @site.climate, @site.soil, @site.errors)
		if @site.errors == [] then 
			@site.soil = Soildata.get(params[:soil_id])
			Alfalfa.rate_soil(params, @site)
			#console
			render "soil.#{params[:view]}" 
		else
			render "/crop/error" 
		end
	end

	# rate a landscape (OBSOLETE)
	def landscape
		@site = AccessorsSite.new
		@site.crop = "alfalfa"
		Validate.landscape_params(params, @site.landscape, @site.errors)
		if @site.errors == [] then 
			Alfalfa.rate_landscape(params, @site)
			render "landscape.#{params[:view]}" 
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
			Alfalfa.rate_soil(params, @site)
			Alfalfa.rate_landscape(params, @site)
			#console
			render "site.#{params[:view]}" 
		else
			render "/crop/error" 
		end
	end

end