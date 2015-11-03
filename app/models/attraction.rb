class Attraction < ActiveRecord::Base
  has_many :pictures
  validates :name, presence: true


  def self.import_foursquare_attractions(city, num_attractions = 50)
    begin
      base_url = "https://api.foursquare.com/v2/venues/explore?"
      auth_string = "client_id=#{FOURSQUARE_CLIENT_ID}&client_secret=#{FOURSQUARE_CLIENT_SECRET}&v=20151021"
      query_string = "&section=sights&limit=#{num_attractions}&radius=50000&venuePhotos=1&near=#{city}"
      request_url = base_url + auth_string + query_string
      response = JSON.parse(HTTParty.get(request_url).body)
      attractions = response["response"]["groups"].first["items"]
      for attraction in attractions
        attraction_hours_url = "https://api.foursquare.com/v2/venues/#{attraction["venue"]["id"]}/hours?#{auth_string}"
        attraction_hours_response = JSON.parse(HTTParty.get(attraction_hours_url).body)["response"]

        picture_path = attraction["venue"]["featuredPhotos"]["items"].first["prefix"] + "240x240" +
                       attraction["venue"]["featuredPhotos"]["items"].first["suffix"]
        picture = Picture.new(:path => picture_path)
        picture = picture.save ? picture : nil
        new_attraction = self.new(:name => attraction["venue"]["name"],
                                  :city => city,
                                  :category => attraction["venue"]["categories"].first["name"],
                                  :description => attraction["tips"].first["text"],
                                  :address => attraction["venue"]["location"]["formattedAddress"].join(", "),
                                  :latitude => attraction["venue"]["location"]["lat"],
                                  :longitude => attraction["venue"]["location"]["lng"],
                                  :rating => attraction["venue"]["rating"],
                                  :url => attraction["venue"]["url"],
                                  :picture_id => picture.present? ? picture.id : nil,
                                  :hours_json => attraction_hours_response)
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

  #day: int representing Mon-Sun as an int (1-7)
  #start_time: "0800"
  #end_time: "1600"
  def is_open(day, start_time, end_time)
    hours = self.hours_json["hours"]

  end

end
