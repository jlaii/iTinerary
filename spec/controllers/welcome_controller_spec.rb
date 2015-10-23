require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
	before :each do
		sign_out :user
	end
  context "save welcome page information" do
    it "saving trip given city and date" do
      expect(Trip.count).to eq 0
      post :save, :destination => 'San Francisco', :startdate => '10/23/2015', :enddate => '10/24/2015'
      expect(Trip.count).to eq 1
      trip = Trip.find_by_city('San Francisco')
      expect(trip).not_to eq nil
      expect(trip.start_time).to eq DateTime.new(2015, 10, 23)
      expect(trip.end_time).to eq DateTime.new(2015, 10, 24)
    end
  end

  context "start date and end date validation" do
    it "start date should be prior to end date" do
      expect(Trip.count).to eq 0
      post :save, :destination => 'New York', :startdate => '10/25/2015', :enddate => '10/24/2015'
      trip = Trip.find_by_city('New York')
      expect(trip).to eq nil
      expect(Trip.count).to eq 0
    end
  end
end
