class Potato

TBD_DEDUCTIONS=>{
:chu=>[[1200, 90], [2000, 70], [2300, 55], [2700, 40], [3500, 0]],
:ph=>[[4.3, 90], [4.4, 70], [4.5,30], [4.8, 10], [5.2, 0], [5.5, 0], [6.0,30], [6.8, 50], [7.0, 60], [7.5, 90]],
:root_restri=>[[10, 100], [40, 90], [50, 60], [70, 20], [100, 0]],
:surfaceSalinity=>[[0, 0], [1, 5], [3, 50], [7, 90], [10, 100]],
:subsurfaceSalinity=>[[0, 0], [4, 10], [8, 20], [12, 40], [16, 70]] 
}


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

	def Potato.calculate
		crop = {}
		crop[:surfaceSalinity] = Calculate.lookup(8, POTATO[:surfaceSalinity])
		crop[:chu] = Calculate.lookup(1200, POTATO[:chu])
		return crop
	end

end 
