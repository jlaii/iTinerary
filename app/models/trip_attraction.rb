class TripAttraction < ActiveRecord::Base
  belongs_to :trip
  has_one :attraction
end
