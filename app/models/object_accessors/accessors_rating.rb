class AccessorsRating
  attr_accessor :crop, 
	:polygon, 
	:climate, 
	:management, 
	:responseForm, 
	:errors
	def initialize
		self.polygon = AccessorsPolygon.new
		self.climate = AccessorsPolygonclimate.new
		self.errors = []
	end
end