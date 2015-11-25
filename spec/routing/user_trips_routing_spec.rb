require "rails_helper"

RSpec.describe UserTripsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/user_trips").to route_to("user_trips#index")
    end

    it "routes to #new" do
      expect(:get => "/user_trips/new").to route_to("user_trips#new")
    end

    it "routes to #show" do
      expect(:get => "/user_trips/1").to route_to("user_trips#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/user_trips/1/edit").to route_to("user_trips#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/user_trips").to route_to("user_trips#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/user_trips/1").to route_to("user_trips#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/user_trips/1").to route_to("user_trips#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/user_trips/1").to route_to("user_trips#destroy", :id => "1")
    end

  end
end
