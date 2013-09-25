window.GpsMapView = class
  STATICMAP_URL = "http://maps.googleapis.com/maps/api/staticmap"

  TILE_SIZE = 256
  INITIAL_RESOLUTION = 2 * Math.PI * 6378137 / TILE_SIZE
  ORIGIN_SHIFT = 2 * Math.PI * 6378137 / 2.0

  constructor: (dom_id) ->
    @ctx = dom_id.getContext("2d")

    @zoom = 21
    longitude = 40.6892
    latitude = -74.0447

    # Dont forget you have to convert your projection to EPSG:900913
    meters = @latlon_to_meters longitude, latitude
    console.log meters
    mx = meters[0]  # 40.714728
    my = meters[1] #-73.998672

    pixels = @meters_to_pixels(mx, my, @zoom)
    #meter = @latlon_to_meters(pixels[0], pixels[1])
    console.log "X: #{pixels[0]} Y: #{pixels[1]}"

    right_meters = @pixels_to_meters(pixels[0]+256,pixels[1], @zoom)
    right_latlon = @meters_to_latlon(right_meters[0], right_meters[1])

    @left_meters = @pixels_to_meters(pixels[0]-256,pixels[1], @zoom)
    left_latlon = @meters_to_latlon(@left_meters[0], @left_meters[1])

    # Note that the google origin is South West, and canvas origin is North West
    @bottom_meters = @pixels_to_meters(pixels[0],pixels[1]-256, @zoom)
    bottom_latlon = @meters_to_latlon(@bottom_meters[0], @bottom_meters[1])

    console.log "Right latlon : lat: #{right_latlon[0]} long: #{right_latlon[1]}"
    console.log "Top latlon : lat: #{bottom_latlon[0]} long: #{bottom_latlon[1]}"

    @markers = [ [40.6892,-74.0447], [40.6893,-74.0447], [40.6892,-74.0446], 
      [40.6891,-74.0447], [40.6892,-74.0448] ]
    marker_colors = ['brown', 'green', 'purple', 'yellow', 'blue', 'gray', 
      'orange']

    url_markers = $(@markers).map (i,n) => 
      @_google_marker(n[0], n[1], i, marker_colors[i])

    @background = new Image()
    @background.src = ["#{STATICMAP_URL}?center=#{longitude},#{latitude}",
      "zoom=#{@zoom}","size=#{512}x#{512}",'maptype=satellite', 'sensor=false',
      @_google_marker(bottom_latlon[0], bottom_latlon[1], 'B', 'red'),
      @_google_marker(right_latlon[0], right_latlon[1], 'R', 'red'),
      @_google_marker(left_latlon[0], left_latlon[1], 'L', 'red')
      ].concat($.makeArray(url_markers)).join('&')

    console.log @background.src
    @background.onload = -> @is_loaded = true

  render: () -> 
    @ctx.clear()
    @ctx.drawImage(@background, 0, 0) if @background.is_loaded
    @_circle(256,256,6,'green')
    @_circle(512,256,6,'blue')

    left_pixels = @meters_to_pixels @left_meters[0], @left_meters[1], @zoom
    bottom_pixels = @meters_to_pixels @bottom_meters[0], @bottom_meters[1], @zoom
    for marker in @markers
      meters = @latlon_to_meters marker[0], marker[1]
      pixels = @meters_to_pixels(meters[0], meters[1], @zoom)
      @_circle(pixels[0] - left_pixels[0], pixels[1] - bottom_pixels[1],6,'black')

  _google_marker: (lat, lon, label, color) ->
    "markers=color:#{color}%7Clabel:#{label}%7C#{lat},#{lon}"

  _circle: (x,y,diameter, color) ->
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

  resolution: (zoom) ->
    # "Resolution (meters/pixel) for given zoom level (measured at Equator)"
    INITIAL_RESOLUTION / Math.pow(2, zoom)

  latlon_to_meters: (lat, lon) ->
    # "Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"

    mx = lon * ORIGIN_SHIFT / 180.0
    my = Math.log( Math.tan((90 + lat) * Math.PI / 360.0 )) / (Math.PI / 180.0)

    my = my * ORIGIN_SHIFT / 180.0
    [mx, my]

  meters_to_pixels: (mx, my, zoom) ->
    #"Converts EPSG:900913 to pyramid pixel coordinates in given zoom level"
    res = @resolution zoom
    px = (mx + ORIGIN_SHIFT) / res
    py = (my + ORIGIN_SHIFT) / res
    [ px, py ]

  pixels_to_meters: (px, py, zoom) ->
    #"Converts pixel coordinates in given zoom level of pyramid to EPSG:900913"
    res = @resolution(zoom)
    mx = px * res - ORIGIN_SHIFT
    my = py * res - ORIGIN_SHIFT
    [mx, my]

  meters_to_latlon: (mx, my) ->
    # "Converts XY point from Spherical Mercator EPSG:900913 to lat/lon in WGS84 Datum"
    lon = (mx / ORIGIN_SHIFT) * 180.0
    lat = (my / ORIGIN_SHIFT) * 180.0

    lat = 180 / Math.PI * (2 * Math.atan(Math.exp(lat * Math.PI / 180.0)) - Math.PI / 2.0)
    [lat, lon]

