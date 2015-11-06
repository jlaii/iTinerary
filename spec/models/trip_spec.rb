require 'rails_helper'

RSpec.describe Trip, type: :model do
  context "test travel time from San Francisco to Berkeley" do
    san_francisco = Attraction.new(latitude: 37.7833, longitude: -122.4167) # San Francisco
    berkeley = Attraction.new(latitude: 37.8717, longitude: -122.2728) # Berkeley
    asian_art_museum = Attraction.new(latitude: 37.7803, longitude: -122.4161) # Asian Art Museum

    it "calculates euclidean distance from san francisco to berkeley" do
      expect(Trip.calculate_distance_euclidean(san_francisco, berkeley).round(3)).to eq(16.011)
    end

    it "calculates euclidean travel time from san francisco to berkeley" do
      expect(Trip.calculate_travel_time_euclidean(san_francisco, berkeley, 30).round(0)).to eq(32)
    end

    it "calculates manhattan distance from san francisco to berkeley" do
      expect(Trip.calculate_distance_manhattan(san_francisco, berkeley).round(3)).to eq(22.468)
    end

    it "calculates manhattan travel time from san francisco to berkeley" do
      expect(Trip.calculate_travel_time_manhattan(san_francisco, berkeley, 30).round(0)).to eq(45)
    end

    it "calculates euclidean travel time to itself" do
      expect(Trip.calculate_travel_time_euclidean(san_francisco, san_francisco, 30).round(0)).to eq(0)
    end

    it "calculates manhattan travel time to itself" do
      expect(Trip.calculate_travel_time_manhattan(san_francisco, san_francisco, 30).round(0)).to eq(0)
    end

    it "calculates manhattan travel time from san francisco to asian art museum" do
      expect(Trip.calculate_travel_time_manhattan(san_francisco, asian_art_museum, 30).round(0)).to eq(1)
    end
  end
end