class CreateTripAttractions < ActiveRecord::Migration
  def change
    create_table :trip_attractions do |t|
      t.integer :trip_id
      t.integer :attraction_id
      t.datetime :start_time
      t.datetime :end_time
      t.integer :vote_count

      t.timestamps null: false
    end
  end
end
