class Documentation5Controller < ApplicationController


  def Index
    render
  end

	def factor2
		if VALID_CROPS.keys.include?(params[:crop]) then @crop = VALID_CROPS[params[:crop]]  end
		@factor=Definition.where(:name=>params[:factor]).first
		@data = eval("#{@crop[:name].capitalize}::#{@factor[:name].upcase}_DEDUCTIONS")
	end

	def factorCropSpecificWithChart
		if VALID_CROPS.keys.include?(params[:crop]) then @crop = VALID_CROPS[params[:crop]]  end
		@factor=Definition.where(:name=>params[:factor]).first
		@data = eval("#{@crop[:name].capitalize}::#{@factor[:name].upcase}_DEDUCTIONS")
	end


	def input
		@input = Definition.where(:name=>params[:name]).first
		render "/api/input.html.erb"
	end

end