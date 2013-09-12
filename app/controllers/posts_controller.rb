class PostsController < ApplicationController
  require 'json'
  require 'httparty'
  require 'nokogiri'
  require 'mechanize'
  require 'rubygems'
  require 'csv'
  # /Users/alexsoble/.rvm/gems/ruby-1.9.3-p362/gems/google-api-client-0.6.4/
  # require 'google/api-client'
  require 'launchy'

  def talk_to_divvy(username, password, google_token)

    agent = Mechanize.new
    page = agent.get('https://divvybikes.com/login')
    login_form = page.form
    login_form.subscriberUsername = username
    login_form.subscriberPassword = password
    page = agent.submit(login_form)
    page = agent.page.link_with(:text => 'Trips').click
    rows = page.search("tr")

    # Build data table to export to Google Drive if user requested it. 
    if google_token != "none" 
      tmp_file = Tempfile.new("#{username}_divvytrips.csv")
      CSV.open(tmp_file, "ab") do |csv|
        csv << ["Start Station", "Start Date", "End Station", "End Date", "Duration"]
      end
    end

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

      if google_token != "none" 
        unless start_station.blank? && end_station.blank?
          CSV.open(tmp_file, "ab") do |csv|
            csv << ["#{start_station}", "#{start_time}", "#{end_station}", "#{end_time}", "#{duration}"]
          end
        end
      end
    end

    if google_token != "none" 
      # Create a new API client & load the Google Drive API 
      client = Google::APIClient.new
      drive = client.discovered_api('drive', 'v2')

      # Request authorization
      client.authorization.client_id = ENV["GOOGLE_KEY"]
      client.authorization.client_secret = ENV["GOOGLE_SECRET"]
      client.authorization.scope = 'https://www.googleapis.com/auth/drive'
      client.authorization.redirect_uri = "http://www.divvybrags.com/#{username}"

      uri = client.authorization.authorization_uri
      Launchy.open(uri)

      # Exchange authorization code for access token
      $stdout.write  "Enter authorization code: "
      client.authorization.code = gets.chomp
      client.authorization.fetch_access_token!

      # Insert a file
      file = drive.files.insert.request_schema.new({
        'title' => 'My document',
        'description' => 'A test document',
        'mimeType' => 'text/plain'
      })

      media = Google::APIClient::UploadIO.new('document.txt', 'text/plain')
      result = client.execute(
        :api_method => drive.files.insert,
        :body_object => file,
        :media => media,
        :parameters => {
          'uploadType' => 'multipart',
          'alt' => 'json'})
    end
    
    return(result.to_s)

  end

  def insert_file(client, title, description, parent_id, mime_type, file_name)
    drive = client.discovered_api('drive', 'v2')
    file = drive.files.insert.request_schema.new({
      'title' => title,
      'description' => description,
      'mimeType' => mime_type
    })
    # Set the parent folder.
    if parent_id
      file.parents = [{'id' => parent_id}]
    end
    media = Google::APIClient::UploadIO.new(file_name, mime_type)
    result = client.execute(
      :api_method => drive.files.insert,
      :body_object => file,
      :media => media,
      :parameters => {
        'uploadType' => 'multipart',
        'alt' => 'json'})
    if result.status == 200
      return result.data
    else
      puts "An error occurred: #{result.data['error']['message']}"
      return nil
    end
  end

  def create

    @username = params[:username]
    @password = params[:password]
    @google_token = params[:google_token]

    divvy_data = talk_to_divvy(@username, @password, @google_token)
    
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
