class Attraction < ActiveRecord::Base
  has_many :pictures
  validates :name, presence: true


  def self.import_foursquare_attractions(city)
    begin
      if city.length == 0
        flash[:error] = "Destination must be non-empty"
        return false
      end
      base_url = "https://api.foursquare.com/v2/venues/explore?"
      auth_string = "client_id=#{FOURSQUARE_CLIENT_ID}&client_secret=#{FOURSQUARE_CLIENT_SECRET}"
      query_string = "&v=20151021&section=sights&limit=50&radius=50000"
      request_url = base_url + auth_string + query_string + "&near=#{city}"
      response = JSON.parse(HTTParty.get(request_url).body)
      attractions = response["response"]["groups"].first["items"]
      for attraction in attractions
        if attraction["venue"]["photos"]["count"] > 0
          picture_path = attraction["venue"]["photos"]["groups"].first["prefix"] + "240x240"
          + attraction["venue"]["photos"]["groups"].first["suffix"]
          picture = Picture.new(:attraction_id => Attraction.maximum(:id).next,
                                :path => picture_path)
          picture = picture.save ? picture : nil
        else
          picture = nil
        end
        new_attraction = self.new(:name => attraction["venue"]["name"],
                                  :city => attraction["venue"]["location"]["city"],
                                  :category => attraction["venue"]["categories"].first["name"],
                                  :description => attraction["tips"].first["text"],
                                  :address => attraction["venue"]["location"]["formattedAddress"],
                                  :latitude => attraction["venue"]["location"]["lat"],
                                  :longitude => attraction["venue"]["location"]["lng"],
                                  :rating => attraction["venue"]["rating"],
                                  :picture_id => picture)
        new_attraction.save
      end
    rescue StandardError
      return false
    end
    return true

  end

end
