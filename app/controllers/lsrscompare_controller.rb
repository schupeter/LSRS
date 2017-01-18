class LsrscompareController < ApplicationController

  def client
    #get libraries
    require "yaml"
    
    # get request parameters
    params.each do |key, value|
      case key.upcase        # clean up letter case in request parameters
        when "STEP" then @step = value.to_i
				when "JOB1" then @job1 = value
        when "JOB2" then @job2 = value
      end # case
    end # params
    @timestamp = DateTime::now.to_s[0,19].delete("-:").gsub("T", "t")

    if !(defined? @step) then @step = 1 end # request parameter missing, so start at step 1. 
      @baseDir = "#{Rails.root.to_s}/public/batch/"
    
    # STEP 1:  select first job
    if @step == 1 then
      # get existing batch jobs
      @resultsJobsArray  = Dir.entries(@baseDir + "results/").sort
      @resultsJobsArray.delete(".")
      @resultsJobsArray.delete("..")
      #for all jobs get the contents of the results files
      @resultsHash = Hash.new
      for jobName in @resultsJobsArray
        # determine directory name
        dirName = @baseDir + "results/" + jobName + "/"
        # populate metadata for that directory
        @resultsHash[jobName] = Hash.new
        if File::exists?( dirName + "control.yml" ) then # complete
          @resultsHash.store(jobName, YAML.load_file(@baseDir + "results/" + jobName + "/control.yml") )
        end
      end
      render :action => 'client1', :layout => false and return and exit 1
    end # step 1
    
    # STEP 2:  select other job
    if @step == 2 then
      @job1Hash = YAML.load_file(@baseDir + "results/" + @job1 + "/control.yml")
      # get existing batch jobs
      @resultsJobsArray  = Dir.entries(@baseDir + "results/").sort
      @resultsJobsArray.delete(".")
      @resultsJobsArray.delete("..")
      @resultsJobsArray.delete(@job1) # exclude the already selected job
      #for all jobs get the contents of the results files
      @resultsHash = Hash.new
      for jobName in @resultsJobsArray
        if jobName != @job1 # exclude the already selected job
          # determine directory name
          controlFileName = @baseDir + "results/" + jobName + "/control.yml"
           # populate metadata for that directory
          if File::exists?( controlFileName ) then # complete
            jobHash = YAML.load_file(controlFileName)
            if @job1Hash['FrameworkName'] == jobHash['FrameworkName'] then
              @resultsHash.store(jobName, jobHash)
            end
          end
        end
      end
      @comparableJobsArray = @resultsHash.keys.sort
      render :action => 'client2', :layout => false and return and exit 1
    end # step 2

  end # client

end
