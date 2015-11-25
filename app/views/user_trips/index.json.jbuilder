json.array!(@user_trips) do |user_trip|
  json.extract! user_trip, :id, :user_id, :trip_id
  json.url user_trip_url(user_trip, format: :json)
end
