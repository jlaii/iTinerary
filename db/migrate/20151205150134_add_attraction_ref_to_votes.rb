class AddAttractionRefToVotes < ActiveRecord::Migration
  def change
    add_reference :votes, :attraction, index: true, null: false
  end
end
