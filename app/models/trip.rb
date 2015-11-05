class Trip < ActiveRecord::Base
  has_many :trip_attractions
  has_and_belongs_to_many :user
  validate :trip_date_validation
  RAD_PER_DEG = Math::PI/180
  EARTH_R_KM = 6371 # Radius of Earth in Km
  DRIVING_SPEED = 40 # km/hr
  VOTE_WEIGHT = 1
  TRAVEL_WEIGHT = 0.01
  FOURSQUARE_WEIGHT = 0.3

  def trip_date_validation
  	if self.start_time.to_i > self.end_time.to_i
  		errors[:base] << "start date must be prior to end date"
  	end
  end

  def generate_itinerary
    start_time = 800
    attractions = create_attractions(params)
    city = City.find_by_name(params[:city])
    curr_attraction = Attraction.new(:latitude => city.lat, :longitude => city.lng)
    vote_hash = create_vote_hash()
    for i in 0...5
      trip_attraction_hash = self.get_next_trip_attraction(curr_attraction, attractions, start_time, vote_hash)
      attractions.delete(trip_attraction_hash[:trip_attraction].attraction_id)
      curr_attraction = next_attraction
      start_time += 200 + trip_attraction_hash[:travel_time]
    end
    return itinerary
  end

  def get_next_trip_attraction(prev_attraction, attractions, start_time,  vote_hash)
    best_score = -1
    best_attraction = nil
    for attraction in attractions
      travel_time = Trip.calculate_travel_time_manhattan(prev_attraction, attraction, DRIVING_SPEED)
      score = vote_hash[attraction] * VOTE_WEIGHT + travel_time * TRAVEL_WEIGHT + attraction.rating * FOURSQUARE_WEIGHT
      if score > best_score and attraction.is_open?(INSERT_DAY, start_time, start_time + 200)
        best_score = score
        best_attraction = attraction
      end
    end
    trip_attraction = TripAttraction.new(:start_time => start_time, :end_time => start_time + 200,
                                         :attraction_id => best_attraction.id,
                                         :vote_count => vote_hash[best_attraction.id], :trip_id => self.id)
    trip_attraction.save
    {:trip_attraction => trip_attraction, :travel_time => travel_time}




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
