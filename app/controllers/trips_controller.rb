class TripsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
  end

  def generate_itinerary

  end
end
