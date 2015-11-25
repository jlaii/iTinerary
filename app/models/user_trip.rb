class UserTrip < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => :trip_id
end
