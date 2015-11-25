require 'rails_helper'
require 'Foursquare'
# require 'yaml'
# fake_api = YAML.load_file('spec/fake_api.yml')

RSpec.describe Attraction, type: :model do
  before(:all) do
    @fake_api_response = File.read('spec/data/fake_api.json')
  end

  context "importing attractions using FourSquare" do

    before do
      Attraction.delete_all
      City.delete_all
    end

    after do
      Attraction.delete_all
      City.delete_all
    end

    it "imports attractions for a city" do
      expect(Attraction.count).to eq 0
      expect(City.count).to eq 0
      Foursquare.should_receive(:import_attractions).and_return(@fake_api_response)
      Attraction.import_foursquare_attractions("San Francisco", num_attractions = 1)
      expect(City.count).to eq 1
      expect(Attraction.count).to eq 1
    end

    it "returns true if city exists" do
      Foursquare.should_receive(:import_attractions).and_return(@fake_api_response)
      expect(Attraction.import_foursquare_attractions("San Francisco", 1)).to eq true
    end

    it "returns false if city does not exist" do
      expect(Attraction.count).to eq 0
      expect(Attraction.import_foursquare_attractions("city_that_does_not_exist")).to eq false
      expect(Attraction.count).to eq 0
    end

  end

  context "after importing attractions" do
    before do
      Attraction.delete_all
      City.delete_all
    end
    after do
      Attraction.delete_all
      City.delete_all
    end
    it "an attraction and city contains all necessary relevant info" do
      Foursquare.should_receive(:import_attractions).and_return(@fake_api_response)
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

    it "returns the number of overlapping hours with a popular timeframe" do
      #this attraction is popular from 800-1400 on tuesdays (11/24 is a tuesday)
      popular_attraction = Attraction.new(:hours_json => @sample_hours_json)
      time = DateTime.new(2015, 11, 24, 8)
      expect(popular_attraction.num_hours_popular(time)).to eq 2
      time = time.change({hour: 7})
      expect(popular_attraction.num_hours_popular(time)).to eq 1
      time = time.change({hour: 6})
      expect(popular_attraction.num_hours_popular(time)).to eq 0

    end

  end
end
