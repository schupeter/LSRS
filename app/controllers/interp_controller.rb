class InterpController < ApplicationController

  def list_sectors
		@sectors = Interpretation.sectors
  end

	def list_interpretations
		@interpretations = Interpretation.find_all_by_sector(params[:sector])
	end

	def describe_interpretation
		@value_factors = Ratingvalue.value_factors(params[:sector],params[:interpretation])
		@range_factors = Ratingrange.range_factors(params[:sector],params[:interpretation])
	end

	def interpret
		@value_factors = Ratingvalue.value_factors(params[:sector],params[:interpretation])
		@range_factors = Ratingrange.range_factors(params[:sector],params[:interpretation])
	end

def test
params={:sector=>"Agriculture", :interpretation=>"APPLES"}
@value_factors = Ratingvalue.value_factors(params[:sector],params[:interpretation])
@range_factors = Ratingrange.range_factors(params[:sector],params[:interpretation])
@cmp = Dss_v3_ns_cmp.find_by_cmp_id("NSD00100000401")
@name = "Soil_name_#{@cmp.province.downcase}_v2".constantize.find_by_soil_id(@cmp.soil_id)
@layers = "Soil_layer_#{@cmp.province.downcase}_v2".constantize.find_all_by_soil_id(@cmp.soil_id)

@interpretations = Hash.new
factor = @value_factors.keys[2]
@interpretations[factor] = @value_factors[factor][:ratings][@cmp.send(@value_factors[factor][:method])]
@interpretations[factor] = @value_factors[factor][:ratings][eval("@#{@value_factors[factor][:table]}.#{@value_factors[factor][:method]}")]
# above works, so below should work if table were populated.
for factor in @value_factors.keys do
@interpretations[factor] = @value_factors[factor][:ratings][eval("@#{@value_factors[factor][:table]}.#{@value_factors[factor][:method]}")]
end
end

def test_lookups
	# build some sample data
	params = {:sector=>"Agriculture",:interpretation=>"Alfalfa"}
	INTERPS["Agriculture"]["Alfalfa"] = Ratingvalue.value_factors(params[:sector],params[:interpretation])
	# show data
	INTERPS["Agriculture"]["Alfalfa"]["Drainage"][:ratings]
	
	# EXAMPLE using send to dynamically define a method name
	Soil_name_nb_v2.first.drainage
	Soil_name_nb_v2.first.send("drainage")
	# EXAMPLE use constantize to do polymorphic associations
	"Soil_name_nb_v2".constantize.first.drainage
	# can even create a new generic name for an existing ActiveRecord object
	Tablename = "Soil_name_nb_v2".constantize
	Tablename.first.drainage
	# 
	INTERPS["Agriculture"]["Alfalfa"]["Drainage"][:ratings][Soil_name_nb_v2.first.drainage]
	factor = "drainage"
	INTERPS["Agriculture"]["Alfalfa"][factor.capitalize][:ratings][Soil_name_nb_v2.first.send(factor)]
	factors = ["drainage","drainage"]
end

end
