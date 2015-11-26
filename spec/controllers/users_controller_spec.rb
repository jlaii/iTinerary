require 'rails_helper'
require 'spec_helper'

RSpec.describe UsersController, type: :controller do
  before(:context) do
    User.delete_all
    Trip.delete_all
    UserTrip.delete_all
  end

  # user = User.create(id: 1, email: "test@gmail.com")
  login_user # suppose to create user with id=1
  context "Test show" do
    # byebug
    it "checks if get the right amount of trips of a user" do
      Trip.create(id: 1)
      Trip.create(id: 2)
      Trip.create(id: 3)
      UserTrip.create(user_id: subject.current_user.id, trip_id: 1)
      UserTrip.create(user_id: subject.current_user.id, trip_id: 2)
      UserTrip.create(user_id: subject.current_user.id, trip_id: 3)
      # byebug
      post :show
      expect(assigns(:trips).length).to equal(3)
    end
  end
end
