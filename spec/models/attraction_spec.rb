require 'rails_helper'

RSpec.describe Attraction, type: :model do
  context "importing attractions using FourSquare" do
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
end
