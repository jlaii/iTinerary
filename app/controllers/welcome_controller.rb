class WelcomeController < ApplicationController
	def save
		startdate = DateTime.strptime(params[:startdate], '%m/%d/%Y')
		enddate = DateTime.strptime(params[:enddate], '%m/%d/%Y')
		if startdate > enddate
			flash[:error] = "Start date cannot be later than end date."
    		redirect_to root_path
    	else
    		redirect_to show_attractions_path(destination: params[:destination].titleize, startdate: params[:startdate], enddate: params[:enddate])
		end
	end
end
