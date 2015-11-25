require 'rails_helper'

RSpec.describe TripsController, type: :controller do
  before(:all) do
    @fake_api_response = File.read('spec/data/fake_api.json')
    @fake_hours_response = File.read('spec/data/sample_hours.json')
    @taipei_response = File.read('spec/data/import_taipei.json')
    @taipei_hours = File.read('spec/data/taipei_hours.json')
  end

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
      post :new, :destination => "San Francisco", :startdate => "11/16/2015", :enddate => "11/18/2015",
      "1"=>"0", "2"=>"0", "3"=>"0"
      #, "4"=>"0", "5"=>"0", "6"=>"0", "7"=>"0", "8"=>"0", "9"=>"0", "10"=>"0",
      # "11"=>"0", "12"=>"0", "13"=>"0", "14"=>"0", "15"=>"0", "16"=>"0", "17"=>"0", "18"=>"0", "19"=>"0", "20"=>"0",
      # "21"=>"0", "22"=>"0", "23"=>"0", "24"=>"0", "25"=>"0", "26"=>"0", "27"=>"0", "28"=>"0", "29"=>"0", "30"=>"0",
      # "31"=>"0", "32"=>"0", "33"=>"0", "34"=>"0", "35"=>"0", "36"=>"0", "37"=>"0", "38"=>"0", "39"=>"0", "40"=>"0",
      # "41"=>"0", "42"=>"0", "43"=>"0", "44"=>"0", "45"=>"0", "46"=>"0", "47"=>"0", "48"=>"0", "49"=>"0", "50"=>"0"
      expect(Trip.count).to eq 1
      expect(TripAttraction.count).to eq 3
    end
  end

  context "generate itinerary" do

    before do
      Foursquare.should_receive(:import_attractions).and_return(@taipei_response)
      Foursquare.should_receive(:import_hours).at_most(20).times.and_return(@taipei_hours)
      Attraction.import_foursquare_attractions("Taipei", 20)
    end

    it "test number of trip attractions in itinerary" do
      start_id = Attraction.first.id
      post :new, :destination => "Taipei", :startdate => "11/02/2015", :enddate => "11/03/2015",
           start_id.to_s =>"0", (start_id+1).to_s=>"0", (start_id+2).to_s=>"0", (start_id+3).to_s=>"0", (start_id+4).to_s=>"0", (start_id+5).to_s=>"0", (start_id+6).to_s=>"0", (start_id+7).to_s=>"0", (start_id+8).to_s=>"0"
      trip = Trip.find_by_city("Taipei")
      post :generate_itinerary, :id => trip.id
      trip_attractions = TripAttraction.where.not(end_time: nil)
      expect(trip_attractions.length).to eq(8)
    end
  end
end
