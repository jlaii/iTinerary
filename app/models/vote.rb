class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :trip_attraction
  validates_uniqueness_of :user_id, :scope => :trip_attraction_id
  validates :user_id, :trip_attraction_id, presence: true
end
