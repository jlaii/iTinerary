class UsersController < ApplicationController
  def new
  end

  def create
  end

  def show
    @trip_id_list = []
    UserTrip.where(user_id: current_user.id).each do |user_trip|
      @trip_id_list.append(user_trip.trip_id)
    end
    @trips = Trip.where(id: @trip_id_list)
  end
end
