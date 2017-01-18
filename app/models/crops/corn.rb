class Corn

# deduction values (all values must be in ascending order)
PPE_DEDUCTIONS = [
{:value=>-550, :deduction=>100},
{:value=>-400, :deduction=>70, :rating=>["Brown soil zone","considered a very severe moisture limitation","Class 4-5 boundary"]},
{:value=>-250, :deduction=>40, :rating=>["Winnipeg, Ottawa","considered a moderate moisture limitation","Class 2-3 boundary"]},
{:value=>-150, :deduction=>20, :rating=>["Class 1-2 boundary"]},
{:value=>-50, :deduction=>0}
]

CHU_DEDUCTIONS = [
{:value=>1200, :deduction=>90, :rating=>["Class 6-7 boundary"]}, 
{:value=>1700, :deduction=>80, :rating=>["Class 5-6 boundary"]}, 
{:value=>2000, :deduction=>70, :rating=>["present economic limit for corn production","Class 4-5 boundary"]}, 
{:value=>2300, :deduction=>55, :rating=>["Class 3-4 boundary"]}, 
{:value=>2700, :deduction=>40, :rating=>["a moderate limitation (Guelph and Ottawa c. 2010)", "Class 2-3 boundary"]}, 
{:value=>3500, :deduction=>0, :rating=>["no limitation"]}, 
]

ESM_DEDUCTIONS = [ 
	{:value=>-50, :deduction=>0}, 
	{:value=>50, :deduction=>10}
]

EFM_DEDUCTIONS = [ 
	{:value=>0, :deduction=>0}, 
	{:value=>100, :deduction=>10}
]

	def Corn.rate_climate(params, climate)
		# aridity
		climate.aridity = Assess_climate.aridity(climate.PPE, PPE_DEDUCTIONS)
		# heat
		climate.heat = Assess_climate.chu(climate.CHU, CHU_DEDUCTIONS)
		# basic
		climate.basic_rating = [climate.aridity.Rating, climate.heat.Rating].min
		# modifiers
		climate.modifiers = AccessorsClimateModifiers.new
		climate.modifiers.m1 = Assess_climate.esm(climate.ESM, ESM_DEDUCTIONS)
		climate.modifiers.m2 = Assess_climate.efm(climate.EFM, EFM_DEDUCTIONS)
		climate.modifiers.total_percent = climate.modifiers.m1 + climate.modifiers.m2
		climate.modifiers.deduction = climate.basic_rating * climate.modifiers.total_percent / 100
		# final
		climate.final_rating = climate.basic_rating - climate.modifiers.deduction
		climate.suitability = Calculate.rating(climate.final_rating)
	end

end
