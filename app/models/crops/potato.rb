class Potato

	def Potato.calculate
		crop = {}
		crop[:surfaceSalinity] = Calculate.lookup(8, POTATO[:surfaceSalinity])
		crop[:chu] = Calculate.lookup(1200, POTATO[:chu])
		return crop
	end

end 
