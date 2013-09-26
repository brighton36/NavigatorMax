window.GpsMapView = class
  STATICMAP_URL = "http://maps.googleapis.com/maps/api/staticmap"

  GOOGLE_TILE_SIZE = 256
  INITIAL_RESOLUTION = 2 * Math.PI * 6378137 / GOOGLE_TILE_SIZE
  ORIGIN_SHIFT = 2 * Math.PI * 6378137 / 2.0
  
  # Since 640x640 is the max size that google static supports, we take the largest
  # 'even' alignment for our tiles
  RENDER_TILE_SIZE = 512

  constructor: (dom_id) ->
    @ctx = dom_id.getContext("2d")

    @zoom = 21
    @focus_latlon = [40.6892, -74.0447]

    @render_tiles = [] # TODO index by zoom level, tiles as a hash

    console.log "Canvas dimensions: #{@ctx.canvas.width}x#{@ctx.canvas.height}"

    @canvas_center = [Math.floor(@ctx.canvas.width/2), Math.floor(@ctx.canvas.height/2)]

    pixels = @latlon_to_pixels(@focus_latlon...)
   
    console.log "Center World Pixels X: #{pixels[0]} Y: #{pixels[1]}"

    console.log "UL Pixels X: #{pixels[0]-256} Y: #{pixels[1]+256}"
    console.log "LR Pixels X: #{pixels[0]+256} Y: #{pixels[1]-256}"

    right_meters = @pixels_to_meters(pixels[0]+256,pixels[1])
    right_latlon = @meters_to_latlon(right_meters...)

    @left_meters = @pixels_to_meters(pixels[0]-256,pixels[1])
    left_latlon = @meters_to_latlon(@left_meters...)

    # Note that the google origin is South West, and canvas origin is North West
    @bottom_meters = @pixels_to_meters(pixels[0],pixels[1]-256)
    bottom_latlon = @meters_to_latlon(@bottom_meters...)

    console.log "Right latlon : lat: #{right_latlon[0]} long: #{right_latlon[1]}"
    console.log "Top latlon : lat: #{bottom_latlon[0]} long: #{bottom_latlon[1]}"

    @markers = [ [40.6892,-74.0447], [40.6893,-74.0447], [40.6892,-74.0446], 
      [40.6891,-74.0447], [40.6892,-74.0448] ]
    marker_colors = ['brown', 'green', 'purple', 'yellow', 'blue', 'gray', 
      'orange']

    url_markers = $(@markers).map (i,n) => 
      @_google_marker(n[0], n[1], i, marker_colors[i])

    @background = new Image()
    @background.src = ["#{STATICMAP_URL}?center=#{@focus_latlon[0]},#{@focus_latlon[1]}",
      "zoom=#{@zoom}","size=#{512}x#{512}",'maptype=satellite', 'sensor=false',
      "format=png32",
      @_google_marker(bottom_latlon[0], bottom_latlon[1], 'B', 'red'),
      @_google_marker(right_latlon[0], right_latlon[1], 'R', 'red'),
      @_google_marker(left_latlon[0], left_latlon[1], 'L', 'red')
      ].concat($.makeArray(url_markers)).join('&')

    console.log @background.src
    @background.onload = -> @is_loaded = true

  render: () -> 
    @ctx.clear()
    # TODO: We should have some kind of grid to display if our background tiles 
    # aren't loaded/available
    @ctx.drawImage(@background, @canvas_center[0]-RENDER_TILE_SIZE/2, @canvas_center[1]-RENDER_TILE_SIZE/2) if @background.is_loaded

    for marker in @markers
      canvas_coords = @_latlon_to_canvas( marker... )
      # TODO: clip testing (is x < 0 or > width-1) same for y
      @_circle 6, 'black', canvas_coords...

  _latlon_to_canvas: (lat, lon) ->
    viewport_ul_pixels = @_viewport_ul_to_pixels()

    pixels = @latlon_to_pixels lat, lon

    [ pixels[0]-viewport_ul_pixels[0], pixels[1]-viewport_ul_pixels[1] ]

  _google_marker: (lat, lon, label, color) ->
    "markers=color:#{color}%7Clabel:#{label}%7C#{lat},#{lon}"

  _circle: (diameter, color, x,y) ->
    @ctx.beginPath()
    @ctx.arc(x,y,diameter, 0, 2 * Math.PI, false)
    @ctx.lineWidth = 4
    @ctx.strokeStyle = 'white'
    @ctx.stroke()
    @ctx.beginPath()
    @ctx.arc(x,y,diameter, 0, 2 * Math.PI, false)
    @ctx.lineWidth = 1
    @ctx.strokeStyle = color
    @ctx.stroke()

  _resolution: (zoom) ->
    # "Resolution (meters/pixel) for given zoom level (measured at Equator)"
    INITIAL_RESOLUTION / Math.pow(2, zoom)

  # Upper-right corner of the viewport, in google pixels:
  _viewport_ul_to_pixels: ->
    # TODO: Test!
    focus_in_pixels = @latlon_to_pixels(@focus_latlon...)
    [ focus_in_pixels[0] - @canvas_center[0], focus_in_pixels[1] - @canvas_center[1] ]

  # Lower-right corner of the viewport, in google pixels:
  _viewport_lr_to_pixels: ->
    # TODO: Test!
    focus_in_pixels = @latlon_to_pixels(@focus_latlon...)

    [ focus_in_pixels[0] + @ctx.canvas.width - @canvas_center[0], 
      focus_in_pixels[1] - @ctx.canvas.height - @canvas_center[1] ]

  latlon_to_meters: (lat, lon) ->
    # "Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"
    mx = lon * ORIGIN_SHIFT / 180.0
    my = Math.log( Math.tan((90 + lat) * Math.PI / 360.0 )) / (Math.PI / 180.0)

    my = my * ORIGIN_SHIFT / 180.0
    [mx, my]

  meters_to_pixels: (mx, my) ->
    #"Converts EPSG:900913 to pyramid pixel coordinates in given zoom level"
    res = @_resolution @zoom
    px = (mx + ORIGIN_SHIFT) / res
    py = (my + ORIGIN_SHIFT) / res
    [ px, py ]

  latlon_to_pixels: (lat, lon) ->
    @meters_to_pixels @latlon_to_meters(lat,lon)...

  pixels_to_meters: (px, py) ->
    #"Converts pixel coordinates in given zoom level of pyramid to EPSG:900913"
    res = @_resolution @zoom
    mx = px * res - ORIGIN_SHIFT
    my = py * res - ORIGIN_SHIFT
    [mx, my]

  meters_to_latlon: (mx, my) ->
    # "Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum"
    lon = (mx / ORIGIN_SHIFT) * 180.0
    lat = (my / ORIGIN_SHIFT) * 180.0

    lat = 180 / Math.PI * (2 * Math.atan(Math.exp(lat * Math.PI / 180.0)) - Math.PI / 2.0)
    [lat, lon]

  pixels_to_latlon: (px, py) ->
    @meters_to_latlon @pixels_to_meters(px,py)...

