class CreateVotes < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.belongs_to :user, :trip_attraction, index: true, null: false
      t.integer :vote, :null => false

      t.timestamps null: false
    end
  end
end
