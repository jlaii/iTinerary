require 'rails_helper'

RSpec.describe TripsController, type: :controller do
  before :each do
    sign_out :user
  end
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
    attraction_start1 = Attraction.new # San Francisco city center
    attraction_start1.latitude = 37.77493
    attraction_start1.longitude = -122.41942
    attraction_end1 = Attraction.new # Asian Art Museum
    attraction_end1.latitude = 37.7802804660325
    attraction_end1.longitude = -122.416089177132

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

    it "calculates manhattan travel time to itself" do
      expect(Trip.calculate_travel_time_manhattan(attraction_start1, attraction_end1, 30).round(0)).to eq(2)
    end
  end

  context "generating a trip" do
    before(:context) do
      TripAttraction.delete_all
      Attraction.delete_all
      Trip.delete_all
    end
    after(:context) do
      TripAttraction.delete_all
      Attraction.delete_all
      Trip.delete_all
    end

    it "generate trip and trip attractions" do
      city = City.new(:name => "San Francisco", :lat => 37.7833, :lng => 122.4167)
      city.save
      attraction1 = Attraction.new(:id => 1, :name => "park", :city => "San Francisco",
        :latitude => 22.27769953093909, :longitude => 114.16185379028319, :rating => 9.5)
      attraction1.save
      attraction2 = Attraction.new(:id => 2, :name => "theater", :city => "San Francisco",
        :latitude => 22.27769953093909, :longitude => 114.16185379028319, :rating => 9.5)
      attraction2.save
      attraction3 = Attraction.new(:id => 3, :name => "exploritorium", :city => "San Francisco",
        :latitude => 22.27769953093909, :longitude => 114.16185379028319, :rating => 9.5)
      attraction3.save
      expect(Trip.count).to eq 0
      expect(TripAttraction.count).to eq 0
      post :new, :destination => "San Francisco", :startdate => "2015-11-06T00:00:00+00:00", :enddate => "2015-11-10T00:00:00+00:00", 
      "1"=>"0", "2"=>"0", "3"=>"0"
      #, "4"=>"0", "5"=>"0", "6"=>"0", "7"=>"0", "8"=>"0", "9"=>"0", "10"=>"0",
      # "11"=>"0", "12"=>"0", "13"=>"0", "14"=>"0", "15"=>"0", "16"=>"0", "17"=>"0", "18"=>"0", "19"=>"0", "20"=>"0",
      # "21"=>"0", "22"=>"0", "23"=>"0", "24"=>"0", "25"=>"0", "26"=>"0", "27"=>"0", "28"=>"0", "29"=>"0", "30"=>"0",
      # "31"=>"0", "32"=>"0", "33"=>"0", "34"=>"0", "35"=>"0", "36"=>"0", "37"=>"0", "38"=>"0", "39"=>"0", "40"=>"0",
      # "41"=>"0", "42"=>"0", "43"=>"0", "44"=>"0", "45"=>"0", "46"=>"0", "47"=>"0", "48"=>"0", "49"=>"0", "50"=>"0"
      expect(Trip.count).to eq 1
      expect(TripAttraction.count).to eq 3
      trip = Trip.find_by_city("San Francisco")
      post :generate_itinerary, :id => trip.id
    end
  end
end
