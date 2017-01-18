@baseDir = "#{Rails.root.to_s}/public/batch/"
@job1 = "20091119t162418r5984"
@job1Hash = YAML.load_file(@baseDir + "results/" + @job1 + "/control.yml")
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
  puts @job1Hash['FrameworkName'] + "--" + jobHash['FrameworkName']
@resultsHash.store(jobName, jobHash)
end
end
end
end
@comparableJobsArray = @resultsHash.keys.sort
