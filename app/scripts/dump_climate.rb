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
		if not File.exists?(sourcePathname) then 
			FileUtils.touch(sourcePathname)
			sleep(2) # ensure mtimes will be different
		end
		# populate the metadata file for each climate scenario
		if not File.exists?(metadataPathname) then
			@metadataHash = {"Title"=>climate.Title_en,"Geography"=>"polygons","Framework"=>frameworkName,"Timeframe"=>"?","Origin"=>"?","Description"=>"?"}
			File.open(metadataPathname, 'w'){ |f| f << @metadataHash.to_json }
			sleep(2) # ensure mtimes will be different
		end
		# create a dummy normals dump file for each climate scenario
		if not File.exists?(normalsPathname) then 
			normalsKey = "#{frameworkName}/#{fileName}:normals"
			redis.set(normalsKey, 'Normals data is unavailable (indices were dumped from MySQL)')
			File.open(normalsPathname,"w"){ |f| f << redis.dump(normalsKey) }
			redis.expire(normalsKey, 20000000)
			sleep(2) # ensure mtimes will be different
		end
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
