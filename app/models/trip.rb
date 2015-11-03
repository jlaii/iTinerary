class Trip < ActiveRecord::Base
  has_many :trip_attractions
  has_and_belongs_to_many :user
  validate :trip_date_validation

  def trip_date_validation
  	if self.start_time.to_i > self.end_time.to_i
  		errors[:base] << "start date must be prior to end date"
  	end
  end

  def next_attraction(tripattraction_id) #input tripattraction id
  	attraction = TripAttraction.find(tripattraction_id)
  	trip = Trip.find(attraction.trip_id)
  end

end
