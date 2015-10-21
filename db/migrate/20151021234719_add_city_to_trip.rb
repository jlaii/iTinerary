class AddCityToTrip < ActiveRecord::Migration
  def change
    add_column :trips, :city, :string
  end
end
