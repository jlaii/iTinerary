require 'rails_helper'
require 'byebug'

RSpec.describe Attraction, type: :model do
  context "importing attractions using FourSquare" do
    it "imports attractions for a given city" do
      expect(Attraction.find_by_city("San Francisco")).to eq nil
      Attraction.import_foursquare_attractions("San Francisco")
      expect(Attraction.find_by_city("San Francisco")).not_to eq nil
    end
  end
end
