 # Alfalfa
=begin
#these are obsolete, but indicate how the problem with GDD was fixed.

	# temperature is kind of messed up.  Tony's doc has some inconsistencies, but they are mostly easy to fix
	# should take the time to fix the documentation along with writing this new code.
	
	# Tony's methodology doc (first and last are not from the table)
GDD_DEDUCT_ALFALFA_FROM_TABLE = [
{:value=>0, :deduction=>100},
{:value=>480, :deduction=>80},
{:value=>930, :deduction=>70},
{:value=>1410, :deduction=>50},
{:value=>1890, :deduction=>20},
{:value=>2100, :deduction=>0},
]
Calculate.interpolate(1264, GDD_DEDUCT_ALFALFA_FROM_TABLE)
	
	# formula from LSRS 4.0
	GDD_DEDUCT_ALFALFA_FROM_FORMULA = [ [450, 90], [480, 89], [930, 81], [1410, 67], [1890, 45], [2600, 0] ].to_h

Actual current formula yields:
HF1a = 89.02
HF1b = -0.0067
HF1c = -0.000016
=end
class Gdd
def Gdd.calc(gdd)
hf1a = 89.02
hf1b = -0.0067
hf1c = -0.000016
hf1a + ( hf1b * gdd ) + ( hf1c * gdd ** 2 )
end
end
Gdd.calc(570) #80.00
Gdd.calc(900) # 70.03
Gdd.calc(1264) # 55.01
Gdd.calc(1366) # 50.01
Gdd.calc(1878) # 20.01
Gdd.calc(2158) # 0.05

# Brome
class Gdd
def Gdd.calc(gdd)
hf1a = 89.28
hf1b = -0.0085
hf1c = -0.000016
hf1a + ( hf1b * gdd ) + ( hf1c * gdd ** 2 )
end
end
Gdd.calc(0)
Gdd.calc(541)
Gdd.calc(864)
Gdd.calc(1324)
Gdd.calc(1832)
Gdd.calc(2111) 
