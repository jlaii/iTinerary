require 'rails_helper'

RSpec.describe TripsController, type: :controller do
  before(:context) do
    @trip = Trip.create(city:'New York')
  end
  after(:context) do
    @trip.delete
  end

  it "gets the trip" do
    get :show, :id => @trip.id
    expect(response.status).to eq 200
  end

  context "GET #show" do
    subject { get :show, :id => @trip.id}

    it "renders the show template" do
      expect(subject).to render_template(:show)
      expect(subject).to render_template("show")
      expect(subject).to render_template("trips/show")
    end
  end

  context "get next attraction" do
    it "from highest votes" do
      Attraction.delete_all
      TripAttraction.delete_all
      attraction_names = ["Louise M. Davies Symphony Hall", "Asian Art Museum", "Yerba Buena Gardens", "Huntington Park", "Corona Heights Park"]
      trip_attractions = []
      for i in 0...5
        Attraction.create(id: i+1, name: attraction_names[i], latitude: 30, longitude: 30, rating: 10)
        trip_attractions.append(TripAttraction.new(id: i+1, trip_id: 1, attraction_id: i+1, vote_count: i))
      end
      prev_attraction = Attraction.new(id: 6, name: "prev_attraction", latitude: 30, longitude: 30, rating: 10)
      trip = Trip.new
      start_time = DateTime.now.change({hour: 8})
      result = trip.get_next_trip_attraction(prev_attraction, trip_attractions, start_time)[:trip_attraction]
      # byebug
      # post :get_next_trip_attraction, :prev_attraction => prev_attraction
      expect(Attraction.find(result.attraction_id).name).to eq("Corona Heights Park")
    end
  end
end
