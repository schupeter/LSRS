class Climate_calc
# generic climate data calculations
# :tmax is maximum temperature in degrees centigrade
# :tmin is minimum temperature in degrees centigrade
# :tprecip is total precipitation in millimeters
# :radiation is solar radiation at the top of the atmosphere

	def Climate_calc.monthly2dailyinterps(monthlyData, daysPerMonth)
		#Calculates 365 daily values from 12 monthly values using a trig interpolation
		#monthlyData has 12 values which normally represent min or max monthly mean temperature values for Jan-Dec
		extendedArray = [monthlyData[11]] + monthlyData + [monthlyData[0]]
		dailyArray = Array.new
		for x in 0..11 do
			a = 7.29*(extendedArray[x+1] - extendedArray[x]) - 3.91*(extendedArray[x+2] - extendedArray[x]);
			b = 1.95*(extendedArray[x+1] - extendedArray[x]);
			c = extendedArray[x] - 6.47*(extendedArray[x+1] - extendedArray[x]) + 3.74*(extendedArray[x+2] - extendedArray[x]);
			for y in 1..daysPerMonth[x] do
				dailyArray.push( (a*Math.cos(0.0174533*y) + b*Math.sin(0.0174533*y) + c) )
			end
		end
		return dailyArray;
	end
	
	def Climate_calc.monthly2dailyprecip(monthlyData, daysPerMonth)
		#Calculates 365 daily values from 12 monthly values
		#monthlyData has 12 values which normally represent total monthly precipitation values for Jan-Dec
		dailyPrecipArray = Array.new
		for month in 0..11 do
			precip = monthlyData[month] / daysPerMonth[month].to_f;
			daysPerMonth[month].times{dailyPrecipArray.push(precip)}
		end
    return dailyPrecipArray
	end

	def Climate_calc.tenyearnormals(climateArray)
		for day in climateArray do
			day[:t10ave] = (day[:tmaxArray].sum +  day[:tminArray].sum)/ 20
			day[:t10min] = day[:tminArray].sum / 10
		end
	end

	def Climate_calc.monthly(normalsKey, polygon, redis)
		# calculates and stores climate indices for a site based on monthly climate normals data
		# get data (based in redis)
		site = JSON.parse(redis.hget(normalsKey,polygon),:symbolize_names => true)  # TODO - add or delete [:monthly]
		@year = "2017" # just any non-leap year - required for yday
		# create climate array with daily values of TMAX, TMIN, TMEAN, PRECIP
		site[:climate] = Array.new(365){|e| {}} # create empty hashes
		daysPerMonth = [31,28,31,30,31,30,31,31,30,31,30,31]
		Climate_calc.monthly2dailyinterps(site[:tmax],daysPerMonth).map.with_index{|v,i| site[:climate][i][:tmax]=v}
		Climate_calc.monthly2dailyinterps(site[:tmin],daysPerMonth).map.with_index{|v,i| site[:climate][i][:tmin]=v}
		Climate_calc.monthly2dailyprecip(site[:precip],daysPerMonth).map.with_index{|v,i| site[:climate][i][:precip]=v}
		# populate climate array with DAYNUMBER, TMEAN
		site[:climate].each_with_index{|v,i| v[:daynumber] = i+1}
		site[:climate].map{|v| v[:tmean] = ( v[:tmax] + v[:tmin] ) / 2}
		# GDD
		site.merge!(Climate_gdd.calc(site,5.0,1,365,1))
		# EGDD
		site.merge!(Climate_egdd.dailyrange(site[:climate],yday("April 1"),site[:GDD_First],yday("October 31")))
		# should probably use Climate_egdd.monthly calc, but monthly is SNAFU
		site[:climate] = Climate_egdd.daily(site[:climate],site[:EGDD_First],site[:EGDD_Last],site[:lat])
		site[:EGDD] = site[:climate].map{|day| day[:egdd]}.compact.sum.round(0)
		# populate climate array with RADIATION, PE
		Climate_evap.radiation(site[:lat]).map.with_index{|v,i| site[:climate][i].merge!(v)}
		site[:climate] = Climate_evap.baier_robertson(site[:climate])
		# P-PE
		site[:PPE] = Climate_evap.ppe(site[:climate],yday("May 1"),yday("August 31")).round(1)
		# chu
		site[:chu_thresholds] = Climate_chu.thresholds(site[:lat], site[:long])
		site[:chu_start] = Climate_chu.startmonthly(site[:climate],yday("April 1"),site[:chu_thresholds][:start_temp])
		site[:chu_stop] = Climate_chu.stopmonthly(site[:climate],site[:chu_thresholds][:stop_temp])
		site[:climate] = Climate_chu.calculate(site[:climate],site[:chu_start],site[:chu_stop],"chu1")
		site[:CHU1] = site[:climate].map{|day| day[:chu1]}.compact.sum.round(0)
		site[:CHU2] = Climate_chu.ave(site[:CHU1],site[:chu_thresholds])
		# canhm
		site[:EGDD600] = Climate_canolaheat.egdd_sum(site[:climate],site[:EGDD_First],600)
		site[:EGDD1100] = Climate_canolaheat.egdd_sum(site[:climate],site[:EGDD_First],1100)
		if site[:EGDD1100] == nil then site[:TmaxEGDD] = 0 else
			site[:TmaxEGDD] = Climate_canolaheat.tmax_egdd(site[:climate],site[:EGDD600],site[:EGDD1100])
		end
		site[:CanHM] = Climate_canolaheat.canhm(site[:TmaxEGDD])
		return site
	end

	def Climate_calc.monthlies(normalsKey, indicesKey, indicesDumpPathname, redis)
		# calculates indices for all polygons in a polygonset, based on monthly normals
		# assumes raw climate data is available in Redis 
		for polygon in redis.hkeys(normalsKey) do
			redis.hset(indicesKey, polygon, Climate_calc.monthly(normalsKey, polygon, redis).except(:monthly, :climate, :lat, :long, :elev, :chu_thresholds).to_json)
		end
		# dump the hash to a file
		File.open(indicesDumpPathname,"w"){ |f| f << redis.dump(indicesKey) }
	end


	def Climate_calc.daily(params)
		# calculates and stores climate indices for a site based on daily climate data
		# site[:climate] is an array of 365 hashes
		dir = "/production/data/climate/stations/#{params[:station]}"
		site = JSON.parse(File.read("#{dir}/coordinates.json"),:symbolize_names => true)
		site[:climate] = CSV.read("#{dir}/daily/#{params[:daily]}.csv", headers:true, header_converters: :symbol, converters: :all, col_sep: "\t").map{|row| row.to_hash}
		site[:year] = params[:daily].to_i
		@year = site[:year] 
		# populate climate array with DAYNUMBER, TMEAN
		site[:climate].each_with_index{|v,i| v[:daynumber] = i+1}
		site[:climate].map{|v| v[:tmean] = ( v[:tmax] + v[:tmin] ) / 2}
		# GDD
		site.merge!(Climate_gdd.calc(site,5.0,1,365,params[:chu2springdays].to_i))
		# EGDD
		site.merge!(Climate_egdd.dailyrange(site[:climate],yday("April 1"),site[:GDD_First],yday("October 31")))
		site[:climate] = Climate_egdd.daily(site[:climate],site[:EGDD_First],site[:EGDD_Last],site[:lat])
		site[:EGDD] = site[:climate].map{|day| day[:egdd]}.compact.sum.round(0)
		# populate climate array with RADIATION, PE
		Climate_evap.radiation(site[:lat]).map.with_index{|v,i| site[:climate][i].merge!(v)}
		site[:climate] = Climate_evap.baier_robertson(site[:climate])
		# P-PE
		site[:PPE] = Climate_evap.ppe(site[:climate],yday("May 1"),yday("August 31")).round(1)
		# PPE cumulative
		site[:climate] = Climate_evap.ppe_cum(site[:climate],yday("May 1"),yday("August 31"))
		# PPE monthlies
		site[:PPE_April] = Climate_evap.ppe(site[:climate],yday("April 1"),yday("April 30")).round(1)
		site[:PPE_May] = Climate_evap.ppe(site[:climate],yday("May 1"),yday("May 31")).round(1)
		site[:PPE_June] = Climate_evap.ppe(site[:climate],yday("June 1"),yday("June 30")).round(1)
		site[:PPE_July] = Climate_evap.ppe(site[:climate],yday("July 1"),yday("July 31")).round(1)
		site[:PPE_August] = Climate_evap.ppe(site[:climate],yday("August 1"),yday("August 31")).round(1)
		site[:PPE_September] = Climate_evap.ppe(site[:climate],yday("September 1"),yday("September 30")).round(1)
		# ESM
		site[:ESM] = site[:PPE_May].round(0)
		# EFM
		site[:EFM] = site[:PPE_September].round(0)
		# CanolaHeatModel and 
		site[:CanHM] = Climate_canolaheat.daily(site[:climate],site[:EGDD_First],site[:EGDD_Last])
		# CHU
		site[:CHU_First] = Climate_chu.startstreak(site[:climate],yday("April 15"),12.8,3)
		site[:CHU_Last] = Climate_chu.stopmin(site[:climate],yday("October 15"),-2.0)
		site[:climate] = Climate_chu.calculate(site[:climate],site[:CHU_First],site[:CHU_Last],"chu1")
		site[:CHU1] = site[:climate].map{|day| day[:chu1]}.compact.sum.round(0)
		# CHU test2
		#site[:normals] = []
		site[:climate].map{|day| day[:tmaxArray] = [] }
		site[:climate].map{|day| day[:tminArray] = [] }
		for i in 0..9 do
			year = site[:year] - i
			if File.exist?("#{dir}/daily/#{year}.csv") then
				yearData = CSV.read("#{dir}/daily/#{year}.csv", headers:true, header_converters: :symbol, converters: :all, col_sep: "\t").map{|row| row.to_hash}
				yearData.map.with_index{|day,i| site[:climate][i][:tmaxArray].push(day[:tmax]); site[:climate][i][:tminArray].push(day[:tmin])}
			else
				#render "error_missingyear" and return and exit 1
				missingyear = true
			end
		end
		# populate climate with T10AVE, T10MIN
		if missingyear == true then
			site[:CHU2] = "ERROR: missing data required to calculate prior 10 year normals."
		else
			site[:climate] = Climate_calc.tenyearnormals(site[:climate])
			site[:CHU2_First] = Climate_chu.startmean(site[:climate],yday(params[:chu2springfirstday]),params[:chu2springtemp].to_f,params[:chu2springtemp10ave].to_f)
			site[:CHU2_Last] = Climate_chu.stopmean(site[:climate],yday(params[:chu2falllastday]),params[:chu2falltemp].to_f,params[:chu2falltemp10min].to_f,params[:chu2falltempmin].to_f)
			site[:climate] = Climate_chu.calculate(site[:climate],site[:CHU2_First],site[:CHU2_Last],"chu2")
			site[:CHU2] = site[:climate].map{|day| day[:chu2]}.compact.sum.round(0)
		end
		#File.open("#{dir}/daily/#{params[:daily]}_indices.json","w"){ |f| f << site.except(:monthly, :climate, :lat, :long, :elev, :chu_thresholds).to_json }
		File.open("#{dir}/daily/#{params[:daily]}_indices.json","w"){ |f| f << site.except(:climate, :lat, :long, :elev, :year, :normals).to_json }
		return site
	end

	def Climate_calc.dailies(params)
		# calculates and stores climate indices for a site for all years with daily climate data
#params = {:station=>"2101300", :daily=>"1951", :chu2springfirstday=>"April 15", :chu2springtemp=>"14.2", :chu2springdays=>"5", :chu2springtemp10ave=>"10", :chu2falltemp=>"10.1", :chu2falltempmin=>"-2", "chu2falltemp10min"=>"10", :chu2falllastday=>"October 15"}

Dir.chdir("/production/data/climate/stations/2101300/daily/")
# calculate the indices for each year
for year in Dir.glob("*.csv").sort.map{|filename| filename.split(".").first} do
puts year
params[:daily]=year
Climate_calc.daily(params)
end
# calculate the indices for each year
xx = Hash.new
for year in Dir.glob("*.csv").sort.map{|filename| filename.split(".").first} do
xx[year] = JSON.parse( File.read(year+"_indices.json") )  # TODO: turn these into symbols
# TODO: get rid of ErosivityRegion for each year.
end

# have to do all years because params can change, so this unless statement can't be used
#unless File.exists?("#{year}_indices.json") and File.mtime("#{year}.csv") < File.mtime("#{year}_indices.json") then 
#puts "Do calcs for #{year}"
#end
	end


	private

  def self.yday(monthday)
    "#{monthday}, #{@year}".to_date.yday
  end


end
