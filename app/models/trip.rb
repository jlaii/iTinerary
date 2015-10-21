class Trip < ActiveRecord::Base
  has_many :attractions
  belongs_to :user
end
