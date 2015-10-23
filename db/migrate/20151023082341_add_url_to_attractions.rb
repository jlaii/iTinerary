class AddUrlToAttractions < ActiveRecord::Migration
  def change
    add_column :attractions, :url, :string
  end
end
