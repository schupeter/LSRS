class AccessorsRating
  attr_accessor :crop, 
	:polygon, 
	:climateData,
	:climate,
	:management, 
	:responseForm, 
	:errors
	def initialize
		self.polygon = AccessorsPolygon.new
		self.climateData = AccessorsPolygonclimate.new
		self.climate = AccessorsClimate.new
		self.errors = []
	end
end