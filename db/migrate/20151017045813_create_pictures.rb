class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.integer :attraction_id
      t.string :path

      t.timestamps null: false
    end
  end
end
