class AddHoursJsonToAttractions < ActiveRecord::Migration
  def change
    add_column :attractions, :hours_json, :json
  end
end
