class Documentation5Controller < ApplicationController


  def Index
    render
  end

	def factor
		if VALID_CROPS.keys.include?(params[:crop]) then @crop = VALID_CROPS[params[:crop]]  end
		#@factor=VALID_FACTORS[params[:factor]]
		@factor=Definition.where(:name=>params[:factor]).first
		@data = eval("#{@crop[:name].capitalize}::#{@factor[:name].upcase}_DEDUCTIONS")
		#render "#{@factor[:category]}_#{@factor[:name]}"
	end

	def input
		@input = Definition.where(:name=>params[:name]).first
		render "/api/input.html.erb"
	end

end