$ ->

  $('#password').attr('autocomplete','off')

  $('#google-drive').click ->
    window.location.href = "/authorize"