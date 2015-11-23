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
      expect(Trip.count).to eq 1
      expect(TripAttraction.count).to eq 3
    end

    it "change vote counts for trip_attraction id:1" do
      post :new, :destination => "San Francisco", "1"=>"1", "2"=>"0", "3"=>"0"
      expect(TripAttraction.find(1).vote_count).to eq 1
    end
    
    it "should fail to create trip- end_date before start_date" do
      post :new, :destination => "San Francisco", :startdate => "11/18/2015", :enddate => "11/16/2015",
           "1"=>"0", "2"=>"0", "3"=>"0"
      expect { raise "start_date later than end_date" }.to raise_error
    end
  end

  context "generate itinerary" do
    before(:context) do
      City.delete_all
      Trip.delete_all
      Attraction.delete_all
      TripAttraction.delete_all
    end

    def fake_api_call
      @last_modified = Date.new(2010, 1, 15).to_s
      @content_length = '52823'
      @request_object = HTTParty::Request.new Net::HTTP::Get, '/'
      @response_object = Net::HTTPOK.new('1.1', 200, 'OK')
      allow(@response_object).to receive_messages(body: File.read('spec/data/import_taipei.json'))
      @response_object['last-modified'] = @last_modified
      @response_object['content-length'] = @content_length
      @parsed_response = lambda { {"foo" => "bar"} }
      @fake_response = HTTParty::Response.new(@request_object, @response_object, @parsed_response)
    end

    def fake_hours_api_call
      @last_modified = Date.new(2010, 1, 15).to_s
      @content_length = '52823'
      @request_object = HTTParty::Request.new Net::HTTP::Get, '/'
      @response_object = Net::HTTPOK.new('1.1', 200, 'OK')
      allow(@response_object).to receive_messages(body: File.read('spec/data/taipei_hours.json'))
      @response_object['last-modified'] = @last_modified
      @response_object['content-length'] = @content_length
      @parsed_response = lambda { {"foo" => "bar"} }
      @fake_response = HTTParty::Response.new(@request_object, @response_object, @parsed_response)
    end

    before do
      fake_api_call
      HTTParty.should_receive(:get).and_return(@fake_response)
      Attraction.import_foursquare_attractions("Taipei", 20)
    end

    it "test number of trip attractions in itinerary" do
      start_id = Attraction.first.id
      fake_hours_api_call
      HTTParty.should_receive(:get).at_most(20).times.and_return(@fake_response)
      post :new, :destination => "Taipei", :startdate => "11/02/2015", :enddate => "11/03/2015",
           start_id.to_s =>"0", (start_id+1).to_s=>"0", (start_id+2).to_s=>"0", (start_id+3).to_s=>"0", (start_id+4).to_s=>"0", (start_id+5).to_s=>"0", (start_id+6).to_s=>"0", (start_id+7).to_s=>"0", (start_id+8).to_s=>"0"
      trip = Trip.find_by_city("Taipei")
      post :generate_itinerary, :id => trip.id
      trip_attractions = TripAttraction.where.not(end_time: nil)
      expect(trip_attractions.length).to eq(8)
    end
  end
end
