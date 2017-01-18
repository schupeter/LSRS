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



# OBSOLETE because these are now separate services.
	def potato
		@test = Initialize.parameters(params)
		@soilHash = {}
		@soilHash.store("province", "ON")
		@soilHash.store("soil_code", "BSB")
		@soilHash.store("modifier", "~~~~~")
		@soilHash.store("profile", "A")
		@nameRecords = Soil_name_on_v2.where(@soilHash)
		@crop = Potato.calculate
		render "test"
	end
	

  def Index
    render
  end
	
	def debug
		render "/home/debug.html"
	end
end
