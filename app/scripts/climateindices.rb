#!/usr/local/bin/ruby
# Script to call climate calculations and load them into Redis
# - it assumes that climate data has been loaded into /production/data/climate/polygons via the 
#   load_monthly_data or load_daily_data controllers (TODO daily data)
# - if the dump file from Redis exists and is current then it loads it into Redis. (TODO) Otherwise,
# - it calculates the climate indices for all polygons in the polygonset and stores them in Redis
# - it creates a dump file from Redis
# this script should be run when new climate data has been uploaded.
# perhaps better to run under cron, <== NO!
# or list runs to do on a webpage and trigger from that page  <== YES!


require "/home/peter/bin/lib/colorize.rb"

# display general help if parameters are missing.
if $*[0] == nil
	puts "Load and calculate climate indices"
	puts "Usage:  climate [polygonset] [datatype] [dataset]"
	puts "  where [polygonset] is a directory found in /production/data/climate/polygons"
	puts "  where [datatype] is one of: monthly|daily"
	puts "  where [dataset] is a observation file name found in all of the indicated monthly directories"
	puts " if filename is missing then the available datasets are displayed"
	puts 
	puts "e.g. climateindices.rb dss_v3_yt monthly 1961x90_Observations.json"
	exit
end
polygonset = $*[0] 
datatype = $*[1] 

# list available datasets if dataset is missing
require 'pathname'
dirs = Pathname.new("/production/data/climate/polygons/#{polygonset}").children.select { |c| c.directory? }.sort
if $*[2] == nil
	case datatype
	when "monthly" 
		puts "Load and calculate climate indices from these #{datatype} normals datasets".yellow
		dirs.each{|d| puts d.to_s.split('/')[-1]}
	else
		puts "Invalid parameter: '#{$*[0] }'.  Must be 'monthly' or 'daily'."
	end
	exit
end

# prep ruby environment
require 'net/http'
require 'yaml'
require 'csv'
require 'json'
require 'fileutils'
require 'active_support/core_ext/enumerable.rb' # sum
require 'active_support/core_ext/string.rb' # to_date
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

# process data
filename = $*[1] 
redis = Redis.new
case datatype
when "monthly"
	puts "Calculating indices".yellow
	for location in dirs do
		puts "location".red
		puts location
		p = location.to_s.split('/')
		case p[4]
		when "stations"
			params = {:station=>p[5], :normals=>p[7]}
		when "polygons"
		  scenarios = (dirs[0]+datatype).children
			p = scenarios[0].to_s.split('/')
			params = {:polygonset=>p[5], :polygon=>p[6], :normals=>p[8][0..-6]} 
		end
		Climate_calc.monthly(params, redis)
		
		
		# add to the hash in Redis 
#		TODO THIS BELONGS IN  Climate_calc.monthly
		redis.hset("ytc003:1961x90_Observations","10",Climate_calc.monthly(params))
		
	end
	# dump the hash from Redis
	puts filename[0..-5]
	File.open("/production/data/climate/polygons/#{filename[0..-5]}.properties.redisdump","w"){ |f| f << redis.dump("#{params[:polygonset]}:#{params[:normals]}") }
when "daily"
	Climate_load.daily("/development/data/climate/#{datatype}/#{filename}")
end

