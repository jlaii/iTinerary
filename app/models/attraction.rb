class Attraction < ActiveRecord::Base
  has_many :pictures
  validates :name, presence: true


end
