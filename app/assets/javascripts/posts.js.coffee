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

  unless $('.date').attr('data-dates') == "none"

    date_array = []
    milage_array = []
    additive_array = [0]

    $('.date').each(->
      date_array.push $(this).attr('data-date')
      milage_array.push parseFloat($(this).attr('data-miles'))
      more_miles = parseFloat($(this).attr('data-miles')) + additive_array[additive_array.length - 1]
      more_miles_rounded = (Math.round(more_miles * 10)) / 10
      additive_array.push more_miles_rounded
    )
    additive_array.shift()

    $('#container').highcharts({
        chart: { type: 'column' },
        title: { text: 'Divvygraph' },
        xAxis: { 
          categories: date_array,
          labels: { maxStaggerLines: 1, rotation: 315, step: 4 },
          showFirstLabel: false
          showLastLabel: false
          },
        yAxis: [
          { 
            title: { text: 'Miles This Day', style: { color: '#3DB7E4' } }, 
            labels: { style: { color: '#3DB7E4' } },
          }
          { 
            title: { text: 'Total Miles Divvied', style: { color: '#FF7518' } }, 
            labels: { style: { color: '#FF7518' } },
            opposite: true,
            min: 0
          }
        ]
        series: [   
          { type: 'column', name: 'Miles This Day', data: milage_array, color: '#3DB7E4'}
          { type: 'spline', name: 'Total Miles', data: additive_array, color: '#FF7518', yAxis: 1 },
        ],
        credits: false
    })