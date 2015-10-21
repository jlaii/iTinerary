class WelcomeController < ApplicationController
	def save
		name = params[:name]
		#TODO: transform start/end date to DateTime
	    start_time = params[:startdate]
	    end_time = params[:enddate]

	    newTrip = Trip.new(name: name, start_time: start_time, end_time: end_time)
	    newTrip.save
	    
		redirect_to attractions_path
	end
end
