class TripsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
  end

  def generate_itinerary

    #"please generate an itinerary for me according to this trip_id"
    @trip = Trip.find(params[:id])
    if @itinerary

    end
    @itinerary = @trip.generate_itinerary(@trip.city)
    render "show_itinerary"
  end

  def show_itinerary
    render "show_itinerary"
  end

  def new
    params[:destination] = params[:destination].titleize
    city = params[:destination]

    if !current_user #need to log in -> call something to login first then return back to this code

    end

    has_trip = false
    current_user.trips.each do |trip|
      if trip.city == city
        has_trip = true
        break
      end
    end

    if has_trip
      trip = current_user.trips.where(:city => city).first #making assumption this user only go to this city once
      saved = true
    else
      start_lst = params[:startdate].split("/")
      end_lst = params[:enddate].split("/")
      start_time = DateTime.new(start_lst[2].to_i, start_lst[0].to_i, start_lst[1].to_i, 0, 0, 0)
      end_time = DateTime.new(end_lst[2].to_i, end_lst[0].to_i, end_lst[1].to_i, 0, 0, 0)
      trip = Trip.new(city: city, start_time: start_time, end_time: end_time, :user_id => current_user.id)
      saved = trip.save
    end
    if saved && has_trip
      params.each do |key, value|
        if key.to_i.to_s == key
          trip.trip_attractions.where(:attraction_id => key).first.increment!(:vote_count, value.to_i)
        end
      end
      redirect_to generate_itinerary_path(trip.id)
    elsif saved && !has_trip
      #add in all the trip_attractions to this trip
      # byebug
      params.each do |key, value|
        # if (attraction_id != "destination" && attraction_id != "startdate" && attraction_id != "enddate")
        if key.to_i.to_s == key
          newTripAttraction = TripAttraction.new(attraction_id:key, trip_id:trip.id, vote_count:value)
          newTripAttraction.save
        end
      end
      redirect_to generate_itinerary_path(trip.id)
    else
      flash[:error] = "Start date cannot be later than end date."
      redirect_to root_path
    end
  end

  def delete
    Trip.destroy(params[:id])
    redirect_to user_show_path
  end
end
