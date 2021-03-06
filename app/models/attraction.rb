require 'Foursquare'
class Attraction < ActiveRecord::Base
  has_many :pictures
  has_many :votes
  validates :name, presence: true


  def self.import_foursquare_attractions(city, num_attractions = 50, trip_id = nil)
    begin
      response = JSON.parse(Foursquare.import_attractions(city, num_attractions))

      attractions = response["response"]["groups"].first["items"]
      if attractions.length == 0
        return false
      end
      new_city = City.new(:name => city.titleize, :lat => response["response"]["geocode"]["center"]["lat"],
                          :lng => response["response"]["geocode"]["center"]["lng"])
      new_city.save
      for attraction in attractions

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

  #day: int representing Mon-Sun as an int (1-7)
  #start_time: int, e.g. 0800
  #end_time: int, e.g. 1600
  def is_open?(day, start_time, end_time)
    in_timeframe? day, start_time, end_time, "hours"
  end

  def num_hours_popular(start_time)
    count = 0
    hour_minutes = start_time.hour * 100 + start_time.minute
    if in_timeframe? start_time.wday, hour_minutes, hour_minutes + 100, "popular"
      count += 1
    end
    if in_timeframe? start_time.wday, hour_minutes + 100, hour_minutes + 200, "popular"
      count += 1
    end
    return count
  end

  def in_timeframe?(day, start_time, end_time, hours_type)
    #hours_json format: https://developer.foursquare.com/docs/explore#req=venues/40a55d80f964a52020f31ee3/hours
    if self.hours_json.nil?
      self.import_hours_json
    end
    if self.hours_json[hours_type].nil?
      if hours_type == "hours"
        return true
      else
        return false
      end

    end
    timeframes = self.hours_json[hours_type]["timeframes"]
    if timeframes.nil?
      if hours_type == "hours"
        return true
      else
        return false
      end
    end

    for timeframe in timeframes
      if timeframe["days"].include? day
        for open_time in timeframe["open"]
          # is open all day
          if open_time["start"] == "0000" and open_time["end"] == "+0000"
            return true
          end
          frame_start = open_time["start"].to_i
          frame_end = open_time["end"] == "+0000" ? 2400 : open_time["end"].to_i
          if frame_start <= start_time and frame_end >= end_time
            return true
          end
        end
      end
    end
    return false

  end

  def import_hours_json
    attraction_hours_response = JSON.parse(Foursquare.import_hours(self))["response"]
    self.update_attributes(:hours_json => attraction_hours_response)
    self.save
  end

end
