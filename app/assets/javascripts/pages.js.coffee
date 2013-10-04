$ ->

  $('#password').attr('autocomplete','off')

  $('#google-drive').click ->
    window.location.href = "/authorize"

  window.click_counter = 0
  window.tip_memory = ''
  $('img').hide()

  $('.game-box').click ->
    window.click_counter += 1
    console.log window.click_counter
    if window.click_counter < 3
      this_box = $(this)
      if this_box.hasClass('covered')
        this_box.removeClass('covered')
        this_box.children(':first').show()
        id = this_box.children(':first').attr('id')
        if window.tip_memory == id
          $('#win-status').html('Match!')
        window.tip_memory = id
        if id == 'waterbottle'
          $('#message').html("Don't forget to stay hydrated!")
        if id == 'ridedefensive'
          $('#message').html("Ride defensively.")
        if id == 'layers'
          $('#message').html("Remember to wear layers!")
        if id == 'stretch'
          $('#message').html("Warm up your muscles. Stretch.")
        if id == 'goggles'
          $('#message').html("Keep snow out of your eyes.")
        if id == 'longunderwear'
          $('#message').html("Long underwear is key.")
        if id == 'gloves'
          $('#message').html("You're gonna need gloves.")
        if id == 'woolsocks'
          $('#message').html("Wear wool socks.")
      else
        this_box.addClass('covered')
        this_box.children(':first').hide()
        $('#win-status').html('')
        window.tip_memory = ''
    else
      $('.game-box').addClass('covered')
      $('img').hide()
      window.click_counter = 0
      $('#win-status').html('')
      window.tip_memory = ''