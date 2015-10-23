require 'rails_helper'
require 'byebug'

RSpec.describe AttractionsController, type: :controller do
  context "shows a list of attractions" do
    before(:each) do
      Attraction.delete_all
    end
    after(:each) do
      Attraction.delete_all
    end
    it "retrieves attractions if city hasn't been loaded before" do
      expect(Attraction.find_by_city("San Francisco")).to eq nil
      get :show, :destination => 'San Francisco'
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
    end

    it "doesn't retrieve new attractions if city has been loaded before" do
      Attraction.import_foursquare_attractions("San Francisco")
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
      expect(Attraction.count).to eq 50
      get :show, :destination => 'San Francisco'
      expect(Attraction.count).to eq 50
    end

    it "show an error if no attractions could be found for a given destination" do
      get :show, :destination => 'AtlantisTheCityThatDoesntExist'
      expect(flash[:error]).to eq "Could not find attractions in 'AtlantisTheCityThatDoesntExist'"


    end

  end

  context "show by id" do
    before(:context) do
      Attraction.import_foursquare_attractions("San Francisco")
    end
    after(:context) do
      Attraction.delete_all
    end
    it "shows the attraction if the id exists" do
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
      get :show_by_id, :id => Attraction.first.id
      expect(response.status).to eq 200
    end

    it "does not show the attraction if the id is invalid, because there will be an error" do
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
      begin
        get :show_by_id, :id => -1
      rescue ActiveRecord::RecordNotFound

      end
    end
  end


end
