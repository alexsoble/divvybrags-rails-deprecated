class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :total_hours
      t.integer :total_minutes
      t.integer :total_seconds
      t.integer :number_of_trips
      t.integer :distance
      t.string :username

      t.timestamps
    end
  end
end
