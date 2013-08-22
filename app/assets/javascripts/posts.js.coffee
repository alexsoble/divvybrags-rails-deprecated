$ -> 

  number_of_trips = $('#number-of-trips').text()
  hours = $('#hours').text()
  minutes = $('#minutes').text()
  seconds = $('#seconds').text()
  miles = $('#miles').text()

  $('#tweet-it').click ->
    window.location.href = "https://twitter.com/share?text=#{number_of_trips}%20trips.%20#{hours}%20hours,%20#{minutes}%20minutes,%20#{seconds}%20seconds.%20#{miles}%20miles.&hashtags=DivvyBrag"

  $('#email-it').click ->
    window.location.href = "mailto:friend@gmail.com?Subject=Divvy&body=#{number_of_trips}%20trips.%0A%0A#{hours}%20hours,%20#{minutes}%20minutes,%20#{seconds}%20seconds.%0A%0A#{miles}%20miles.%0A%0A#{document.URL}%0A%0A#DivvyBrag"

  $('#update-it').click ->
    window.location.href = "/home"