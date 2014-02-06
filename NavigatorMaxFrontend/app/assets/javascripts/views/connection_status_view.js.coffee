window.ConnectionStatusView = class 
  constructor: (dom_id) ->
    @dom_id = dom_id
    @frames_since_last_fps = 0
    @frames_per_second = 0
    @last_fps_update_at = new Date().getTime()
    @_is_connected = false
  
  is_connected: (flag = null) ->
    if flag?
      @_is_connected = flag
    else
      @_is_connected

  render: ->
    # FPS Calc
    now = new Date().getTime()

    if (now - @last_fps_update_at) > 1000
      @frames_per_second = @frames_since_last_fps
      @frames_since_last_fps = 1
      @last_fps_update_at = now
    else
      @frames_since_last_fps++

    conn_status = if @_is_connected then 'Connected' else 'Disconnected'
    $(@dom_id).html "#{conn_status} (#{@frames_per_second} fps)"

