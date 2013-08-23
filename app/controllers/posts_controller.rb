class PostsController < ApplicationController
  require 'json'
  require 'httparty'
  require 'nokogiri'
  require 'mechanize'

  def talk_to_divvy(username, password)

    agent = Mechanize.new
    page = agent.get('https://divvybikes.com/login')
    login_form = page.form
    login_form.subscriberUsername = username
    login_form.subscriberPassword = password
    page = agent.submit(login_form)
    page = agent.page.link_with(:text => 'Trips').click
    rows = page.search("tr")

    result = []
    rows.each do |r|
      tds = r.xpath('td')

      if tds[1].present? then start_station = tds[1].text else start_station = '' end
      if tds[2].present? then start_time = tds[2].text else start_time = '' end
      if tds[3].present? then end_station = tds[3].text else end_station = '' end
      if tds[4].present? then end_time = tds[4].text else end_time = '' end
      if tds[5].present? then duration = tds[5].text else duration = 0 end


      data = "{ \"start_station\" : \"#{start_station}\", \"start_time\" : \"#{start_time}\", \"end_station\" : \"#{end_station}\", \"end_time\" : \"#{end_time}\", \"duration\" : \"#{duration}\" }"

      result << data

    end

    return(result.to_s)
    
  end

  def create

    @username = params[:username]
    @password = params[:password]

    divvy_data = talk_to_divvy(@username, @password)
    
    @raw_trips = JSON.parse(divvy_data)
    @trips = []

    @raw_trips.each do |t|
      @parsed_trip = JSON.parse(t)
      @trips << @parsed_trip
    end
    
    @number_of_trips = @trips.length - 1
    @first_trip_date = @trips.first["start_time"]

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

    @distances = []
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

      @distance += this_distance

    end

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
        redirect_to post_url(p)
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

    redirect_to post_url(@post)

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

  end 

end
