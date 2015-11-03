require 'rails_helper'

RSpec.describe Attraction, type: :model do
  context "importing attractions using FourSquare" do
    before(:context) do
      Attraction.delete_all
    end
    after(:context) do
      Attraction.delete_all
    end
    it "imports attractions for a city" do
      expect(Attraction.count).to eq 0
      Attraction.import_foursquare_attractions("San Francisco", num_attractions = 1)
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
    end
    it "an attraction contains all necessary relevant info" do
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
      expect(attraction.hours_json).to_not eq nil
    end


  end

  def sample_hours_json
    JSON.parse(%q({"meta":{"code":200,"requestId":"563852f4498eef7582dde68c"},"notifications":[{"type":"notificationTray","item":{"unreadCount":0}}],"response":{"hours":{"timeframes":[{"days":[1,2,3,4,5],"includesToday":true,"open":[{"start":"0800","end":"1600"},{"start":"1800","end":"2330"}],"segments":[]},{"days":[6],"open":[{"start":"0900","end":"1600"},{"start":"1800","end":"2330"}],"segments":[]},{"days":[7],"open":[{"start":"0900","end":"1800"}],"segments":[]}]},"popular":{"timeframes":[{"days":[2],"includesToday":true,"open":[{"start":"0800","end":"1400"},{"start":"1800","end":"2100"}],"segments":[]},{"days":[3],"open":[{"start":"0800","end":"1500"},{"start":"1900","end":"2100"}],"segments":[]},{"days":[4],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2100"}],"segments":[]},{"days":[5],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2200"}],"segments":[]},{"days":[6],"open":[{"start":"0800","end":"1600"},{"start":"1800","end":"2200"}],"segments":[]},{"days":[7],"open":[{"start":"0800","end":"1700"}],"segments":[]},{"days":[1],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2100"}],"segments":[]}]}}}))["response"]
  end

  context "check attraction's hours" do
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

  end
end
