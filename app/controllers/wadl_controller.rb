class WadlController < ApplicationController

	def WADL
		@application = Webapplication.where(:name=>params[:service]).first
		render :action => 'WADL.xml.builder'
	end
	
end
