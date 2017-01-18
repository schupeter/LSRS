class LsrsCmp < ActiveRecord::Base
  self.table_name="lsrs_configuration.lsrs_cmps"

	def FrameworkName
		self.WarehouseName[0..-5]
	end

end
