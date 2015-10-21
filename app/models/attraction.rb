class Attraction < ActiveRecord::Base
  has_many :pictures
  has_and_belongs_to_many :trips
end
