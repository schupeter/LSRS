#!/usr/local/bin/ruby
# Script to call climate loading and calculations and load them into Redis
# - it the dump file from Redis exists and is current then it loads it into Redis. (TODO) Otherwise,
# - it loads the datafile from development that was used to populate the raw climate data in production
# - it calculates the climate indices 
# - it stores them in Redis (TODO)
# - it creates a dump file from Redis (TODO)
# this script should be run when new climate data has been uploaded.
# perhaps better to include it as part of the upload process.


require "/home/peter/bin/lib/colorize.rb"

# display general help if parameters are missing.
if $*[0] == nil
	puts "Load and calculate climate indices"
	puts "Usage:  climate [datatype] [filename]"
	puts "  where [datatype] is one of: monthly|daily"
	puts "  where [filename] is the name of the climate data to be processed"
	puts " if filename is missing then the available datasets are displayed"
	puts 
	puts "e.g. climate monthly dataset27.txt"
	exit
end

# list available filenames if filename is missing
datatype = $*[0] 
if $*[1] == nil
	case datatype
	when "monthly","daily" 
		puts "Load and calculate climate indices from these #{datatype} normals datasets".yellow
		Dir.chdir("/development/data/climate/#{datatype}")
		Dir.glob("**/*\.txt").each{|d| puts " #{d}"}
	else
		puts "Invalid parameter: '#{$*[0] }'.  Must be 'monthly' or 'daily'."
	end
	exit
end

filename = $*[1] 
# process data
require 'net/http'
require 'yaml'
require 'csv'
require 'json'
require 'fileutils'
require 'active_support/core_ext/enumerable.rb'
require 'active_support/core_ext/string.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_calc.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_canolaheat.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_chu.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_egdd.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_erosivity.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_evap.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_gdd.rb'
require '/production/sites/sislsrs/app/models/climate_indices/climate_load.rb'
require '/production/sites/sislsrs/app/models/other/web.rb'
require 'redis'
case datatype
when "monthly"
	puts "Organizing data".yellow
	locationsArray = Climate_load.monthly("/development/data/climate/#{datatype}/#{filename}")
	puts "Now calculating indices".yellow
	for location in locationsArray do
		p = location.split('/')
		case p[4] 
		when "stations" 
			params = {:station=>p[5], :normals=>p[7]} 
		when "polygons" 
			params = {:polygonset=>p[5], :polygon=>p[6], :normals=>p[8][0..-6]} 
		end
		Climate_calc.monthly(params)
		puts params
		puts location
		# add to the hash in Redis
	end
	# dump the hash from Redis
	
	File.open("/production/data/climate/monthly/#{filename[0..-5]}.indices.redisdump","w"){ |f| f << redis.dump("#{params[:polygonset]}:#{params[:normals]}") }
when "daily"
	Climate_load.daily("/development/data/climate/#{datatype}/#{filename}")
end

