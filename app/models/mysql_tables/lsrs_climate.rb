class LsrsClimate < ActiveRecord::Base
  self.table_name="lsrs_configuration.lsrs_climates"

=begin
	def WarehouseName
		n = self.FrameworkURI.split("/")
		if n[5] == "slc" and n[8] == nil then
			return "#{n[5]}_#{n[6]}_canada_climate#{self.scenario}"
		else
			return "#{n[5]}_#{n[6]}_#{n[8]}#{n[9]}_climate#{self.scenario}"
		end
	end

	def PolygonTable
		n = self.FrameworkURI.split("/")
		if n[5] == "slc" and n[8] == nil then
			return "#{n[5]}_#{n[6]}_canada_pat"
		else
			return "#{n[5]}_#{n[6]}_#{n[8]}#{n[9]}_pat"
		end
	end
=end
end
