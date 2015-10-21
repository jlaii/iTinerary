class Trip < ActiveRecord::Base
  has_many :attractions
  has_and_belongs_to_many :user
end
