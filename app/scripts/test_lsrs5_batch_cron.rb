#!/usr/bin/ruby
# Run these commands in IRB or run program from shell

# create color palette for output text
require "/home/peter/bin/lib/colorize.rb"

@batchDir = "/production/sites/sislsrs/public/batch/"
Dir.chdir(@batchDir + "pending/")

#get libraries
require 'fileutils'
require 'yaml'
require '/production/sites/sislsrs/app/helpers/libxml-helper'
require '/production/sites/sislsrs/app/models/ogc/wps1'
require '/production/sites/sislsrs/app/models/ogc/lsrs_gdas'
require 'open-uri'
require 'builder'
require 'active_record'
require 'dbf'
require '/production/sites/sislsrs/app/helpers/dbf-helper'
require '/production/sites/sislsrs/app/models/ogc/gdas2dbf'
require 'redis'
redis = Redis.new

# get control file
nextJob = "20170508t181650r9810_control.yml"
@controlPathname = @batchDir + "pending/" + nextJob
@control = YAML.load_file(@controlPathname)

# parse contents of control file
@detailsRootURL = @control['DetailsRootURL']
outputXmlFilename = @control['OutputXmlFilename']
outputCsvFilename = @control['OutputCsvFilename']
outputDbfFilename = @control['OutputDbfFilename']
outputHtmlFilename = @control['OutputHtmlFilename']
outputDbfSummaryFilename = @control['OutputDbfSummaryFilename']
@statusFilename = @control['StatusFilename']
@statusURL = @control['StatusURL']
@outputURL = @control['OutputURL']
@frameworkName = @control['FrameworkName']
@cmpTable = @control['ComponentTable']
@fromPoly = @control['FromPoly']
@toPoly = @control['ToPoly']
@crop = @control['Crop']
@management = @control['Management']
@climateName = @control['ClimateTable']  # TODO: change from MySQL table row to Redis key name
puts "@frameworkName = #{@frameworkName}".yellow
puts "@climateName = #{@climateName}".yellow

# Get array of polygon identifiers from the text file that was generated by the lsrsbatch_controller
@slArray = File.new(@control['PolygonsFilename']).readlines.map {|line| line.chomp}

# set some names
@climateSourcePathname = "/production/data/climate/polygons/#{@frameworkName}/#{@climateName}"
@normalsDumpPathname = @climateSourcePathname + ".normals.redisdump"
@indicesDumpPathname = @climateSourcePathname + ".indices.redisdump"
@normalsKey = "#{@frameworkName}:#{@climateName}:normals"
@indicesKey = "#{@frameworkName}:#{@climateName}:indices"

# check to see if climate data has been processed into indices
if not File.exist?(@climateSourcePathname) then puts "ERROR: Climate data file doesn't exist"  end
if not File.exist?(@normalsDumpPathname) then puts "NOTE: Climate normals redisdump file doesn't exist" end
if not File.exist?(@indicesDumpPathname) then puts "NOTE: Climate indices redisdump file doesn't exist" end

# load or update climate data into Redis if necessary


# normals dump may be outdated (if source data was edited or updated on disk) or was never created
if File.exist?(@normalsDumpPathname) and File.mtime(@normalsDumpPathname) > File.mtime(@climateSourcePathname) then 
	# normals dump file is up to date
	if redis.expire(@normalsKey, 20000000) then
		puts "ttl for normals key was reset"
	else # key has expired, so reload from dump file
		redis.restore(@normalsKey,20000000,File.read(@normalsDumpPathname))
		puts "normals key was reloaded"
	end
else
	# normals redis key and redisdump as well as metadata file need to be created/updated
	puts "Refreshing redisdump of normals data"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_load.rb"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_erosivity.rb"
	require "/production/sites/sislsrs/app/models/other/web.rb"
	Climate_load.monthlies(@climateSourcePathname, @normalsKey, @normalsDumpPathname)
	redis.expire(@normalsKey, 20000000)
end

# indices may be outdated or were never created
if File.exist?(@indicesDumpPathname) and File.mtime(@indicesDumpPathname) > File.mtime(@normalsDumpPathname) then
	# indices dump file is up to date
	if redis.expire(@indicesKey, 20000000) then
		puts "ttl for indices key was reset"
	else # key has expired, so reload from dump file
		redis.restore(@indicesKey,20000000,File.read(@indicesDumpPathname))
		puts "indices key was reloaded"
	end
else 
	# indices dump is outdated, so both redis key and redisdump need to be created/updated
	puts "Refreshing redisdump of indices"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_calc.rb"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_gdd.rb"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_egdd.rb"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_evap.rb"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_chu.rb"
	require "/production/sites/sislsrs/app/models/climate_indices/climate_canolaheat.rb"
	require 'active_support/core_ext/string/conversions.rb'
	Climate_calc.monthlies(@normalsKey, @indicesKey, @indicesDumpPathname, redis)
	redis.expire(@indicesKey, 20000000)
end

puts "Debugging from here".red
puts "Got to here".green

# now calculate soil ratings



 