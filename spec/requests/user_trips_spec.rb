require 'rails_helper'

RSpec.describe "UserTrips", type: :request do
  describe "GET /user_trips" do
    it "works! (now write some real specs)" do
      get user_trips_path
      expect(response).to have_http_status(200)
    end
  end
end
