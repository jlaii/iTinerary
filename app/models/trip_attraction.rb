class TripAttraction < ActiveRecord::Base
  belongs_to :trips
  has_one :attractions
  has_many :votes

  def self.save_trip_attraction(attraction, trip_id)
  	trip_attraction = self.new(:trip_id => trip_id, :attraction_id => attraction.id)
  	trip_attraction.save
  end
end
