class AccessorsPolygonbatch
  attr_accessor :crop, 
	:cropHash,
	:frameworkName, 
	:framework, 
	:cmpTableName, 
	:fromPoly,
	:toPoly,
	:polyArray,
	:region,
	:view,
	:climateTableName,
	:management,
	:timeStamp,
	:dir,
	:url,
	:host,
	:statusFilename,
	:statusURL,
	:outputURL,
	:errors
	def initialize
		self.cropHash = {}
		self.errors = []
	end
end
