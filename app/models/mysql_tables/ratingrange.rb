class Ratingrange < ActiveRecord::Base
  self.table_name="suitability.rating_ranges"

	def self.factors(sector,interpretation)
		self.select(:factor).where("sector = ? and interpretation = ?",sector,interpretation).group(:factor).map{|x| x.factor }
	end

	def self.values(sector,interpretation,factor)
		self.where("sector = ? and interpretation = ? and factor = ?",sector,interpretation,factor).order(:min_value).each_with_object(Array.new){|x,array| array.push(x) }
	end

	def self.range_factors(sector,interpretation)
		range_factors = Hash.new
		for factor in self.factors(sector,interpretation) do
			range_factors[factor] = self.values(sector,interpretation,factor)
		end
		return range_factors
	end

end
