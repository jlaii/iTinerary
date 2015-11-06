class Trip < ActiveRecord::Base
  has_many :trip_attractions
  has_and_belongs_to_many :user
  validate :trip_date_validation
  RAD_PER_DEG = Math::PI/180
  EARTH_R_KM = 6371 # Radius of Earth in Km
  DRIVING_SPEED = 20 # km/hr
  VOTE_WEIGHT = 10
  TRAVEL_WEIGHT = -0.05
  FOURSQUARE_WEIGHT = 0.5
  NUM_ATTRACTIONS = 4
  SEC_PER_DAY = 86400

  def trip_date_validation
  	if self.start_time.to_i > self.end_time.to_i
  		errors[:base] << "start date must be prior to end date"
  	end
  end

  def generate_itinerary(city_name)
    had_lunch = false
    start_time = DateTime.new(self.start_time.year, self.start_time.month, self.start_time.day, 8)
    trip_attractions = TripAttraction.where(:trip_id => self.id).to_a
    city = City.find_by_name(city_name)
    curr_attraction = Attraction.new(:latitude => city.lat, :longitude => city.lng)
    itinerary = []
    for i in 1..NUM_ATTRACTIONS * ((self.end_time - self.start_time).to_i/SEC_PER_DAY + 1)
      trip_attraction_hash = self.get_next_trip_attraction(curr_attraction, trip_attractions, start_time)
      # logger.debug trip_attraction_hash
      break if trip_attraction_hash == false
      next_attraction = trip_attraction_hash[:trip_attraction]
      itinerary.append(next_attraction)
      trip_attractions.delete(next_attraction)
      curr_attraction = Attraction.find(next_attraction.attraction_id)
      start_time += 2.hours + trip_attraction_hash[:travel_time].minutes
      if start_time.hour >= 12 and not had_lunch
        lunch = TripAttraction.new(:lunch => true, :start_time => start_time, :end_time => start_time + 1.hour)
        itinerary.append(lunch)
        start_time += 1.hour
        had_lunch = true
      end
      if i % NUM_ATTRACTIONS == 0
        start_time = start_time.change({hour: 8})
        start_time += 1.days
        had_lunch = false
      end
    end
    return itinerary
  end

  def get_next_trip_attraction(prev_attraction, trip_attractions, start_time)
    best_score = -100000000
    best_attraction = nil
    best_travel_time = 0
    day_of_week = start_time.wday
    for trip_attraction in trip_attractions
      attraction = Attraction.find(trip_attraction.attraction_id)
      travel_time = Trip.calculate_travel_time_manhattan(prev_attraction, attraction, DRIVING_SPEED)
      score = trip_attraction.vote_count * VOTE_WEIGHT + travel_time * TRAVEL_WEIGHT + attraction.rating * FOURSQUARE_WEIGHT
      hour_minutes = start_time.hour * 100 + start_time.minute
      if score > best_score and attraction.is_open?(day_of_week, hour_minutes, hour_minutes + 200)
        best_score = score
        best_attraction = trip_attraction
        best_travel_time = travel_time
      end
    end
    return false if best_attraction.nil?
    best_attraction.update_attributes(:start_time => DateTime.new(start_time.year, start_time.month,
                                                                  start_time.day, start_time.hour, start_time.minute),
                                      :end_time => DateTime.new(start_time.year, start_time.month,
                                                                start_time.day, start_time.hour + 2, start_time.minute))
    best_attraction.save
    return {:trip_attraction => best_attraction, :travel_time => best_travel_time}
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
