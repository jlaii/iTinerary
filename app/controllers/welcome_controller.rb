class WelcomeController < ApplicationController
	def save
		name = params[:name]
	    start_lst = params[:startdate].split("/")
	    end_lst = params[:enddate].split("/")
	    start_time = DateTime.new(start_lst[2].to_i, start_lst[0].to_i, start_lst[1].to_i)
	    end_time = DateTime.new(end_lst[2].to_i, end_lst[0].to_i, end_lst[1].to_i)

	    newTrip = Trip.new(name: name, start_time: start_time, end_time: end_time)
	    newTrip.save

		redirect_to attractions_path
	end
end
