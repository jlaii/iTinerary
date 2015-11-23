require 'rails_helper'
require 'byebug'

RSpec.describe AttractionsController, type: :controller do

  def fake_api_call
    fake_api_response = File.read('spec/data/fake_api.json')
    @last_modified = Date.new(2010, 1, 15).to_s
    @content_length = '3533'
    @request_object = HTTParty::Request.new Net::HTTP::Get, '/'
    @response_object = Net::HTTPOK.new('1.1', 200, 'OK')
    allow(@response_object).to receive_messages(body: fake_api_response)
    @response_object['last-modified'] = @last_modified
    @response_object['content-length'] = @content_length
    @parsed_response = lambda { {"foo" => "bar"} }
    @fake_response = HTTParty::Response.new(@request_object, @response_object, @parsed_response)
  end

  context "shows a list of attractions" do
    before(:each) do
      Attraction.delete_all
      City.delete_all
    end
    after(:each) do
      Attraction.delete_all
      City.delete_all
    end

    before do
      fake_api_call
    end

    it "retrieves attractions if city hasn't been loaded before" do
      expect(Attraction.find_by_city("San Francisco")).to eq nil
      get :show, :destination => 'San Francisco'
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
    end

    it "doesn't retrieve new attractions if city has been loaded before" do
      HTTParty.should_receive(:get).and_return(@fake_response)
      Attraction.import_foursquare_attractions("San Francisco")
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
      expect(Attraction.count).to eq 1
      get :show, :destination => 'San Francisco'
      expect(Attraction.count).to eq 1
    end

    it "show an error if no attractions could be found for a given destination" do
      get :show, :destination => 'AtlantisTheCityThatDoesntExist'
      expect(flash[:error]).to eq "Could not find attractions in 'Atlantis The City That Doesnt Exist'"


    end

  end

  context "show by id" do
    before(:context) do
      Attraction.delete_all
    end
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end
    before do
      fake_api_call
      HTTParty.should_receive(:get).and_return(@fake_response)
      Attraction.import_foursquare_attractions("San Francisco")
    end
    it "shows the attraction if the id exists" do
      expect(Attraction.find_by_city("San Francisco")).to_not eq nil
      get :show_by_id, :id => Attraction.first.id
      expect(assigns[:attraction].id).to eq Attraction.first.id
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
