class LsrsbatchstatusController < ApplicationController

  def client
    #get libraries
    require "yaml"

    # get existing batch jobs
    @baseDir = "#{Rails.root.to_s}/public/batch/"
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
				if File::exists?(@baseDir + "results/#{jobName}/output.xml") then
					if (Time.now - File.stat(@baseDir + "results/#{jobName}/output.xml").mtime) < 100 then
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
    
    render :action => 'client', :layout => false and return and exit 1
    
  end
    
  def remove
    baseDir = "#{Rails.root.to_s}/public/batch/"
    @pendingFile = baseDir + "pending/" + params["JobName"] + "_control.yml"
    @processingFile = baseDir + "processing/" + params["JobName"] + "_control.yml"
    @resultsDir = baseDir + "results/" + params["JobName"]
    if params["JobName"]["/"] == nil then # directory name is not being hacked, so rm should be safe
      if File::exists?(@pendingFile) then FileUtils.rm(@pendingFile) end
      if File::exists?(@processingFile) then FileUtils.rm(@processingFile) end
      FileUtils.rm_r(@resultsDir)
    end
  end

end
