class PostsController < ApplicationController
  require 'json'
  require 'csv'

  def create

    @raw_trips = JSON.parse(divvy_data)
    @trips = []

    @raw_trips.each do |t|
      @parsed_trip = JSON.parse(t)
      @trips << @parsed_trip
    end
    
    @number_of_trips = @trips.length - 1
    @first_trip_date = @trips[1]["start_time"]

    time_in_seconds = 0
    @trips.each do |t|

      unless t["duration"] == nil
    
        duration = t["duration"].split
        logger.debug "DURATION: #{duration}"
        duration.each do |d|

          if d.count('h') != 0
            time_in_seconds += d.strip.chomp.to_i * 3600
          end

          if d.count('m') != 0
            time_in_seconds += d.strip.chomp.to_i * 60
          end

          if d.count('s') != 0
            time_in_seconds += d.strip.chomp.to_i
          end

        end

      end

    end

    @total_hours = time_in_seconds / 3600
    @total_minutes = (time_in_seconds % 3600) / 60
    @total_seconds = (time_in_seconds % 3600) % 60 

    Day.where(:username => @username).destroy_all
    @day_logger = []
    @distance = 0

    @trips.each do |t|

      starting_point = t['start_station'].gsub("&"," and ").gsub(" ","+") + " Chicago, IL, USA"
      logger.debug "START STATION: #{starting_point}"

      ending_point = t['end_station'].gsub("&"," and ").gsub(" ","+") + " Chicago, IL, USA"
      logger.debug "END STATION: #{ending_point}"

      google_url = "http://maps.googleapis.com/maps/api/distancematrix/json?origins=#{starting_point}&destinations=#{ending_point}&sensor=false&mode=bicycling&units=imperial"
      encoded_google_url = URI.encode(google_url)
      google_response = HTTParty.get(encoded_google_url)
      response = JSON.parse(google_response.body)
      @start_address = response["destination_addresses"].first
      @end_address = response["origin_addresses"].first
      this_distance = response["rows"].first["elements"].first["distance"]["text"].gsub("mi","").gsub(" ","").to_f
      logger.debug "this_distance= " + "#{this_distance}"

      unless this_distance > 20
        @distance += this_distance

        if t["start_time"].present?
          @date = Date.strptime(t["start_time"], "%m/%d/%y")

          if Day.where(:username => @username, :this_date => @date).present?
            d = Day.where(:username => @username, :this_date => @date).first
            d.miles += this_distance
            d.save
          
          else
            Day.create(
              this_date: @date,
              miles: this_distance,
              username: @username)

          end 
        end
      end
    end
    logger.debug "DAY LOGGER: #{@day_logger}"

    @distance = @distance.to_i

    Post.all.each do |p|

      # Check if this username is already in the system; if so, update values.

      if p.username == @username
        p.update_attributes(
          total_hours: @total_hours,
          total_minutes: @total_minutes,
          total_seconds: @total_seconds,
          distance: @distance,
          number_of_trips: @number_of_trips,
          first_trip_date: @first_trip_date
          )
        redirect_to "/#{@username}"
        return
      end
    end

    # If the user's new, create a new post for her/him.

    @post = Post.create(
      username: @username,
      total_hours: @total_hours,
      total_minutes: @total_minutes,
      total_seconds: @total_seconds,
      distance: @distance,
      number_of_trips: @number_of_trips,
      first_trip_date: @first_trip_date
      )

    redirect_to "/#{@username}"

  end

  def show

    if params[:id].present?
      @post = Post.find_by_id(params[:id])
    end
    
    if params[:username].present?
      @post = Post.find_by_username(params[:username])
    end

    @username = @post.username
    @total_hours = @post.total_hours
    @total_minutes = @post.total_minutes
    @total_seconds = @post.total_seconds
    @distance = @post.distance
    @number_of_trips = @post.number_of_trips
    @updated_at = @post.updated_at.strftime("%m/%e/%y")
    @first_trip_date = @post.first_trip_date

    @day_logger = Day.where(:username => @username).all.sort { |a, b| a.this_date <=> b.this_date }

    if @day_logger.present? 
      @first_day = @day_logger.first.this_date
      @last_day = @day_logger.last.this_date

      all_the_days = []
      day = @first_day
      while day <= @last_day
        all_the_days << day
        day = day.next_day
      end 
      @all_the_days = all_the_days

      @all_the_days_with_trips = []
      @day_logger.each do |day|
        @all_the_days_with_trips << day.this_date
      end

    end

    # CO2 calculations based on this EPA factsheet: http://www.epa.gov/otaq/climate/documents/420f11041.pdf
    # @distance is in miles, so @distance * 0.432 yields kg of CO2 released by a car over the equivalent distance
    # Multiplying that by ~2.20 gives us lbs of CO2 released by a car over the equivalent distance
    @co2_saved = (@distance * 0.432 * 2.20462).to_i

  end 

end
