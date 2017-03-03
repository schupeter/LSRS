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


	# prepares a valid request for the polygon_urls action
  def polygon_client
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
      @climateTables = LsrsClimate.where('PolygonTable like ? or PolygonTable like ?',@soilDataset.DSSClimatePolygonTable,@soilDataset.SLCClimatePolygonTable).order("Title_en")
      @crops = Lsrs_crop.all
    end
    render
  end

	# generates the LSRSv5 urls for a given polygon + climate + crop
	# first validates the input parameters, then gets component and climate data for the polygon
	def polygon_urls
		@rating = AccessorsRating.new
		Validate.polygon_urls(params, @rating)
		Polygon.get_data(@rating.polygon, @rating.climateData, @rating.errors)
		Polygon.get_ratings(@rating.crop, @rating.polygon, @rating.climateData.data, @rating.climate, @rating.errors)
		Polygon.aggregate_ratings(@rating.polygon.components, @rating.climate, @rating.aggregate)
		console
	end

  def Index
    render
  end
	
	def debug
		render "/home/debug.html"
	end
end
