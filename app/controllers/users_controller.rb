class UsersController < ApplicationController
  def new
  end

  def create
  end

  def show
    begin
      @user = User.find(current_user.id)
      @trip_id_list = []
      UserTrip.where(user_id: current_user.id).each do |user_trip|
        @trip_id_list.append(user_trip.trip_id)
      end
      @trips = Trip.where(id: @trip_id_list)
    rescue
      flash[:error] = "User not logged in."
      redirect_to(root_path)
    end
  end
end
