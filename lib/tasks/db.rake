namespace :db do
  desc "import attractions for popular cities to database"
  task import_attractions: :environment do
    require "Attraction"
    require "Picture"
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
      if attraction["venue"]["photos"]["count"] > 0
        picture_path = attraction["venue"]["photos"]["groups"].first["prefix"] + "240x240"
        + attraction["venue"]["photos"]["groups"].first["suffix"]
        picture = Picture.new(:attraction_id => Attraction.maximum(:id).next,
                              :path => picture_path)
        byebug
        picture = picture.save ? picture : nil
      else
        picture = nil
      end
      new_attraction = Attraction.new(:name => attraction["venue"]["name"],
                                      :city => attraction["venue"]["location"]["city"],
                                      :category => attraction["venue"]["categories"].first["name"],
                                      :description => attraction["tips"].first["text"],
                                      :address => attraction["venue"]["location"]["formattedAddress"],
                                      :latitude => attraction["venue"]["location"]["lat"],
                                      :longitude => attraction["venue"]["location"]["lng"],
                                      :rating => attraction["venue"]["rating"],
                                      :picture_id => picture)
      # new_attraction.validate
      # if new_attraction.save
      #   puts "success"
      #   puts attraction["venue"]["name"] + " : " + attraction["tips"].first["text"]
      # end
    end
    byebug

  end

end
