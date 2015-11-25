class AddUuidToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :uuid, :string
  end
end
