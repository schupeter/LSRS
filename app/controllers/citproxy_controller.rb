class CitproxyController < ApplicationController


  def new
		# display client for a new request
    render
  end

	def create_request
		# store the request
		#@request = Request.new
		#@request.timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
		timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
		#@request.filename = params[:standardInput1].original_filename.gsub(' ','_')
		filename = params[:standardInput1].original_filename.gsub(' ','_')
		#@request.save
		FileUtils.mkdir_p(ROOT.join("active", timestamp))
		# write monthly normals file
		File.open(ROOT.join("active", timestamp, filename), 'wb') do |file|
			file.write(params[:standardInput1].read)
		end
		# write parameters
		File.open(ROOT.join("active", timestamp, "parameters.txt"), 'wb') do |file|
			file.write(params.except("controller","action", "standardInput1"))
		end
	end

	def list
		# display all requests (pending and complete)
		render
	end
	
	def store_response
		# store the response received from the mediator
		File.open(ROOT.join("active", params[:timestamp], params[:file].original_filename), 'wb') do |file|
			file.write(params[:file].read)
		end
		Request.move_to_complete(params[:timestamp])
		render "store_response.txt", :layout => false
	end




	def debug2
		# store the request
		@request = Request.new
		@request.timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
		@request.filename = params[:file].original_filename.gsub(' ','_')
		@request.save
		FileUtils.mkdir_p(DIR.join(@request.timestamp))
		File.open(DIR.join(@request.timestamp, @request.filename), 'wb') do |file|
			file.write(params[:file].read)
		end
	end
	
	def debug1
		File.open(DIR.join("junk_results"), 'wb') do |file|
			file.write(params[:file].read)
		end
	end


# remember to delete completed processing requests from queue


end