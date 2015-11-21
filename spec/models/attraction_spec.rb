require 'rails_helper'
# require 'yaml'
# fake_api = YAML.load_file('spec/fake_api.yml')

RSpec.describe Attraction, type: :model do
  def fake_api_call
    fake_api_response = File.read('spec/data/fake_api.json')
    @last_modified = Date.new(2010, 1, 15).to_s
    @content_length = '3533'
    @request_object = HTTParty::Request.new Net::HTTP::Get, '/'
    @response_object = Net::HTTPOK.new('1.1', 200, 'OK')
    allow(@response_object).to receive_messages(body: fake_api_response)
    @response_object['last-modified'] = @last_modified
    @response_object['content-length'] = @content_length
    @parsed_response = lambda { {"foo" => "bar"} }
    @fake_response = HTTParty::Response.new(@request_object, @response_object, @parsed_response)
  end

  context "importing attractions using FourSquare" do
    before(:context) do
      Attraction.delete_all
      City.delete_all
    end
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end

    before do
      fake_api_call
    end


    it "imports attractions for a city" do
      expect(Attraction.count).to eq 0
      expect(City.count).to eq 0
      HTTParty.should_receive(:get).and_return(@fake_response)
      Attraction.import_foursquare_attractions("San Francisco", num_attractions = 1)
      expect(City.count).to eq 1
      expect(Attraction.count).to eq 1
    end

    it "returns true if city exists" do
      HTTParty.should_receive(:get).and_return(@fake_response)
      expect(Attraction.import_foursquare_attractions("San Francisco", 1)).to eq true
    end

    it "returns false if city does not exist" do
      expect(Attraction.count).to eq 0
      expect(Attraction.import_foursquare_attractions("city_that_does_not_exist")).to eq false
      expect(Attraction.count).to eq 0
    end

  end

  context "after importing attractions" do
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end

    before do
      fake_api_call
    end
    it "an attraction and city contains all necessary relevant info" do
      HTTParty.should_receive(:get).and_return(@fake_response)
      Attraction.import_foursquare_attractions("San Francisco", 1)
      attraction = Attraction.first
      expect(attraction.city).to_not eq nil
      expect(attraction.name).to_not eq nil
      expect(attraction.description).to_not eq nil
      expect(attraction.address).to_not eq nil
      expect(attraction.latitude).to_not eq nil
      expect(attraction.longitude).to_not eq nil
      expect(attraction.rating).to_not eq nil
      expect(attraction.picture_id).to_not eq nil
      expect(attraction.url).to_not eq nil
      city = City.first
      expect(city.name).to_not eq nil
      expect(city.lat).to_not eq nil
      expect(city.lng).to_not eq nil
    end


  end


  context "check attraction's hours" do
    before(:context) do
      @sample_hours_json = JSON.parse(File.read('spec/data/sample_hours.json'))["response"]
      @always_open_sample_hours_json = JSON.parse(File.read('spec/data/always_open_sample_hours.json'))["response"]
    end

    it "returns true if attraction is open" do
      fake_attraction = Attraction.new(:hours_json => @sample_hours_json)
      expect(fake_attraction.is_open? 1, 800, 1600).to eq true
      expect(fake_attraction.is_open? 2, 800, 1600).to eq true
      expect(fake_attraction.is_open? 3, 800, 1600).to eq true
      expect(fake_attraction.is_open? 4, 800, 1600).to eq true
      expect(fake_attraction.is_open? 5, 800, 1600).to eq true
      expect(fake_attraction.is_open? 6, 900, 1600).to eq true
      expect(fake_attraction.is_open? 7, 900, 1800).to eq true
    end
    it "returns false if attraction is closed for any time during interval" do
      fake_attraction = Attraction.new(:hours_json => @sample_hours_json)
      expect(fake_attraction.is_open? 1, 800, 1601).to eq false
      expect(fake_attraction.is_open? 2, 800, 1601).to eq false
      expect(fake_attraction.is_open? 3, 800, 1601).to eq false
      expect(fake_attraction.is_open? 4, 800, 1601).to eq false
      expect(fake_attraction.is_open? 5, 800, 1601).to eq false
      expect(fake_attraction.is_open? 6, 900, 1601).to eq false
      expect(fake_attraction.is_open? 7, 900, 1801).to eq false
    end

    it "returns true if attraction is open 24/7" do
      open_attraction = Attraction.new(:hours_json => @always_open_sample_hours_json)
      expect(open_attraction.is_open? 1, 0000, 2400).to eq true
      expect(open_attraction.is_open? 2, 0000, 2400).to eq true
      expect(open_attraction.is_open? 3, 0000, 2400).to eq true
      expect(open_attraction.is_open? 4, 0000, 2400).to eq true
      expect(open_attraction.is_open? 5, 0000, 2400).to eq true
      expect(open_attraction.is_open? 6, 0000, 2400).to eq true
      expect(open_attraction.is_open? 7, 0000, 2400).to eq true
    end

  end
end
