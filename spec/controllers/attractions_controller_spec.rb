require 'rails_helper'
require 'byebug'

RSpec.describe AttractionsController, type: :controller do

  def fake_api_call
    @last_modified = Date.new(2010, 1, 15).to_s
    @content_length = '3533'
    @request_object = HTTParty::Request.new Net::HTTP::Get, '/'
    @fake_response_object = Net::HTTPOK.new('1.1', 200, 'OK')
    allow(@fake_response_object).to receive_messages(body: %q({"meta":{"code":200,"requestId":"563c8613498eb5a5246e168b"},"response":{"geocode":{"what":"","where":"san francisco","center":{"lat":37.77493,"lng":-122.41942},"displayString":"San Francisco, CA, United States","cc":"US","geometry":{"bounds":{"ne":{"lat":37.833687,"lng":-122.34905},"sw":{"lat":37.708085,"lng":-122.536232}}},"slug":"san-francisco-california","longId":"72057594043319895"},"warning":{"text":"There aren't a lot of results near you. Try something more general, reset your filters, or expand the search area."},"headerLocation":"San Francisco","headerFullLocation":"San Francisco","headerLocationGranularity":"city","totalResults":50,"suggestedBounds":{"ne":{"lat":37.77939528151925,"lng":-122.41917216389899},"sw":{"lat":37.7766956217338,"lng":-122.4218802557078}},"groups":[{"type":"Recommended Places","name":"recommended","items":[{"reasons":{"count":0,"items":[{"summary":"This spot is popular","type":"general","reasonName":"globalInteractionReason"}]},"venue":{"id":"4aa48566f964a520024720e3","name":"Louise M. Davies Symphony Hall","contact":{"phone":"4158646000","formattedPhone":"(415) 864-6000","twitter":"sfsymphony"},"location":{"address":"201 Van Ness Ave","crossStreet":"btwn Grove & Hayes St","lat":37.778045451626525,"lng":-122.4205262098034,"postalCode":"94102","cc":"US","city":"San Francisco","state":"CA","country":"United States","formattedAddress":["201 Van Ness Ave (btwn Grove & Hayes St)","San Francisco, CA 94102","United States"]},"categories":[{"id":"5032792091d4c4b30a586d5c","name":"Concert Hall","pluralName":"Concert Halls","shortName":"Concert Hall","icon":{"prefix":"https:\/\/ss3.4sqi.net\/img\/categories_v2\/arts_entertainment\/musicvenue_","suffix":".png"},"primary":true}],"verified":true,"stats":{"checkinsCount":20253,"usersCount":10617,"tipCount":57},"url":"http:\/\/www.sfsymphony.org","rating":9.5,"ratingColor":"00B551","ratingSignals":511,"hours":{"isOpen":false},"photos":{"count":1,"groups":[{"type":"venue","name":"Venue photos","count":1,"items":[{"id":"500f6ba6e4b0c5fcbc1d1d05","createdAt":1343187878,"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/aW-lSddmQt9fnQjgWr8mBbS_P0n6JlSsUKLLx0ZnTFU.jpg","width":537,"height":720,"user":{"id":"7067931","firstName":"Damien","lastName":"Silva","gender":"male","photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/LNTT5MM0V3UQVIFB.jpg"}},"visibility":"public"}]}]},"hereNow":{"count":0,"summary":"Nobody here","groups":[]},"featuredPhotos":{"count":1,"items":[{"id":"500f6ba6e4b0c5fcbc1d1d05","createdAt":1343187878,"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/aW-lSddmQt9fnQjgWr8mBbS_P0n6JlSsUKLLx0ZnTFU.jpg","width":537,"height":720,"user":{"id":"7067931","firstName":"Damien","lastName":"Silva","gender":"male","photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/LNTT5MM0V3UQVIFB.jpg"}},"visibility":"public"}]}},"tips":[{"id":"4b184a2270c603bb6d398fb4","createdAt":1259883042,"text":"Avoid the traffic, tolls, and the $$ parking garage fees - take BART to Civic Center station and walk four blocks west to the hall. You'll arrive in a better mood.","type":"user","canonicalUrl":"https:\/\/foursquare.com\/item\/4b184a2270c603bb6d398fb4","likes":{"count":35,"groups":[],"summary":"35 likes"},"logView":true,"todo":{"count":2},"user":{"id":"140038","firstName":"San Francisco Symphony","gender":"none","photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/140038-WJZL2BJCNOW0R5MI.jpg"}}}],"referralId":"e-10-4aa48566f964a520024720e3-0"}]}]}}))
    @fake_response_object['last-modified'] = @last_modified
    @fake_response_object['content-length'] = @content_length
    @parsed_response = lambda { {"foo" => "bar"} }
    @fake_response = HTTParty::Response.new(@request_object, @fake_response_object, @parsed_response)
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
