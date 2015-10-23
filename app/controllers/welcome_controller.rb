class WelcomeController < ApplicationController
	def save
    	params[:destination] = params[:destination].titleize
		city = params[:destination]
    	start_lst = params[:startdate].split("/")
    	end_lst = params[:enddate].split("/")
    	start_time = DateTime.new(start_lst[2].to_i, start_lst[0].to_i, start_lst[1].to_i)
    	end_time = DateTime.new(end_lst[2].to_i, end_lst[0].to_i, end_lst[1].to_i)

    	newTrip = Trip.new(city: city, start_time: start_time, end_time: end_time)
    	saved = newTrip.save

    	if saved
    		redirect_to show_attractions_path(destination: city, startdate: start_time, enddate: end_time)
    	else
    		flash[:error] = "Start date cannot be later than end date."
    		redirect_to root_path
    	end
	end
end
