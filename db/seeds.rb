# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create([{first_name: 'Apple', last_name: 'Banana', email: 'apple@banana.com'}])
User.create([{first_name: 'Orange', last_name: 'Grape', email: 'orange@grape.com'}])

Trip.create([{name: 'Best Trip Ever 1', note: 'hopefully this will be a good trip! :x', user_id: 1}])


# 5.times do |i|
#   Product.create(name: "Product ##{i}", description: "A product.")
# end