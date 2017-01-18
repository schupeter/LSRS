class Request
  #attr_accessor :timestamp, :filename
	
	class << self

		def active
			Dir.chdir("/production/proxies/cit_v1r2/active")
			Dir.glob("*")
		end

		def complete
			Dir.chdir("/production/proxies/cit_v1r2/complete")
			Dir.glob("*")
		end

		def all
			self.active + self.complete
		end

		def filename(timestamp)
			Dir.chdir("/production/proxies/cit_v1r2/active/#{timestamp}")
			(Dir.glob("*") - ["parameters.txt", "results.txt"])[0]
		end

		def move_to_complete(timestamp)
			FileUtils.mv("/production/proxies/cit_v1r2/active/#{timestamp}", "/production/proxies/cit_v1r2/complete/")
		end

	end
end
