class Post < ActiveRecord::Base
  attr_accessible :distance, :number_of_trips, :total_hours, :total_minutes, :total_seconds, :username, :first_trip_date
end
