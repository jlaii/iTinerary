class CreateUserTrips < ActiveRecord::Migration
  def change
    create_table :user_trips do |t|
      t.integer :user_id, :null => false
      t.integer :trip_id, :null => false

      t.timestamps null: false
    end
  end
end
