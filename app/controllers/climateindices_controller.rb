class ClimateindicesController < ApplicationController
# This program generates climate indices from daily temperature data.

 def index
#	 Dir.chdir(Rails.root.join('public','uploads'))
		#Dir.chdir('/development/data/climate/daily')
		#@dailyFilenames = Dir.glob("*").sort # take this out eventually
		Dir.chdir('/production/schemas/climatemonthly/1.0/examples')  # take this out eventually
		@monthlyFilenames = Dir.glob("*").sort # take this out eventually
	end

 def list_daily_calcs
		Dir.chdir('/production/data/climate/stations')
		@dailyStations = Dir.glob(File.join("*/daily", "*.csv")).sort
	end

	def list_monthly_calcs
	end

	def describe
		@field = Definition.where(:name=>params[:name]).first
	end

	def format_lsrs1
		@fields = Definition.where("format_lsrs1 > 0")
		render "show_format.html"
	end

	def calculate_monthly
		# calculates and stores climate indices for a site based on monthly climate normals
		@station = Climate_calc.monthly(params)
	end

	def calculate_daily
		# calculates and stores climate indices for a site based on daily climate data for one year
		@station = Climate_calc.daily(params)
		render "calculate_daily.#{params[:format]}"
	end

	def calculate_dailies
		# calculates and stores climate indices for a site based for all years of daily data
		
	end

	def load_daily_data
		# load and sanitize daily observations data
		@loaded = Climate_load.daily(params, params[:file].path)
		# update flash hash with messages
		flash[:daily] = "Climate data in #{params[:file].original_filename} was loaded."
		redirect_to :action=>"index"
#		render "debug_loaddaily"
	end

	def load_monthly_data
		# load and sanitize monthly normals data
		@loaded = Climate_load.monthly(params[:file].path)
		if @loaded.class == Array then render"load_monthly_data.html.erb" else render "error.html.erb" end
	end

end
