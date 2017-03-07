class AccessorsSite
  attr_accessor :climate, :soil, :landscape, :crop, :cmp_id, :percent, :slope, :length, :stoniness, :errors
	def initialize
		self.climate = AccessorsClimate.new
		self.soil = AccessorsSoil.new
		self.landscape = AccessorsLandscape.new
		self.errors = []
	end
end