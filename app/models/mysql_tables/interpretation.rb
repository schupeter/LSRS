class Interpretation < ActiveRecord::Base
  self.table_name="suitability.interpretations"

	def self.sectors
		self.select(:sector).group(:sector).map{|x| x.sector}
	end

	def self.interpretations(sector)
		self.where(:sector=>sector).map{|x| x.title_en}
	end

end
