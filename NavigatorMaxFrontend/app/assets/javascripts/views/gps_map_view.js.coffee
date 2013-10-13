window.GpsMapView = class
  STATICMAP_URL = "http://maps.googleapis.com/maps/api/staticmap"

  GOOGLE_TILE_SIZE = 256
  INITIAL_RESOLUTION = 2 * Math.PI * 6378137 / GOOGLE_TILE_SIZE
  ORIGIN_SHIFT = 2 * Math.PI * 6378137 / 2.0
  
  # Since 640x640 is the max size that google static supports, we take the largest
  # 'even' alignment for our tiles
  RENDER_TILE_SIZE = 512

  # This is used to calculate the background grid that's drawn behind the tiles
  # if they're not loaded:
  BACKGROUND_GRID_SIZE = 16

  constructor: (dom_id, lat, lon, options = {}) ->
    @options = options
    @options.zoom ?= 21
    @options.debug_rendering ?= false
    @options.path_stroke ?= 'fff'

    @tile_images = []  # This is our tile cache

    @turtle_angle = null
    @draw_path = null

    @ctx = dom_id.getContext("2d")
    @canvas_center = [Math.floor(@ctx.canvas.width/2), Math.floor(@ctx.canvas.height/2)]

    @focus(lat, lon)

    if @options.debug_rendering
      $(document).keydown (e) =>
        switch e.keyCode
          # Left:
          when 37 then @focus(@focus_latlon[0], @focus_latlon[1]-0.00001)
          # Up:
          when 38 then @focus(@focus_latlon[0]+0.00001, @focus_latlon[1])
          # Right:
          when 39 then @focus(@focus_latlon[0], @focus_latlon[1]+0.00001)
          # Down:
          when 40 then @focus(@focus_latlon[0]-0.00001, @focus_latlon[1])


  render: () -> 
    @ctx.clear()
  
    # Let's draw the background first:
    for tile in @background_tiles
      if tile.image.is_loaded
        @ctx.drawImage( tile.image, tile.source_x, tile.source_y, 
          tile.copy_width, tile.copy_height, tile.dest_x, tile.dest_y,
          tile.copy_width, tile.copy_height) 
      else
        # Vertical lines:
        cursor_x = tile.dest_x + BACKGROUND_GRID_SIZE - (tile.dest_x % BACKGROUND_GRID_SIZE)
        while (cursor_x < tile.dest_x+tile.copy_width)
          @_line 'blue', cursor_x, tile.dest_y, cursor_x, tile.dest_y+tile.copy_height
          cursor_x += BACKGROUND_GRID_SIZE
        # Horizontal lines:
        cursor_y = tile.dest_y + BACKGROUND_GRID_SIZE - (tile.dest_y % BACKGROUND_GRID_SIZE)
        while (cursor_y < tile.dest_y+tile.copy_height)
          @_line 'blue', tile.dest_x, cursor_y, tile.dest_x+tile.copy_width, cursor_y
          cursor_y += BACKGROUND_GRID_SIZE

    # Debug the corners, if appropriate:
    if @options.debug_rendering
      for i,tile of @background_tiles
        # Top-left
        @_circle 6, 'black', tile.dest_x, tile.dest_y
        # Top Right:
        @_circle 6, 'black', tile.dest_x+tile.copy_width, tile.dest_y
        # Bottom Right:
        @_circle 6, 'black', tile.dest_x+tile.copy_width, tile.dest_y+tile.copy_height
        # Bottom Left:
        @_circle 6, 'black', tile.dest_x, tile.dest_y+tile.copy_height

    [focal_x, focal_y] = @_latlon_to_canvas( @focus_latlon... )

    # Draw the path of motion:
    if @draw_path?
      @ctx.strokeStyle = @options.path_stroke
      @ctx.lineWidth = 2
      @ctx.beginPath()
      @ctx.moveTo focal_x, focal_y
      for stop_latlon in @draw_path
        @ctx.lineTo @_latlon_to_canvas(stop_latlon...)...
      @ctx.stroke()
      @ctx.closePath()

    # For reference:
    @_circle 6, 'blue', @_latlon_to_canvas(@focus_latlon...)...

    # Draw the turtle:
    @_turtle focal_x, focal_y, @turtle_angle if @turtle_angle?


  _latlon_to_canvas: (lat, lon) ->
    viewport_pixels = @_viewport_in_pixels()
    pixels = @latlon_to_pixels lat, lon
    [ pixels[0]-viewport_pixels[3], @ctx.canvas.height - pixels[1]+viewport_pixels[2] ]

  _tile_img: (tx, ty) ->
    @tile_images[@options.zoom] ?= []
    @tile_images[@options.zoom][tx] ?= []
    
    unless @tile_images[@options.zoom][tx][ty]?
      # This calculates the lower left corner in pixels first, and adds half a 
      # tile to the offset to arrive at the tile's center in pixels

      tile = new Image()
      src_args = [@options.zoom, tx, ty, @]
      tile.src = if (@options.tile_source) then @options.tile_source(src_args...) else @_tile_source(src_args...)
      tile.onload = -> @is_loaded = true
      @tile_images[@options.zoom][tx][ty] = tile

    # Return the tile from the cache 
    @tile_images[@options.zoom][tx][ty]

  _google_marker: (label, color, lat, lon) ->
    "markers=color:#{color}%7Clabel:#{label}%7C#{lat},#{lon}"

  _tile_source: (zoom, tx, ty) ->
    [center_lat, center_lon] = @pixels_to_latlon(
      tx*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2, 
      ty*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2)

    console.log "lat: #{center_lat} lon: #{center_lon}"

    src_parts = ["#{STATICMAP_URL}?center=#{center_lat},#{center_lon}",
      "zoom=#{zoom}","size=#{RENDER_TILE_SIZE}x#{RENDER_TILE_SIZE}",
      'maptype=satellite', 'sensor=false',"format=png32"]
    src_parts.push @_google_marker('F', 'red', center_lat, center_lon) if @options.debug_rendering
    src_parts.join('&')

  _turtle: (canvas_x, canvas_y, angle, fill_color = 'blue', height = 30, toa = 15/360*2*Math.PI) ->
    @ctx.fillStyle   = fill_color
    @ctx.strokeStyle = '#fff'
    @ctx.lineWidth   = 1

    opposite_length = height
    adjacent_length = Math.tan(toa) * opposite_length

    # Local Coords. These are essentially lines between two hypoteneuses:
    triangle_points = [
      [0-adjacent_length, opposite_length],
      [adjacent_length, opposite_length], 
    ]

    @ctx.beginPath()
    @ctx.moveTo canvas_x, canvas_y
    for point in triangle_points
      # Rotate the triangle:
      point_x = point[0] * Math.cos(angle) - point[1] * Math.sin(angle)
      point_y = point[0] * Math.sin(angle) + point[1] * Math.cos(angle)

      # Translate to world coords:
      @ctx.lineTo canvas_x+point_x, canvas_y+point_y
    
    @ctx.lineTo canvas_x, canvas_y

    @ctx.fill()
    @ctx.stroke()
    @ctx.closePath()

  _line: (color, start_x, start_y, end_x, end_y) ->
    @ctx.beginPath()
    @ctx.moveTo(start_x,start_y)
    @ctx.lineTo(end_x,end_y)
    @ctx.lineWidth = 0.5
    @ctx.strokeStyle = color
    @ctx.stroke()

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

  # This returns the viewport in google coordinates. The array is returned in 
  # "top", "right", "bottom", "left" order.
  _viewport_in_pixels: ->
    focus_in_pixels = @latlon_to_pixels(@focus_latlon...)
    [ focus_in_pixels[1] + @ctx.canvas.height - @canvas_center[1], # Top
      focus_in_pixels[0] + @ctx.canvas.width - @canvas_center[0], # Right
      focus_in_pixels[1] - @canvas_center[1], # Bottom
      focus_in_pixels[0] - @canvas_center[0] ] # Left

  latlon_to_meters: (lat, lon) ->
    # "Converts given lat/lon in WGS84 Datum to XY in Spherical Mercator EPSG:900913"
    mx = lon * ORIGIN_SHIFT / 180.0
    my = Math.log( Math.tan((90 + lat) * Math.PI / 360.0 )) / (Math.PI / 180.0)

    my = my * ORIGIN_SHIFT / 180.0
    [mx, my]

  meters_to_pixels: (mx, my) ->
    #"Converts EPSG:900913 to pyramid pixel coordinates in given zoom level"
    res = @_resolution @options.zoom
    px = (mx + ORIGIN_SHIFT) / res
    py = (my + ORIGIN_SHIFT) / res
    [ px, py ]

  latlon_to_pixels: (lat, lon) ->
    @meters_to_pixels @latlon_to_meters(lat,lon)...

  pixels_to_meters: (px, py) ->
    #"Converts pixel coordinates in given zoom level of pyramid to EPSG:900913"
    res = @_resolution @options.zoom
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

  path: (draw_path) ->
    @draw_path = draw_path

  direction: (angle) ->
    @turtle_angle = angle

  focus: (lat,lon) ->
    @focus_latlon = [lat, lon]
    @background_tiles = []

    # So - to make things easier in the render loop, to preload the image (and 
    # make the render faster in general) we pre-calculate our background tile 
    # rendering parameters here.
    [ viewport_top_pixels, viewport_right_pixels, viewport_bottom_pixels, 
      viewport_left_pixels ] = @_viewport_in_pixels()

    # We traverse the world coords from bottom-left to top right. We reverse the 
    # y-order because google's y-origin is south, and the canvas' is north
    cursor_y_pixels = viewport_bottom_pixels
   
    while (cursor_y_pixels < viewport_top_pixels)
      cursor_x_pixels = viewport_left_pixels
      while (cursor_x_pixels < viewport_right_pixels)
        # The tile offset we're copying from:
        cursor_tile_offset_x = Math.floor(cursor_x_pixels/RENDER_TILE_SIZE)
        cursor_tile_offset_y = Math.floor(cursor_y_pixels/RENDER_TILE_SIZE)

        tile = {image: @_tile_img(cursor_tile_offset_x,cursor_tile_offset_y)}

        # The bottom-left world-coordinates of the tile 
        tile_bl_pixels_x = cursor_tile_offset_x*RENDER_TILE_SIZE
        tile_bl_pixels_y = cursor_tile_offset_y*RENDER_TILE_SIZE

        # Calculate the tile width/source dimensions :
        tile.source_x = cursor_x_pixels-tile_bl_pixels_x
        canvas_width_remaining = viewport_right_pixels - cursor_x_pixels
        if canvas_width_remaining > RENDER_TILE_SIZE
          tile.copy_width = RENDER_TILE_SIZE - tile.source_x 
        else 
          tile.copy_width = canvas_width_remaining

        # Calculate the tile height/source copy dimensions :
        canvas_height_remaining = viewport_top_pixels - cursor_y_pixels

        if canvas_height_remaining > RENDER_TILE_SIZE
          tile.copy_height = tile_bl_pixels_y + RENDER_TILE_SIZE - cursor_y_pixels
          tile.source_y = 0 
        else
          tile.copy_height = canvas_height_remaining
          tile.source_y = RENDER_TILE_SIZE - tile.copy_height
      
        # This is where we're copying to on the canvas:
        tile.dest_x = cursor_x_pixels-viewport_left_pixels
        tile.dest_y = @ctx.canvas.height - cursor_y_pixels + viewport_bottom_pixels - tile.copy_height
        
        @background_tiles.push(tile)
        cursor_x_pixels += tile.copy_width
      cursor_y_pixels += tile.copy_height
