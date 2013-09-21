class DivvyDataPull < ActiveRecord::Base
  # attr_accessible :title, :body

  def talk_to_divvy(username, password)

    agent = Mechanize.new
    page = agent.get('https://divvybikes.com/login')
    login_form = page.form
    login_form.subscriberUsername = username
    login_form.subscriberPassword = password
    page = agent.submit(login_form)
    if page.link_with(:text => 'Trips').present?
      page = agent.page.link_with(:text => 'Trips').click
    else
      return "login-fail"
    end
    rows = page.search("tr")

    # Build data table to export to Google Drive if user requested it. 
    # if google_token != "none" 
    #   tmp_file = Tempfile.new("#{username}_divvytrips.csv")
    #   CSV.open(tmp_file, "ab") do |csv|
    #     csv << ["Start Station", "Start Date", "End Station", "End Date", "Duration"]
    #   end
    # end

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

    #   if google_token != "none" 
    #     unless start_station.blank? && end_station.blank?
    #       CSV.open(tmp_file, "ab") do |csv|
    #         csv << ["#{start_station}", "#{start_time}", "#{end_station}", "#{end_time}", "#{duration}"]
    #       end
    #     end
    #   end
    # end

    # if google_token != "none" 
    #   # Create a new API client & load the Google Drive API 
    #   client = Google::APIClient.new
    #   drive = client.discovered_api('drive', 'v2')

    #   # Request authorization
    #   client.authorization.client_id = ENV["GOOGLE_KEY"]
    #   client.authorization.client_secret = ENV["GOOGLE_SECRET"]
    #   client.authorization.scope = 'https://www.googleapis.com/auth/drive'
    #   client.authorization.redirect_uri = "http://www.divvybrags.com/#{username}"

    #   uri = client.authorization.authorization_uri
    #   Launchy.open(uri)

    #   # Exchange authorization code for access token
    #   $stdout.write  "Enter authorization code: "
    #   client.authorization.code = gets.chomp
    #   client.authorization.fetch_access_token!

    #   # Insert a file
    #   file = drive.files.insert.request_schema.new({
    #     'title' => 'My document',
    #     'description' => 'A test document',
    #     'mimeType' => 'text/plain'
    #   })

    #   media = Google::APIClient::UploadIO.new('document.txt', 'text/plain')
    #   result = client.execute(
    #     :api_method => drive.files.insert,
    #     :body_object => file,
    #     :media => media,
    #     :parameters => {
    #       'uploadType' => 'multipart',
    #       'alt' => 'json'})
    # end
    
    return(result.to_s)

  end
  handle_asynchronously :talk_to_divvy
  
end

# def insert_file(client, title, description, parent_id, mime_type, file_name)
#   drive = client.discovered_api('drive', 'v2')
#   file = drive.files.insert.request_schema.new({
#     'title' => title,
#     'description' => description,
#     'mimeType' => mime_type
#   })
#   # Set the parent folder.
#   if parent_id
#     file.parents = [{'id' => parent_id}]
#   end
#   media = Google::APIClient::UploadIO.new(file_name, mime_type)
#   result = client.execute(
#     :api_method => drive.files.insert,
#     :body_object => file,
#     :media => media,
#     :parameters => {
#       'uploadType' => 'multipart',
#       'alt' => 'json'})
#   if result.status == 200
#     return result.data
#   else
#     puts "An error occurred: #{result.data['error']['message']}"
#     return nil
#   end
# end

