class Climate_load

	def Climate_load.daily(params, filename)
		# Deal with leap years by adding Dec 30 to Dec 31 data for precipitation, average the temp.
		# See http://news.stanford.edu/news/2001/december12/leapyear-1212.html
		# initialize an array to help convert month # to location in an array
		month2julian = [nil,0,31,60,91,121,152,182,213,244,274,305,335]
		# read raw data
		@input = File.read(filename).gsub("\r\n","\n")
		@yaml = YAML.safe_load(@input)
		
		@observationsArray = CSV.parse(@input.split("--- #TSV\n")[1], headers:true, header_converters: :symbol, converters: :all, col_sep: "\t")
		
		#@observationsArray = CSV.read(filename, headers:true, header_converters: :symbol, converters: :all, col_sep: "\t")
		# build a hash to hold data for all stations
		@observationsHash = Hash.new
		coordinatesHash = Hash.new
		require 'net/http'
		for row in @observationsArray do
			if row[:station].class == Float then row[:station] = row[:station].to_i end
			# set up a hash for a new station
			if @observationsHash.keys.include?(row[:station]) == false then 
				@observationsHash[row[:station]] = Hash.new
				coordinatesHash[row[:station]] = {:lat=>row[:lat] ,:long=>row[:long] , :elev=>row[:elev]}
				coordinatesHash[row[:station]][:ErosivityRegion] = Climate_erosivity.identify_erosivityregion(Web.get_ecoprovince(row[:lat],row[:long]))				
			end
			# set up julian day array (with a leading nil)
			if @observationsHash[row[:station]].keys.include?(row[:year]) == false then @observationsHash[row[:station]][row[:year]] = Array.new(367, nil) end
			# populate array with data
			@observationsHash[row[:station]][row[:year]][month2julian[row[:month]]+row[:day]] = {:tmin=>row[:tmin],:tmax=>row[:tmax],:precip=>row[:total_ppt]}
		end
		# @observationsHash is populated with all raw data at this point.
		# for each year, [0] will always be nil, and [60] will be nil during leap years
		# Now need to:
		# - collapse Dec 30 & 31 for leap years.
		# - remove Feb 29 for non-leap years
		require 'fileutils'
		for station in @observationsHash.keys do
			for year in @observationsHash[station].keys do
				if Date.leap?(year) then # collapse Dec 30 & 31
					@observationsHash[station][year][365][:tmin] = (@observationsHash[station][year][365][:tmin] + @observationsHash[station][year][366][:tmin]) / 2
					@observationsHash[station][year][365][:tmax] = (@observationsHash[station][year][365][:tmax] + @observationsHash[station][year][366][:tmax]) / 2
					@observationsHash[station][year][365][:precip] = (@observationsHash[station][year][365][:precip] + @observationsHash[station][year][366][:precip])
					@observationsHash[station][year].delete_at(366)
				else
					@observationsHash[station][year].delete_at(60) # remove feb 29
				end
				@observationsHash[station][year].delete_at(0) # remove placeholder
				# save file as CSV
				dirname = "/production/data/climate/stations/#{station}/daily"
				FileUtils.mkdir_p(dirname) # create all missing subdirectories
				# Create a new CSV file populated with observations data
				CSV.open("#{dirname}/#{year}.csv", 'w', col_sep: "\t") do |csv|
					csv << ['tmin', 'tmax', 'precip'] # Add headers
					@observationsHash[station][year].each do |row|
						csv << [row[:tmin], row[:tmax], row[:precip]]
					end
				end #creating csv
			end #for year
			# update coordinates file
			File.open("/production/data/climate/stations/#{station}/coordinates.json","w"){ |f| f << coordinatesHash[station].to_json }
		end #for station
		# - ensure that there are 365 days with no nils. 
		# TBD
	end

	def Climate_load.monthly(filename)
		@input = File.read(filename).gsub("\r\n","\n")
		@yaml = YAML.safe_load(@input)
		@normalsArray = CSV.parse(@input.split("--- #TSV\n")[1], headers:true, header_converters: :symbol, converters: :all, col_sep: "\t")
		# build a hash to hold data for all stations
		@normalsHash = Hash.new
		@coordinatesHash = Hash.new
		@sitesArray = Array.new
		require 'net/http'
		for row in @normalsArray do
			if row != [] then
				if row[:id].class == Float then row[:id] = row[:id].to_i end
				#if row[:scenario].class == Float then row[:scenario] = row[:scenario].to_s else row[:scenario] = row[:scenario].gsub(" ","_") end
				# set up a hash for a new station
				if @normalsHash.keys.include?(row[:id]) == false then 
					@normalsHash[row[:id]] = Hash.new
					@coordinatesHash[row[:id]] = {:lat=>row[:lat] ,:long=>row[:long] , :elev=>row[:elev]}
					@coordinatesHash[row[:id]][:ErosivityRegion] = Climate_erosivity.identify_erosivityregion(Web.get_ecoprovince(row[:lat],row[:long]))				
				end
				# set up monthly data arrays (with a leading nil)
				if @normalsHash[row[:id]].keys.include?(row[:scenario]) == false then @normalsHash[row[:id]] = {:precip=>Array.new(12, nil),:tmin=>Array.new(12, nil),:tmax=>Array.new(12, nil)} end
				# populate array with data
				for month in 1..12 do
					@normalsHash[row[:id]][:precip][month-1] = row[sprintf("ptot%02d", month).to_sym]
					@normalsHash[row[:id]][:tmin][month-1] = row[sprintf("tmin%02d", month).to_sym]
					@normalsHash[row[:id]][:tmax][month-1] = row[sprintf("tmax%02d", month).to_sym]
				end
				# save station normals data as JSON
				case @yaml['Geography'].downcase
				when 'stations'
					dirname = "/production/data/climate/stations/#{row[:id]}"
				when 'polygons'
					dirname = "/production/data/climate/polygons/#{@yaml['Framework']}/#{row[:id]}"
				else
					return "Error invalid 'Geography'."
				end
				FileUtils.mkdir_p("#{dirname}/monthly") # create all missing subdirectories
				File.open("#{dirname}/coordinates.json","w"){ |f| f << @coordinatesHash[row[:id]].to_json } # update coordinates file
				filename = "#{dirname}/monthly/#{@yaml['Timeframe']}_#{@yaml['Origin']}.json".gsub(" ","_")
				File.open(filename,"w"){ |f| f << @normalsHash[row[:id]].to_json }
				@sitesArray.push(filename)
				puts dirname
			end
		end
		return @sitesArray
	end
=begin DEBUGGING
filename = "/development/data/climate/monthly/CD_dss_ACCESS1_3_85_2025.txt"

=end

end