class AddLunchToTripAttractions < ActiveRecord::Migration
  def change
    add_column :trip_attractions, :lunch, :boolean
  end
end
