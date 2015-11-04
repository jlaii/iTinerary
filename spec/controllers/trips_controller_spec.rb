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

  context "test travel time from San Francisco to Berkeley" do
    attraction_start = Attraction.new # San Francisco
    attraction_start.latitude = 37.7833
    attraction_start.longitude = 122.4167
    attraction_end = Attraction.new # Berkeley
    attraction_end.latitude = 37.8717
    attraction_end.longitude = 122.2728
    it "calculates euclidean distance" do
      expect(Trip.calculate_distance_euclidean(attraction_start, attraction_end).round(3)).to eq(16.011)
    end

    it "calculates euclidean travel time" do
      expect(Trip.calculate_travel_time_euclidean(attraction_start, attraction_end, 30).round(0)).to eq(32)
    end

    it "calculates manhattan distance" do
      expect(Trip.calculate_distance_manhattan(attraction_start, attraction_end).round(3)).to eq(22.468)
    end

    it "calculates manhattan travel time" do
      expect(Trip.calculate_travel_time_manhattan(attraction_start, attraction_end, 30).round(0)).to eq(45)
    end

    it "calculates euclidean travel time to itself" do
      expect(Trip.calculate_travel_time_euclidean(attraction_start, attraction_start, 30).round(0)).to eq(0)
    end

    it "calculates manhattan travel time to itself" do
      expect(Trip.calculate_travel_time_manhattan(attraction_start, attraction_start, 30).round(0)).to eq(0)
    end
  end
end
