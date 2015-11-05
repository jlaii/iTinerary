class TripsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
  end

  def generate_itinerary
    @trip = Trip.new()
    @trip.save
    @itinerary = @trip.generate_itinerary

  end

end
