class AddFirstTripDateToPost < ActiveRecord::Migration
  def change
    add_column :posts, :first_trip_date, :string
  end
end
