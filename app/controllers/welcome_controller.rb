class WelcomeController < ApplicationController
	def save
    redirect_to show_attractions_path(destination: params[:destination].titleize, startdate: params[:startdate], enddate: params[:enddate])
	end
end
