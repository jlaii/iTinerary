require 'rails_helper'

RSpec.describe TripAttraction, type: :model do
  before do
    Trip.delete_all
    Attraction.delete_all
    TripAttraction.delete_all
  end

  context "saving trip attraction" do
    it "saves" do
      attraction = Attraction.new(id: 1)
      expect {
        TripAttraction.save_trip_attraction(attraction, 1)
      }.to change{ TripAttraction.count }.by(1)
    end
  end
end
