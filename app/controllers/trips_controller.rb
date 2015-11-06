class TripsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
  end

  def generate_itinerary

    #"please generate an itinerary for me according to this trip_id"
    @trip = Trip.find(params[:id])
    @itinerary = @trip.generate_itinerary(@trip.city)
    render "show_itinerary"
  end

  def show_itinerary
    render "show_itinerary"
  end

  def new
    params[:destination] = params[:destination].titleize
    city = params[:destination]
    start_lst = params[:startdate].split("/")
    end_lst = params[:enddate].split("/")
    start_time = DateTime.iso8601(params[:startdate])
    end_time = DateTime.iso8601(params[:enddate])

    newTrip = Trip.new(city: city, start_time: start_time, end_time: end_time)
    if current_user
      newTrip.update_attributes(:user_id => current_user.id)
    end
    saved = newTrip.save
    if saved
      #add in all the trip_attractions to this trip
      # byebug
      params.each do |key, value|
        # if (attraction_id != "destination" && attraction_id != "startdate" && attraction_id != "enddate")
        if key.to_i.to_s == key
          newTripAttraction = TripAttraction.new(attraction_id:key, trip_id:newTrip.id, vote_count:value)
          newTripAttraction.save
        end
      end

      redirect_to trip_show_path(:id => newTrip.id)
    else
      flash[:error] = "Start date cannot be later than end date."
      redirect_to root_path
    end
  end
end
