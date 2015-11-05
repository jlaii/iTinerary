require 'rails_helper'

RSpec.describe Attraction, type: :model do
  context "importing attractions using FourSquare" do
    before(:context) do
      Attraction.delete_all
      City.delete_all
    end
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end

    it "imports attractions for a city" do
      expect(Attraction.count).to eq 0
      expect(City.count).to eq 0
      Attraction.import_foursquare_attractions("San Francisco", num_attractions = 1)
      expect(City.count).to eq 1
      expect(Attraction.count).to eq 1
    end

    it "returns true if city exists" do
      expect(Attraction.import_foursquare_attractions("San Francisco", 1)).to eq true
    end

    it "returns false if city does not exist" do
      expect(Attraction.count).to eq 0
      expect(Attraction.import_foursquare_attractions("city_that_does_not_exist")).to eq false
      expect(Attraction.count).to eq 0
    end

  end

  context "after importing attractions" do
    before(:context) do
      Attraction.import_foursquare_attractions("San Francisco", 1)
    end
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end
    it "an attraction and city contains all necessary relevant info" do
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
    def sample_hours_json
      JSON.parse(%q({"meta":{"code":200,"requestId":"563852f4498eef7582dde68c"},"notifications":[{"type":"notificationTray","item":{"unreadCount":0}}],"response":{"hours":{"timeframes":[{"days":[1,2,3,4,5],"includesToday":true,"open":[{"start":"0800","end":"1600"},{"start":"1800","end":"2330"}],"segments":[]},{"days":[6],"open":[{"start":"0900","end":"1600"},{"start":"1800","end":"2330"}],"segments":[]},{"days":[7],"open":[{"start":"0900","end":"1800"}],"segments":[]}]},"popular":{"timeframes":[{"days":[2],"includesToday":true,"open":[{"start":"0800","end":"1400"},{"start":"1800","end":"2100"}],"segments":[]},{"days":[3],"open":[{"start":"0800","end":"1500"},{"start":"1900","end":"2100"}],"segments":[]},{"days":[4],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2100"}],"segments":[]},{"days":[5],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2200"}],"segments":[]},{"days":[6],"open":[{"start":"0800","end":"1600"},{"start":"1800","end":"2200"}],"segments":[]},{"days":[7],"open":[{"start":"0800","end":"1700"}],"segments":[]},{"days":[1],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2100"}],"segments":[]}]}}}))["response"]
    end

    def always_open_sample_hours_json
      JSON.parse(%q({"meta":{"code":200,"requestId":"563a96d2498eac20c1905d85"},"response":{"hours":{"timeframes":[{"days":[1,2,3,4,5,6,7],"includesToday":true,"open":[{"start":"0000","end":"+0000"}],"segments":[]}]},"popular":{"timeframes":[{"days":[3],"includesToday":true,"open":[{"start":"1200","end":"2000"}],"segments":[]},{"days":[4],"open":[{"start":"1200","end":"1400"},{"start":"1800","end":"2000"}],"segments":[]},{"days":[5],"open":[{"start":"1200","end":"1400"},{"start":"1600","end":"2100"}],"segments":[]},{"days":[6],"open":[{"start":"1000","end":"1900"}],"segments":[]},{"days":[7],"open":[{"start":"1000","end":"2000"}],"segments":[]},{"days":[1],"open":[{"start":"1200","end":"2000"}],"segments":[]},{"days":[2],"open":[{"start":"1200","end":"2100"}],"segments":[]}]}}}))["response"]

    end

    it "returns true if attraction is open" do
      fake_attraction = Attraction.new(:hours_json => sample_hours_json)
      expect(fake_attraction.is_open? 1, 800, 1600).to eq true
      expect(fake_attraction.is_open? 2, 800, 1600).to eq true
      expect(fake_attraction.is_open? 3, 800, 1600).to eq true
      expect(fake_attraction.is_open? 4, 800, 1600).to eq true
      expect(fake_attraction.is_open? 5, 800, 1600).to eq true
      expect(fake_attraction.is_open? 6, 900, 1600).to eq true
      expect(fake_attraction.is_open? 7, 900, 1800).to eq true
    end
    it "returns false if attraction is closed for any time during interval" do
      fake_attraction = Attraction.new(:hours_json => sample_hours_json)
      expect(fake_attraction.is_open? 1, 800, 1601).to eq false
      expect(fake_attraction.is_open? 2, 800, 1601).to eq false
      expect(fake_attraction.is_open? 3, 800, 1601).to eq false
      expect(fake_attraction.is_open? 4, 800, 1601).to eq false
      expect(fake_attraction.is_open? 5, 800, 1601).to eq false
      expect(fake_attraction.is_open? 6, 900, 1601).to eq false
      expect(fake_attraction.is_open? 7, 900, 1801).to eq false
    end

    it "returns true if attraction is open 24/7" do
      open_attraction = Attraction.new(:hours_json => always_open_sample_hours_json)
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
