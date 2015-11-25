require 'HTTParty'

class Foursquare
  AUTH_STRING = "client_id=#{FOURSQUARE_CLIENT_ID}&client_secret=#{FOURSQUARE_CLIENT_SECRET}&v=20151021"

  def self.import_attractions(city, num_attractions)
    base_url = "https://api.foursquare.com/v2/venues/explore?"
    query_string = "&section=sights&limit=#{num_attractions}&radius=50000&venuePhotos=1&near=#{city}"
    request_url = base_url + AUTH_STRING + query_string
    HTTParty.get(request_url).body
  end

  def self.import_hours(city)
    attraction_hours_url = "https://api.foursquare.com/v2/venues/#{city.id}/hours?#{AUTH_STRING}"
    HTTParty.get(attraction_hours_url).body
  end


end
