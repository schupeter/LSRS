class Climate_erosivity

	def Climate_erosivity.identify_erosivityregion(ecoprovince) 
		if ["4.1", "10.1", "10.2", "10.3", "11.4", "12.2", "12.3", "14.1", "14.4", "4.3", "9.1", "9.2"].include?(ecoprovince) then
			2
		else
			1
		end
	end

end
