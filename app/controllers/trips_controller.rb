class TripsController < ApplicationController

  # To access Devise view in this controller
  before_action :configure_permitted_parameters, :if => :devise_controller?

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  helper_method :resource, :resource_name, :devise_mapping
  # End devise


  def show
    @trip = Trip.find(params[:id])
  end

  def generate_itinerary(trip_id)
    #"please generate an itinerary for me according to this trip_id"
    @trip = Trip.find(trip_id)
    @itinerary = @trip.generate_itinerary(@trip.city)
    redirect_to show_itinerary_path(:trip_id => trip_id)
  end

  def show_itinerary
    @trip = Trip.find(params[:trip_id])
    @invitation_code = params[:invitation_code]
    if current_user
      is_owner = current_user.id == @trip.user_id
      is_contributor = !UserTrip.where(user_id: current_user.id, trip_id: @trip.id).blank?
      has_correct_invitation = @invitation_code == @trip.uuid
      if is_owner || is_contributor || has_correct_invitation
        # Has permission
        if !is_owner && !is_contributor && has_correct_invitation
          UserTrip.create(user_id: current_user.id, trip_id: @trip.id)
        end
        has_itinerary = false
        trip_attractions = @trip.trip_attractions
        trip_attractions.each do |trip_attraction|
          if trip_attraction.start_time != nil
            has_itinerary = true
            break
          end
        end
        if has_itinerary
          if !is_owner && !is_contributor
            trip_attractions.each do |trip_attraction|
              if !trip_attraction.attraction_id.nil? && !trip_attraction.lunch
                current_user.votes.create(trip_attraction: trip_attraction, attraction_id: trip_attraction.attraction_id, vote: 0)
              end
            end
          end
          @itinerary = TripAttraction.where(:trip_id => @trip.id).where.not(:start_time => nil).order(:start_time)
          render "show_itinerary"
        else
          generate_itinerary(params[:trip_id])
        end
      else
        # No permission
        if @invitation_code
          flash[:notice] = "Ooops! Your invitation code seems incorrect. Please double check the code with the owner."
        else
          flash[:notice] = "Ooops! Your account does not have permission to view this trip or itinerary. Please contact the owner of the trip to get a valid link to this page."
        end
        session[:previous_url] = request.fullpath
        render "no_permission"
      end
    else
      session[:previous_url] = request.fullpath
      flash[:notice] = "Ooops! You do not have permission to view this page. Please sign up or log in."
      render "devise/registrations/new"
    end
  end

  def new
    if !current_user # need to log in here
      session[:additional] = params
      redirect_to new_user_session_path
    else
      create_and_save_trip
    end
  end

  def create_and_save_trip
    params[:destination] = params[:destination].titleize
    city = params[:destination]

    has_trip = false
    @trip_id_list = []
    UserTrip.where(user_id: current_user.id).each do |user_trip|
      @trip_id_list.append(user_trip.trip_id)
    end
    @trips = Trip.where(id: @trip_id_list)
    @trips.each do |trip|
      if trip.city == city
        has_trip = true
        break
      end
    end
    if params[:startdate].include? "/"
      start_lst = params[:startdate].split("/")
      end_lst = params[:enddate].split("/")
      start_time = DateTime.new(start_lst[2].to_i, start_lst[0].to_i, start_lst[1].to_i, 0, 0, 0)
      end_time = DateTime.new(end_lst[2].to_i, end_lst[0].to_i, end_lst[1].to_i, 0, 0, 0)
    else
      start_lst = params[:startdate].split("-")
      end_lst = params[:enddate].split("-")
      start_time = DateTime.new(start_lst[0].to_i, start_lst[1].to_i, start_lst[2].split(" ")[0].to_i, 0, 0, 0)
      end_time = DateTime.new(end_lst[0].to_i, end_lst[1].to_i, end_lst[2].split(" ")[0].to_i, 0, 0, 0)
    end
    if has_trip
      trip = @trips.where(:city => city).first #making assumption this user only go to this city once
      trip.update_attributes(:start_time => start_time, :end_time => end_time)
      saved = trip.save
    else
      trip = Trip.new(city: city, start_time: start_time, end_time: end_time, user_id: current_user.id, uuid: SecureRandom.uuid)
      saved = trip.save
    end
    if saved
      UserTrip.create(user_id: current_user.id, trip_id: trip.id)
      if has_trip
        params.each do |key, value|
          if key.to_i.to_s == key
            trip_attraction = trip.trip_attractions.where(:attraction_id => key).first
            user_vote = current_user.votes.where(trip_attraction_id: trip_attraction.id).first
            vote_diff = value.to_i - user_vote.vote
            user_vote.increment!(:vote, by = vote_diff)
            trip_attraction.increment!(:vote_count, by = vote_diff)
          end
        end
        generate_itinerary(trip.id)
      else
        #add in all the trip_attractions to this trip
        # byebug
        params.each do |key, value|
          # if (attraction_id != "destination" && attraction_id != "startdate" && attraction_id != "enddate")
          if key.to_i.to_s == key
            newTripAttraction = TripAttraction.create(attraction_id: key, trip_id: trip.id, vote_count: value)
            current_user.votes.create(trip_attraction: newTripAttraction, attraction_id: key, vote: value)
          end
        end
        generate_itinerary(trip.id)
      end
    end
  end

  def delete
    Trip.destroy(params[:id])
    redirect_to user_show_path
  end
end