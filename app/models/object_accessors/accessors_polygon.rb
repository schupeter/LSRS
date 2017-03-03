class AccessorsPolygon
  attr_accessor :poly_id, 
	:frameworkName, 
	:cmpTableName, 
	:cmpTableMetadata, 
	:cmpType,
	:databaseTitle, 
	:prtRecord,
	:landscape_id,
	:climate_id,
	:erosivity_region,
	:cmpData,
	:components
	def initialize
		self.components = []
	end
end
