class WelcomeController < ApplicationController
	def save
    params[:destination] = params[:destination].titleize
		name = params[:destination]
    start_lst = params[:startdate].split("/")
    end_lst = params[:enddate].split("/")
    start_time = DateTime.new(start_lst[2].to_i, start_lst[0].to_i, start_lst[1].to_i)
    end_time = DateTime.new(end_lst[2].to_i, end_lst[0].to_i, end_lst[1].to_i)

    newTrip = Trip.new(name: name, start_time: start_time, end_time: end_time)
    newTrip.save

		redirect_to show_attractions_path(params)
	end
end
