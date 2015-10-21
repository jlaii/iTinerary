class AddTripIdToAttractions < ActiveRecord::Migration
  def change
    add_column :attractions, :trip_id, :integer
  end
end
