class Trip < ActiveRecord::Base
  has_many :trip_attractions
  has_and_belongs_to_many :user
  validate :trip_date_validation
  RAD_PER_DEG = Math::PI/180
  EARTH_R_KM = 6371 # Radius of Earth in Km

  def trip_date_validation
  	if self.start_time.to_i > self.end_time.to_i
  		errors[:base] << "start date must be prior to end date"
  	end
  end


  def self.calculate_distance(attraction_start, attraction_end)
    lat1 = attraction_start.latitude * RAD_PER_DEG
    lon1 = attraction_start.longitude * RAD_PER_DEG
    lat2 = attraction_end.latitude * RAD_PER_DEG
    lon2 = attraction_end.longitude * RAD_PER_DEG
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = (Math.sin(dlat/2))**2 + (Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon/2))**2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    d = EARTH_R_KM * c
    return d
  end

  # travel_speed is in Km/h
  def self.calculate_travel_time(attraction_start, attraction_end, travel_speed)
    return calculate_distance(attraction_start, attraction_end) / travel_speed * 60
    # lat1 = attraction_start.latitude * RAD_PER_DEG
    # lon1 = attraction_start.longitude * RAD_PER_DEG
    # lat2 = attraction_end.latitude * RAD_PER_DEG
    # lon2 = attraction_end.longtitude * RAD_PER_DEG
    # dlat = lat2 - lat1
    # dlon = lon2 - lon1
    # a = (Math.sin(dlat/2))**2 + (Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon/2))**2)
    # c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    # d = EARTH_R_KM * c
    # minutes = d / travel_speed * 60
    # return minutes
  end
end
