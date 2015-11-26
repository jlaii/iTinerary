require 'rails_helper'
require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  before(:context) do
    User.delete_all
    Trip.delete_all
    UserTrip.delete_all
  end

  login_user # suppose to create user with id=1
  context "Test show" do
    it "checks if get the right amount of trips of a user" do
      Trip.create(id: 1)
      Trip.create(id: 2)
      Trip.create(id: 3)
      @curr_user_id = subject.current_user.id
      UserTrip.create(user_id: @curr_user_id, trip_id: 1)
      UserTrip.create(user_id: @curr_user_id, trip_id: 2)
      UserTrip.create(user_id: @curr_user_id, trip_id: 3)
      post :show
      expect(assigns(:trips).length).to equal(3)
    end
  end
end
