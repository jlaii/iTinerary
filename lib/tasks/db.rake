namespace :db do
  desc "import attractions for popular cities to database"
  task import_attractions: :environment do
    include HTTParty
    # import_google_attractions
    import_foursquare_attractions
  end

  def import_google_attractions
    client = GooglePlaces::Client.new(GOOGLE_API_KEY)
    city = client.spots_by_query('San Francisco').first
    attractions = client.spots(city.lat, city.lng, :multipage => true, :radius => 50000,
                               :language => 'en', :exclude => ["locality", "airport", "colloquial_area"])
    for attraction in attractions
      puts attraction.name
    end
  end

  def import_foursquare_attractions

    base_url = "https://api.foursquare.com/v2/venues/explore?"
    auth_string = "client_id=#{FOURSQUARE_CLIENT_ID}&client_secret=#{FOURSQUARE_CLIENT_SECRET}"
    query_string = "&v=20151021&section=sights&limit=50&radius=50000"
    request_url = base_url + auth_string + query_string + "&near=San Francisco"
    response = JSON.parse(HTTParty.get(request_url).body)
    attractions = response["response"]["groups"].first["items"]
    for attraction in attractions
      puts attraction["venue"]["name"] + " : " + attraction["tips"].first["text"]
    end

  end

end
