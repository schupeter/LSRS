class Lsrs5Controller < ApplicationController

# Goals for version 5 (a production system that incorporates calculation of climate indices and supports raster):
#
# validate climate data, calc indices, and store them (to simplify access, performance, and reliability)
# read climate indicies directly into climate rating (to simplify use and eliminate a significant source of human errors)
# move formula parameters from databasa into code (to simplify system maintenance)
# eliminate storage of historic runs (not needed for a production system)
# generate ratings from points, not formulas (eliminate unwanted effects at climate extremes)
# store points in one place and use for ratings and to generate documentation (to improve consistency and simplify deduction curve edits)
# change access mechanism to REST (to support saving data for use in raster assessments)
# create separate access for climate. soil. landscape ratings and store complete details separately (to support raster)
# separate all interactions between soil/climate/lansdcape into final calc (to improve logic and simplify raster calculations)
# put soil/climate/lansdcape ratings in Redis or Mysql or a table (to support fast access for raster)
# drop XSLT and use plain HTML for all human-readable outputs (to simplify maintenance)


	# generates the LSRSv5 urls for a given polygon + climate + crop
	# first validates the input parameters, then gets component and climate data for the polygon
	def polygon
		@rating = AccessorsRating.new
		Validate.polygon(params, @rating)
		Polygon.get_data(@rating.polygon, @rating.climateData, @rating.errors) if @rating.errors == []
		Polygon.get_ratings(@rating.crop, @rating.polygon, @rating.climateData.data, @rating.climate, @rating.errors) if @rating.errors == []
		Polygon.aggregate_ratings(@rating.polygon.components, @rating.climate, @rating.aggregate) if @rating.errors == []
		if @rating.errors.size > 0 then @rating.responseForm = "error" end
		render "polygon_" + @rating.responseForm
	end

	# prepares a valid request for the polygon action
  def polygon_client
		private_set_rating_parameters
  end

	# generates the LSRSv5 ratings for a given set of polygons + climate + crop
	def polygonbatch
		if params.size > 2 then # set up batch process
			@batch = AccessorsPolygonbatch.new
			@batch.host = request.host
			Validate.polygonbatch(params, request, @batch)
			Polygonbatch.get_poly_ids(@batch) if @batch.errors == []
			if @batch.errors == [] then
				if @responseForm == "ResponseDocument" or @batch.polygonsHash.keys.size > 30 then #add to the batch queue
					Polygonbatch.queue(@batch)
					render :file => @batch.statusFilename, :content_type => "text/xml", :layout => false 
				else # run immediately
					Polygonbatch.calc_ratings(@batch)
					render"polygonbatch_small"
				end
			else
				render "polygonbatch_error"
			end
		else # display usage instructions
			@processHash = YAML.load_file("#{Rails.root.to_s}/config/services/wps/processes/lsrs.yml")
			@lang="en"
			render "polygonbatch_DescribeProcess_response"
		end
	end

	# prepares a valid request for the polygon batch processor
	def polygonbatch_client
		private_set_rating_parameters
		console
  end

  def batch_queue
    #get libraries
    require "yaml"
    # get existing batch jobs
    @baseDir = "#{Rails.root.to_s}/public/batch5/"
    @resultsJobsArray  = Dir.entries(@baseDir + "results/").sort.reverse
    @resultsJobsArray.delete(".")
    @resultsJobsArray.delete("..")
    #for all jobs get the contents of the results files
    @statusHash = Hash.new
    for jobName in @resultsJobsArray
      # determine directory name
      # populate metadata for that directory
      @statusHash[jobName] = Hash.new
      if File::exists?(@baseDir + "pending/#{jobName}_control.yml") then # pending
        @statusHash.store(jobName, YAML.load_file(@baseDir + "pending/#{jobName}_control.yml") )
        @statusHash[jobName].store(:Status, "Pending")
      elsif File::exists?(@baseDir + "processing/#{jobName}_control.yml") then # processing or halted
        @statusHash.store(jobName, YAML.load_file(@baseDir + "processing/#{jobName}_control.yml") )
				if File::exists?(@baseDir + "results/#{jobName}/output.html") then
					if (Time.now - File.stat(@baseDir + "results/#{jobName}/output.html").mtime) < 100 then
						@statusHash[jobName].store(:Status, "Processing") 
					else
						@statusHash[jobName].store(:Status, "** FAILED **") 
					end
				else
					@statusHash[jobName].store(:Status, "** FAILED **") 
				end
      elsif File::exists?(@baseDir + "results/#{jobName}/control.yml") then # complete
        @statusHash.store(jobName, YAML.load_file(@baseDir + "results/#{jobName}/control.yml") )
        @statusHash[jobName].store(:Status, "Complete")
      end
    end
    @timestamp = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t")
  end

  def batch_delete
    baseDir = "#{Rails.root.to_s}/public/batch5/"
    @pendingFile = baseDir + "pending/" + params["JobName"] + "_control.yml"
    @processingFile = baseDir + "processing/" + params["JobName"] + "_control.yml"
    @resultsDir = baseDir + "results/" + params["JobName"]
    if params["JobName"]["/"] == nil then # directory name is not being hacked, so rm should be safe
      if File::exists?(@pendingFile) then FileUtils.rm(@pendingFile) end
      if File::exists?(@processingFile) then FileUtils.rm(@processingFile) end
      FileUtils.rm_r(@resultsDir)
    end
  end



  def Index
    render
  end
	
	def debug
		render "/home/debug.html"
	end

	# private methods (these are called without referencing the class name)
	private

	def private_climate_scenarios
		# gather metadata for DSS climate scenarios
		dirName = "/production/data/climate/polygons/#{@soilDataset.DSSClimatePolygonTable[0..-5]}/"
		Dir.chdir(dirName)
		climatesDss = Hash[Dir.glob("*.txt").collect { |f| [f, JSON.parse(File.read("#{f}1metadata.json"),:symbolize_names => true)] } ].collect{|k,v|  ["#{v[:Framework]}/#{k}", v[:Title]]}.sort {|a,b| a[1] <=> b[1]}
		# gather metadata for SLC climate scenarios
		dirName = "/production/data/climate/polygons/#{@soilDataset.SLCClimatePolygonTable[0..-5]}/"
		Dir.chdir(dirName)
		climatesSlc = Hash[Dir.glob("*.txt").collect { |f| [f, JSON.parse(File.read("#{f}1metadata.json"),:symbolize_names => true)] } ].collect{|k,v|  ["#{v[:Framework]}/#{k}", v[:Title]]}.sort {|a,b| a[1] <=> b[1]}
		# return them as one hash
		climatesDss + climatesSlc
	end

	def private_set_rating_parameters
    params.each do |key, value|      # standardize request parameters
      case key.upcase        # clean up letter case in request parameters
        when "FRAMEWORKNAME"
          @frameworkName = value
					@cmpTable = value.delete("~") + "_cmp"
					@patTable = value.delete("~").capitalize + "_pat"
      end # case
    end # params
    if !(defined? @frameworkName) or @frameworkName == "" then
      @step = 1
      @soilDatasets = LsrsCmp.order("Title_en ASC")
    else
      @step = 2
      @soilDataset = LsrsCmp.where(:WarehouseName=>@cmpTable).first
			@climates = private_climate_scenarios
      @crops = Lsrs_crop.all
    end
	end

end
