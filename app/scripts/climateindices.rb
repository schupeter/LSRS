#!/usr/local/bin/ruby
# Script to call climate loading and calculations

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
require '/production/sites/sislsrs/app/models/climate_calc.rb'
require '/production/sites/sislsrs/app/models/climate_canolaheat.rb'
require '/production/sites/sislsrs/app/models/climate_chu.rb'
require '/production/sites/sislsrs/app/models/climate_egdd.rb'
require '/production/sites/sislsrs/app/models/climate_erosivity.rb'
require '/production/sites/sislsrs/app/models/climate_evap.rb'
require '/production/sites/sislsrs/app/models/climate_gdd.rb'
require '/production/sites/sislsrs/app/models/climate_load.rb'
require '/production/sites/sislsrs/app/models/web.rb'
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
	end
when "daily"
	Climate_load.daily("/development/data/climate/#{datatype}/#{filename}")
end

