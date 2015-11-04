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

  context "test travel time" do
    attraction_start = Attraction.new
    attraction_start.latitude = 37.7833
    attraction_start.longitude = 122.4167
    attraction_end = Attraction.new
    attraction_end.latitude = 37.8717
    attraction_end.longitude = 122.2728
    it "calculates distance" do
      expect(Trip.calculate_distance(attraction_start, attraction_end).round(2)).to eq(16.01)
    end

    it "calculates travel time" do
      expect(Trip.calculate_travel_time(attraction_start, attraction_end, 30).round(2)).to eq(32.02)
    end

  end
end
