class Ratingvalue < ActiveRecord::Base
  self.table_name="suitability.rating_values"

	def self.factors(sector,interpretation)
		self.select(:factor).where("sector = ? and interpretation = ?",sector,interpretation).group(:factor).map{|x| x.factor }
	end

	def self.values(sector,interpretation,factor)
		self.where("sector = ? and interpretation = ? and factor = ?",sector,interpretation,factor).order(:rating,:lookup_value).each_with_object(Hash.new){|x,hash| hash[x.lookup_value] = x.rating }
	end

	def self.value_factors(sector,interpretation)
		value_factors = Hash.new
		for factor in self.factors(sector,interpretation) do
			value_factors[factor] = Hash.new
			factor_definition = Factordefinition.find_by_factor(factor)
			value_factors[factor][:table] = factor_definition.db_table
			value_factors[factor][:method] = factor_definition.db_method
			value_factors[factor][:ratings] = self.values(sector,interpretation,factor)
		end
		return value_factors
	end

end
