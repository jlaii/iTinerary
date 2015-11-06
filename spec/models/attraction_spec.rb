require 'rails_helper'

RSpec.describe Attraction, type: :model do
  def fake_api_call
    @last_modified = Date.new(2010, 1, 15).to_s
    @content_length = '3533'
    @request_object = HTTParty::Request.new Net::HTTP::Get, '/'
    @response_object = Net::HTTPOK.new('1.1', 200, 'OK')
    allow(@response_object).to receive_messages(body: %q({"meta":{"code":200,"requestId":"563c8613498eb5a5246e168b"},"response":{"geocode":{"what":"","where":"san francisco","center":{"lat":37.77493,"lng":-122.41942},"displayString":"San Francisco, CA, United States","cc":"US","geometry":{"bounds":{"ne":{"lat":37.833687,"lng":-122.34905},"sw":{"lat":37.708085,"lng":-122.536232}}},"slug":"san-francisco-california","longId":"72057594043319895"},"warning":{"text":"There aren't a lot of results near you. Try something more general, reset your filters, or expand the search area."},"headerLocation":"San Francisco","headerFullLocation":"San Francisco","headerLocationGranularity":"city","totalResults":50,"suggestedBounds":{"ne":{"lat":37.77939528151925,"lng":-122.41917216389899},"sw":{"lat":37.7766956217338,"lng":-122.4218802557078}},"groups":[{"type":"Recommended Places","name":"recommended","items":[{"reasons":{"count":0,"items":[{"summary":"This spot is popular","type":"general","reasonName":"globalInteractionReason"}]},"venue":{"id":"4aa48566f964a520024720e3","name":"Louise M. Davies Symphony Hall","contact":{"phone":"4158646000","formattedPhone":"(415) 864-6000","twitter":"sfsymphony"},"location":{"address":"201 Van Ness Ave","crossStreet":"btwn Grove & Hayes St","lat":37.778045451626525,"lng":-122.4205262098034,"postalCode":"94102","cc":"US","city":"San Francisco","state":"CA","country":"United States","formattedAddress":["201 Van Ness Ave (btwn Grove & Hayes St)","San Francisco, CA 94102","United States"]},"categories":[{"id":"5032792091d4c4b30a586d5c","name":"Concert Hall","pluralName":"Concert Halls","shortName":"Concert Hall","icon":{"prefix":"https:\/\/ss3.4sqi.net\/img\/categories_v2\/arts_entertainment\/musicvenue_","suffix":".png"},"primary":true}],"verified":true,"stats":{"checkinsCount":20253,"usersCount":10617,"tipCount":57},"url":"http:\/\/www.sfsymphony.org","rating":9.5,"ratingColor":"00B551","ratingSignals":511,"hours":{"isOpen":false},"photos":{"count":1,"groups":[{"type":"venue","name":"Venue photos","count":1,"items":[{"id":"500f6ba6e4b0c5fcbc1d1d05","createdAt":1343187878,"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/aW-lSddmQt9fnQjgWr8mBbS_P0n6JlSsUKLLx0ZnTFU.jpg","width":537,"height":720,"user":{"id":"7067931","firstName":"Damien","lastName":"Silva","gender":"male","photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/LNTT5MM0V3UQVIFB.jpg"}},"visibility":"public"}]}]},"hereNow":{"count":0,"summary":"Nobody here","groups":[]},"featuredPhotos":{"count":1,"items":[{"id":"500f6ba6e4b0c5fcbc1d1d05","createdAt":1343187878,"prefix":"https:\/\/irs1.4sqi.net\/img\/general\/","suffix":"\/aW-lSddmQt9fnQjgWr8mBbS_P0n6JlSsUKLLx0ZnTFU.jpg","width":537,"height":720,"user":{"id":"7067931","firstName":"Damien","lastName":"Silva","gender":"male","photo":{"prefix":"https:\/\/irs0.4sqi.net\/img\/user\/","suffix":"\/LNTT5MM0V3UQVIFB.jpg"}},"visibility":"public"}]}},"tips":[{"id":"4b184a2270c603bb6d398fb4","createdAt":1259883042,"text":"Avoid the traffic, tolls, and the $$ parking garage fees - take BART to Civic Center station and walk four blocks west to the hall. You'll arrive in a better mood.","type":"user","canonicalUrl":"https:\/\/foursquare.com\/item\/4b184a2270c603bb6d398fb4","likes":{"count":35,"groups":[],"summary":"35 likes"},"logView":true,"todo":{"count":2},"user":{"id":"140038","firstName":"San Francisco Symphony","gender":"none","photo":{"prefix":"https:\/\/irs1.4sqi.net\/img\/user\/","suffix":"\/140038-WJZL2BJCNOW0R5MI.jpg"}}}],"referralId":"e-10-4aa48566f964a520024720e3-0"}]}]}}))
    @response_object['last-modified'] = @last_modified
    @response_object['content-length'] = @content_length
    @parsed_response = lambda { {"foo" => "bar"} }
    @response = HTTParty::Response.new(@request_object, @response_object, @parsed_response)
  end

  context "importing attractions using FourSquare" do
    before(:context) do
      Attraction.delete_all
      City.delete_all
    end
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end

    before do
      fake_api_call
    end


    it "imports attractions for a city" do
      expect(Attraction.count).to eq 0
      expect(City.count).to eq 0
      HTTParty.should_receive(:get).and_return(@response)
      Attraction.import_foursquare_attractions("San Francisco", num_attractions = 1)
      expect(City.count).to eq 1
      expect(Attraction.count).to eq 1
    end

    it "returns true if city exists" do
      HTTParty.should_receive(:get).and_return(@response)
      expect(Attraction.import_foursquare_attractions("San Francisco", 1)).to eq true
    end

    it "returns false if city does not exist" do
      expect(Attraction.count).to eq 0
      expect(Attraction.import_foursquare_attractions("city_that_does_not_exist")).to eq false
      expect(Attraction.count).to eq 0
    end

  end

  context "after importing attractions" do
    after(:context) do
      Attraction.delete_all
      City.delete_all
    end

    before do
      fake_api_call
    end
    it "an attraction and city contains all necessary relevant info" do
      HTTParty.should_receive(:get).and_return(@response)
      Attraction.import_foursquare_attractions("San Francisco", 1)
      attraction = Attraction.first
      expect(attraction.city).to_not eq nil
      expect(attraction.name).to_not eq nil
      expect(attraction.description).to_not eq nil
      expect(attraction.address).to_not eq nil
      expect(attraction.latitude).to_not eq nil
      expect(attraction.longitude).to_not eq nil
      expect(attraction.rating).to_not eq nil
      expect(attraction.picture_id).to_not eq nil
      expect(attraction.url).to_not eq nil
      city = City.first
      expect(city.name).to_not eq nil
      expect(city.lat).to_not eq nil
      expect(city.lng).to_not eq nil
    end


  end


  context "check attraction's hours" do
    def sample_hours_json
      JSON.parse(%q({"meta":{"code":200,"requestId":"563852f4498eef7582dde68c"},"notifications":[{"type":"notificationTray","item":{"unreadCount":0}}],"response":{"hours":{"timeframes":[{"days":[1,2,3,4,5],"includesToday":true,"open":[{"start":"0800","end":"1600"},{"start":"1800","end":"2330"}],"segments":[]},{"days":[6],"open":[{"start":"0900","end":"1600"},{"start":"1800","end":"2330"}],"segments":[]},{"days":[7],"open":[{"start":"0900","end":"1800"}],"segments":[]}]},"popular":{"timeframes":[{"days":[2],"includesToday":true,"open":[{"start":"0800","end":"1400"},{"start":"1800","end":"2100"}],"segments":[]},{"days":[3],"open":[{"start":"0800","end":"1500"},{"start":"1900","end":"2100"}],"segments":[]},{"days":[4],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2100"}],"segments":[]},{"days":[5],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2200"}],"segments":[]},{"days":[6],"open":[{"start":"0800","end":"1600"},{"start":"1800","end":"2200"}],"segments":[]},{"days":[7],"open":[{"start":"0800","end":"1700"}],"segments":[]},{"days":[1],"open":[{"start":"0800","end":"1500"},{"start":"1800","end":"2100"}],"segments":[]}]}}}))["response"]
    end

    def always_open_sample_hours_json
      JSON.parse(%q({"meta":{"code":200,"requestId":"563a96d2498eac20c1905d85"},"response":{"hours":{"timeframes":[{"days":[1,2,3,4,5,6,7],"includesToday":true,"open":[{"start":"0000","end":"+0000"}],"segments":[]}]},"popular":{"timeframes":[{"days":[3],"includesToday":true,"open":[{"start":"1200","end":"2000"}],"segments":[]},{"days":[4],"open":[{"start":"1200","end":"1400"},{"start":"1800","end":"2000"}],"segments":[]},{"days":[5],"open":[{"start":"1200","end":"1400"},{"start":"1600","end":"2100"}],"segments":[]},{"days":[6],"open":[{"start":"1000","end":"1900"}],"segments":[]},{"days":[7],"open":[{"start":"1000","end":"2000"}],"segments":[]},{"days":[1],"open":[{"start":"1200","end":"2000"}],"segments":[]},{"days":[2],"open":[{"start":"1200","end":"2100"}],"segments":[]}]}}}))["response"]

    end

    it "returns true if attraction is open" do
      fake_attraction = Attraction.new(:hours_json => sample_hours_json)
      expect(fake_attraction.is_open? 1, 800, 1600).to eq true
      expect(fake_attraction.is_open? 2, 800, 1600).to eq true
      expect(fake_attraction.is_open? 3, 800, 1600).to eq true
      expect(fake_attraction.is_open? 4, 800, 1600).to eq true
      expect(fake_attraction.is_open? 5, 800, 1600).to eq true
      expect(fake_attraction.is_open? 6, 900, 1600).to eq true
      expect(fake_attraction.is_open? 7, 900, 1800).to eq true
    end
    it "returns false if attraction is closed for any time during interval" do
      fake_attraction = Attraction.new(:hours_json => sample_hours_json)
      expect(fake_attraction.is_open? 1, 800, 1601).to eq false
      expect(fake_attraction.is_open? 2, 800, 1601).to eq false
      expect(fake_attraction.is_open? 3, 800, 1601).to eq false
      expect(fake_attraction.is_open? 4, 800, 1601).to eq false
      expect(fake_attraction.is_open? 5, 800, 1601).to eq false
      expect(fake_attraction.is_open? 6, 900, 1601).to eq false
      expect(fake_attraction.is_open? 7, 900, 1801).to eq false
    end

    it "returns true if attraction is open 24/7" do
      open_attraction = Attraction.new(:hours_json => always_open_sample_hours_json)
      expect(open_attraction.is_open? 1, 0000, 2400).to eq true
      expect(open_attraction.is_open? 2, 0000, 2400).to eq true
      expect(open_attraction.is_open? 3, 0000, 2400).to eq true
      expect(open_attraction.is_open? 4, 0000, 2400).to eq true
      expect(open_attraction.is_open? 5, 0000, 2400).to eq true
      expect(open_attraction.is_open? 6, 0000, 2400).to eq true
      expect(open_attraction.is_open? 7, 0000, 2400).to eq true
    end

  end
end
