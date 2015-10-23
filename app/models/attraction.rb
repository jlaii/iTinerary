class Attraction < ActiveRecord::Base
  has_many :pictures
  validates :name, presence: true


  def self.import_foursquare_attractions(city)
    begin
      base_url = "https://api.foursquare.com/v2/venues/explore?"
      auth_string = "client_id=#{FOURSQUARE_CLIENT_ID}&client_secret=#{FOURSQUARE_CLIENT_SECRET}"
      query_string = "&v=20151021&section=sights&limit=50&radius=50000&venuePhotos=1"
      request_url = base_url + auth_string + query_string + "&near=#{city}"
      response = JSON.parse(HTTParty.get(request_url).body)
      attractions = response["response"]["groups"].first["items"]
      for attraction in attractions
        picture_path = attraction["venue"]["featuredPhotos"]["items"].first["prefix"] + "240x240" +
                       attraction["venue"]["featuredPhotos"]["items"].first["suffix"]
        picture = Picture.new(:path => picture_path)
        picture = picture.save ? picture : nil
        new_attraction = self.new(:name => attraction["venue"]["name"],
                                  :city => city,
                                  :category => attraction["venue"]["categories"].first["name"],
                                  :description => attraction["tips"].first["text"],
                                  :address => attraction["venue"]["location"]["formattedAddress"],
                                  :latitude => attraction["venue"]["location"]["lat"],
                                  :longitude => attraction["venue"]["location"]["lng"],
                                  :rating => attraction["venue"]["rating"],
                                  :url => attraction["venue"]["url"],
                                  :picture_id => picture.present? ? picture.id : nil)
        if new_attraction.save and picture
          picture.update_attributes(:attraction_id => new_attraction)
          picture.save
        end
      end
    rescue StandardError
      return false
    end
    return true

  end

end
