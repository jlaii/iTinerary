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

  def next_attraction(tripattraction_id) #input tripattraction id
  	attraction = TripAttraction.find(tripattraction_id)
  	trip = Trip.find(attraction.trip_id)
  end

  # Returns the euclidean distance in Km between the two attractions by their coordinates
  def self.calculate_distance_euclidean(attraction_start, attraction_end)
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

  # Returns the manhattan distance in Km between the two attractions by their coordinates
  def self.calculate_distance_manhattan(attraction_start, attraction_end)
    lat1 = attraction_start.latitude * RAD_PER_DEG
    lon1 = attraction_start.longitude * RAD_PER_DEG
    lat2 = attraction_end.latitude * RAD_PER_DEG
    lon2 = attraction_end.longitude * RAD_PER_DEG
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a_lat = (Math.sin(dlat/2))**2
    c_lat = 2 * Math.atan2(Math.sqrt(a_lat), Math.sqrt(1-a_lat))
    d_lat = EARTH_R_KM * c_lat
    a_lon = Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon/2))**2
    c_lon = 2 * Math.atan2(Math.sqrt(a_lon), Math.sqrt(1-a_lon))
    d_lon = EARTH_R_KM * c_lon
    d_manhattan = d_lat + d_lon
    return d_manhattan
  end

  # Travel_speed is in Km/h
  # Euclidean distance is used
  # Return value: minutes required given the average travel speed
  def self.calculate_travel_time_euclidean(attraction_start, attraction_end, travel_speed)
    return calculate_distance_euclidean(attraction_start, attraction_end) / travel_speed * 60
  end

  # Travel_speed is in Km/h
  # Manhattan distance is used
  # Return value: minutes required given the average travel speed
  def self.calculate_travel_time_manhattan(attraction_start, attraction_end, travel_speed)
    return calculate_distance_manhattan(attraction_start, attraction_end) / travel_speed * 60
  end
end
