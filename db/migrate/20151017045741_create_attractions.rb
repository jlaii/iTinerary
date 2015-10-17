class CreateAttractions < ActiveRecord::Migration
  def change
    create_table :attractions do |t|
      t.string :name
      t.string :city
      t.string :category
      t.string :description
      t.string :address
      t.float :latitude
      t.float :longitude
      t.float :rating
      t.integer :picture_id
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps null: false
    end
  end
end
