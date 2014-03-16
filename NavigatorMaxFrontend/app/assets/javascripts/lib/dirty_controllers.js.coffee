window.Controller = class
  constructor: ->
  on_connect: (ws) -> 
  on_disconnect: -> 
  on_message: (data) ->
    switch data.request.commandid
      when 'state'
        @tick data.result
      when 'attributes'
        @set_metadata data.result
