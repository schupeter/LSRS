class Brome

# deduction values (all values must be in ascending order)
PPE_DEDUCTIONS = [
{:value=>-650, :deduction=>100},
{:value=>-500, :deduction=>70, :rating=>["dryland farming is severely restricted","this is the driest area in Canada","considered a very severe moisture limitation","Class 4-5 boundary"]},
{:value=>-400, :deduction=>50, :rating=>["near the point where one major crop (barley) becomes a minor part of the cropping system","considered a moderate moisture limitation","Class 3"]},
{:value=>-300, :deduction=>30, :rating=>["corresponds roughly to the Grassland-Parkland boundary","Class 2"]},
{:value=>-150, :deduction=>0}
]

GDD_DEDUCTIONS = [
{:value=>0, :deduction=>100},
{:value=>480, :deduction=>80, :rating=>["Class 5-6 boundary"]},
{:value=>880, :deduction=>70, :rating=>["Class 4-5 boundary"]},
{:value=>1360, :deduction=>55, :rating=>["Class 3-4 boundary"]},
{:value=>1840, :deduction=>20, :rating=>["Class 1-2 boundary"]},
{:value=>2100, :deduction=>0}
]

GSL_DEDUCTIONS = [
{:value=>0, :deduction=>100},
{:value=>65, :deduction=>80, :rating=>["supports a single cut, with no carryover","Class 5-6 boundary"]},
{:value=>120, :deduction=>70, :rating=>["supports a single cut, with no carryover","Class 4-5 boundary"]},
{:value=>175, :deduction=>50, :rating=>["supports two cuts per year","Class 3-4 boundary"]},
{:value=>230, :deduction=>20, :rating=>["supports three cuts per year","Class 1-2 boundary"]},
{:value=>260, :deduction=>0}
]

ESM_DEDUCTIONS = [ 
	{:value=>-50, :deduction=>0}, 
	{:value=>50, :deduction=>10}
]

EFM_DEDUCTIONS = [ 
	{:value=>0, :deduction=>0}, 
	{:value=>100, :deduction=>10}
]

SURFACESALINITY_DEDUCTIONS = [
	{:value=>2, :deduction=>0},
	{:value=>4, :deduction=>20},
	{:value=>8, :deduction=>50},
	{:value=>16, :deduction=>90},
	{:value=>18, :deduction=>100}
]

SUBSURFACESALINITY_DEDUCTIONS = [
	{:value=>0, :deduction=>0},
	{:value=>4, :deduction=>10},
	{:value=>8, :deduction=>20},
	{:value=>12, :deduction=>40},
	{:value=>16, :deduction=>70}
]

	def Brome.rate_climate(params, climate)
		# aridity
		climate.aridity = Assess_climate.aridity(climate.PPE, PPE_DEDUCTIONS)
		# heat
		climate.heat = Assess_climate.gdd_gsl(climate.GDD, GDD_DEDUCTIONS, climate.GSL, GSL_DEDUCTIONS)
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
