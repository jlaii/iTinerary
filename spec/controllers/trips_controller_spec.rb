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
    @trip = Trip.create(city:'New York', :uuid => SecureRandom.uuid)
  end
  after(:context) do
    @trip.delete
  end

  it "gets the trip" do
    get :show, :id => @trip.id
    expect(response.status).to eq 200
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

    login_user
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
      post :new, :destination => "San Francisco", :startdate => "11/16/2015", :enddate => "11/18/2015", "1"=>"0", "2"=>"0", "3"=>"0"
      expect(Trip.count).to eq 1
      expect(TripAttraction.count).to eq 4
    end

  end

  context "generate itinerary" do

    before do
      Foursquare.should_receive(:import_attractions).and_return(@taipei_response)
      Foursquare.should_receive(:import_hours).at_most(20).times.and_return(@taipei_hours)
      Attraction.import_foursquare_attractions("Taipei", 20)
    end

    login_user
    it "test number of trip attractions in itinerary" do
      start_id = Attraction.first.id
      post :new, :destination => "Taipei", :startdate => "11/02/2015", :enddate => "11/03/2015",
           start_id.to_s =>"0", (start_id+1).to_s=>"0", (start_id+2).to_s=>"0", (start_id+3).to_s=>"0", (start_id+4).to_s=>"0", (start_id+5).to_s=>"0", (start_id+6).to_s=>"0", (start_id+7).to_s=>"0", (start_id+8).to_s=>"0"
      trip = Trip.find_by_city("Taipei")
      trip_attractions = TripAttraction.where.not(end_time: nil)
      expect(trip_attractions.length).to eq(10)
    end
  end

  context "shareable link to invite friends" do
    TripAttraction.delete_all
    Attraction.delete_all
    UserTrip.delete_all
    Trip.delete_all


    it "non-user enters shareable link" do
      @trip = Trip.create(city:'Taipei', :uuid => SecureRandom.uuid)
      get :show_itinerary, :trip_id => @trip.id, :invitation_code => @trip.uuid
      expect(flash[:notice]).to have_text("Ooops! You do not have permission to view this page. Please sign up or log in.")
    end
  end

  context "shareable link to invite friends while logged in" do
    TripAttraction.delete_all
    Attraction.delete_all
    UserTrip.delete_all
    Trip.delete_all

    render_views false
    login_user
    it "logged in user without permission and invitation" do
      @trip = Trip.create(city: 'Miami', uuid: SecureRandom.uuid)
      get :show_itinerary, :trip_id => @trip.id
      expect(flash[:notice]).to have_text("Ooops! Your account does not have permission to view this trip or itinerary. Please contact the owner of the trip to get a valid link to this page.")
    end

    it "logged in user joining with incorrect invitation" do
      @trip = Trip.create(city: 'Tokyo', uuid: SecureRandom.uuid)
      get :show_itinerary, :trip_id => @trip.id, :invitation_code => "wrongcode"
      expect(flash[:notice]).to have_text("Ooops! Your invitation code seems incorrect. Please double check the code with the owner.")
    end

    it "logged in user joining with correct invitation without exisiting itinerary" do
      @city = City.create(name: 'London', lat: 51.5072, lng: 0.1275)
      @trip = Trip.create(city: @city.name, start_time: DateTime.now, end_time: DateTime.now, uuid: SecureRandom.uuid)
      expect {
        get :show_itinerary, :trip_id => @trip.id, :invitation_code => @trip.uuid
      }.to change{ UserTrip.count }.by(1)
    end

    it "logged in user joining with correct invitation with exisiting itinerary" do
      @city = City.create(name: 'London', lat: 51.5072, lng: 0.1275)
      @trip = Trip.create(city: @city.name, start_time: DateTime.now, end_time: DateTime.now, uuid: SecureRandom.uuid)
      @trip.trip_attractions = [TripAttraction.create(start_time: DateTime.now)]
      expect {
        get :show_itinerary, :trip_id => @trip.id, :invitation_code => @trip.uuid
      }.to change{ UserTrip.count }.by(1)
    end
  end

end
