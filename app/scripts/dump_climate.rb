#!/usr/local/bin/ruby
# Script to dump out climate data from MySQL so it can be imported into Redis

#get libraries
require 'fileutils'
require 'active_record'
require "/production/sites/sislsrs/app/models/mysql_tables/lsrs_cmp.rb"
require "/production/sites/sislsrs/app/models/mysql_tables/lsrs_climate.rb"
require "/production/sites/sislsrs/app/models/mysql_tables/lsrs_framework.rb"
require 'redis'
redis = Redis.new

# mimic rails
@config = YAML.load_file("/production/sites/sislsrs/config/database.yml")
ActiveRecord::Base.establish_connection(@config["development"])

# create any missing directories used for Redis data dumps
@frameworks = LsrsCmp.all.collect{|c| c.DSSClimatePolygonTable[0..-5]}
dirName = "/production/data/climate/polygons/"
Dir.chdir(dirName)
@frameworks.each{|d| Dir.mkdir(d) if not Dir.exists?(d) } # change this to: for framework in @frameworks do...

for frameworkName in LsrsFramework.all.select(:WarehouseName).map{|n| n.WarehouseName} do
	pat = "#{frameworkName}_pat"
	@climates = LsrsClimate.where(:PolygonTable=>pat)
	for climate in @climates do
		puts climate.WarehouseName
		fileName = climate.WarehouseName[frameworkName.size+1..-1] # drop framework name from warehouse name to create file name
		sourcePathname = "#{dirName}/#{frameworkName}/#{fileName}.txt"
		metadataPathname = "#{dirName}/#{frameworkName}/#{fileName}.txt1metadata.json"
		normalsPathname = "#{dirName}/#{frameworkName}/#{fileName}.txt2normals.redisdump"
		indicesPathname = "#{dirName}/#{frameworkName}/#{fileName}.txt3indices.redisdump"
		# create a dummy txt file for each climate scenario
		if not File.exists?(sourcePathname) then FileUtils.touch(sourcePathname) end
		# populate the metadata file for each climate scenario
		if not File.exists?(metadataPathname) then
			@metadataHash = {"Title"=>climate.Title_en,"Geography"=>"polygons","Framework"=>frameworkName,"Timeframe"=>"?","Origin"=>"?","Description"=>"?"}
			File.open(metadataPathname, 'w'){ |f| f << @metadataHash.to_json }
		end
		# create a dummy normals dump file for each climate scenario
		if not File.exists?(normalsPathname) then FileUtils.touch(normalsPathname) end
		# populate the indices dump file for each climate scenario
		indicesKey = "#{frameworkName}/#{fileName}:indices"
		require "/production/sites/sislsrs/app/models/mysql_tables/#{climate.WarehouseName}.rb"
		for p in eval(climate.WarehouseName.capitalize).all do
			redis.hset(indicesKey, p.poly_id, {"ppe"=>p.ppe,"egdd"=>p.egdd,"chu"=>p.chu,"esm"=>p.esm,"efm"=>p.efm,"eff"=>p.eff,"rhi"=>p.rhi,"er"=>p.ErosivityRegion,"julymean"=>p.julymean,"canhm"=>p.canhm,"gdd"=>p.gdd,"gss"=>p.gss,"gse"=>p.gse,"gsl"=>p.gsl}.to_json)
		end
		File.open(indicesPathname,"w"){ |f| f << redis.dump(indicesKey) }
		redis.expire(indicesKey, 20000000)
	end
end


# problems with dump files???


=begin

require 'redis'
redis = Redis.new
require 'json'

redis.restore("test",20000000,File.read("/production/data/climate/polygons/dss_v3_yt/CD_dss_ACCESS1_3_85_2025_2.txt3indices.redisdump"))
redis.restore("test2",20000000,File.read("/production/data/climate/polygons/dss_v3_bclowerfraser/climate1961x90nlwis_slcv3x0.txt3indices.redisdump"))

redis.restore("test",20000000,File.read("/production/data/climate/polygons/dss_v3_yt/CD_dss_ACCESS1_3_85_2025_2.txt3indices.redisdump"))
File.open("/production/data/climate/polygons/dss_v3_yt/junk.redisdump","w"){ |f| f << redis.dump("test") }

irb(main):010:0> JSON.parse(redis.hget("CD_dss_ACCESS1_3_85_2025_2.txt", "YTD013000670"))
=> {
"precip"=>[19.2, 13.3, 11.4, 6.5, 21.6, 33.9, 47.5, 37.2, 32.0, 21.4, 18.2, 17.6], 
"tmin"=>[-24.6, -21.1, -14.0, -4.3, 1.6, 5.5, 8.2, 6.3, 1.6, -3.6, -16.5, -19.9], 
"tmax"=>[-14.1, -8.6, 0.4, 10.4, 15.5, 19.5, 22.3, 21.0, 14.3, 5.0, -7.5, -9.9], 
"ER"=>1, 
"GDD_First"=>115, 
"GDD_Last"=>272, 
"GDD_Length"=>158, 
"GDD"=>1015, 
"GDDF_First"=>115, 
"GDDF_Last"=>272, 
"GDDF_Length"=>158, 
"GDDF"=>1015, 
"EGDD_First"=>125, 
"EGDD"=>1172, 
"cracks5index"=>114, 
"EGDD_Last"=>267, 
"PPE"=>-311.7, 
"chu_start"=>168, 
"chu_stop"=>272, 
"CHU1"=>1376, 
"CHU2"=>1503, 
"EGDD600"=>199, 
"EGDD1100"=>248, 
"TmaxEGDD"=>20.9, 
"CanHM"=>0.6}
=end