$(document).ready ->
  $('.secret-cell').on 'click', (e) ->
    secret = $(@).attr('data-secret')
    obfuscation = '************************************'
    current_value = $(@).html().replace(/\s/g, '')

    if current_value == obfuscation
      $(@).html secret
    else
      $(@).html obfuscation

    return
