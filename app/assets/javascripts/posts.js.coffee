$ -> 

  number_of_trips = $('#number-of-trips').text()
  hours = $('#hours').text()
  minutes = $('#minutes').text()
  seconds = $('#seconds').text()
  miles = $('#miles').text()
  co2 = $('#co-two').text()

  $('#tweet-it').click ->
    window.location.href = "https://twitter.com/share?text=#{number_of_trips}%20trips.%20#{hours}%20hours,%20#{minutes}%20minutes,%20#{seconds}%20seconds.%20#{miles}%20miles.&hashtags=DivvyBrag"

  $('#update-it').click ->
    window.location.href = "/home"

  $.getScript "https://www.google.com/jsapi", (data, textStatus) ->
      google.load "visualization", "1.0",
        packages: ["corechart"]
        callback: ->

          data = new google.visualization.DataTable()
          data.addColumn('string', 'Day')
          data.addColumn('number', 'Miles')

          $('.date').each(->
            data.addRows([[$(this).attr('data-date'), parseFloat($(this).attr('data-miles'))]])
          )

          options = {'title':'My Divvy Rides','width':620,'height':400}

          chart = new google.visualization.ColumnChart(document.getElementById('chart_div'))
          chart.draw(data, options)