class AddNoteToTrips < ActiveRecord::Migration
  def change
    add_column :trips, :note, :string
  end
end
