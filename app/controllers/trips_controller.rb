class TripsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
  end

  def generate_itinerary
    byebug
    @trip = Trip.new(:start_time => params[:startdate], :end_time => params[:enddate])
    @trip.save
    @itinerary = @trip.generate_itinerary(params[:destination])

  end

  def show_itinerary

  end

end
