require 'rails_helper'

RSpec.describe Attraction, type: :model do
  context "importing attractions using FourSquare" do
    before(:context) do
      Attraction.delete_all
    end
    after(:context) do
      Attraction.delete_all
    end
    it "imports at most 50 attractions for a city" do
      expect(Attraction.count).to eq 0
      Attraction.import_foursquare_attractions("San Francisco")
      expect(Attraction.count).to eq 50
    end

    it "returns true if city exists" do
      expect(Attraction.count).to eq 0
      expect(Attraction.import_foursquare_attractions("San Francisco")).to eq true
      expect(Attraction.count).to eq 50
    end

    it "returns false if city does not exist" do
      expect(Attraction.count).to eq 0
      expect(Attraction.import_foursquare_attractions("city_that_does_not_exist")).to eq false
      expect(Attraction.count).to eq 0
    end

  end

  context "after importing attractions" do
    before(:context) do
      Attraction.import_foursquare_attractions("San Francisco")
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
    end


  end
end
