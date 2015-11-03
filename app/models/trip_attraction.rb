class TripAttraction < ActiveRecord::Base
  belongs_to :trip
  has_one :attraction

  def self.save_trip_attraction(attraction, trip_id)
  	trip_attraction = self.new(:trip_id => trip_id, :attraction_id => attraction.id)
  	trip_attraction.save
  end
end
