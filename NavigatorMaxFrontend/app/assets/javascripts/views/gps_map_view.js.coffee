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

  constructor: (dom_id) ->
    @zoom = 21
    @debug_rendering = true
    @tile_images = []  # This is our tile cache

    @ctx = dom_id.getContext("2d")
    @canvas_center = [Math.floor(@ctx.canvas.width/2), Math.floor(@ctx.canvas.height/2)]

    @focus(40.6892, -74.0447) # TODO: Take from the constructor

    # TODO: nix in production? Maybe a debug toggle?
    $(document).keydown (e) =>
      switch e.keyCode
        # Left:
        when 37 then @focus( @focus_latlon[0], @focus_latlon[1]-0.00001 )
        # Up:
        when 38 then @focus( @focus_latlon[0]+0.00001, @focus_latlon[1] )
        # Right:
        when 39 then @focus( @focus_latlon[0], @focus_latlon[1]+0.00001 )
        # Down:
        when 40 then @focus( @focus_latlon[0]-0.00001, @focus_latlon[1] )

    # At some point I guess this must go?
    @markers = [ [40.6892,-74.0447], [40.6893,-74.0447], [40.6892,-74.0446], 
      [40.6891,-74.0447], [40.6892,-74.0448] ]

  render: () -> 
    @ctx.clear()
   
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

    if @debug_rendering
      for i,tile of @background_tiles
        # Top-left
        @_circle 6, 'black', tile.dest_x, tile.dest_y
        # Top Right:
        @_circle 6, 'black', tile.dest_x+tile.copy_width, tile.dest_y
        # Bottom Right:
        @_circle 6, 'black', tile.dest_x+tile.copy_width, tile.dest_y+tile.copy_height
        # Bottom Left:
        @_circle 6, 'black', tile.dest_x, tile.dest_y+tile.copy_height

    for marker in @markers
      canvas_coords = @_latlon_to_canvas( marker... )
      #console.log "Marker"+canvas_coords
      # TODO: clip testing (is x < 0 or > width-1) same for y
      @_circle 6, 'orange', canvas_coords...

  _latlon_to_canvas: (lat, lon) ->
    viewport_pixels = @_viewport_in_pixels()
    pixels = @latlon_to_pixels lat, lon
    [ pixels[0]-viewport_pixels[3], @ctx.canvas.height - pixels[1]+viewport_pixels[2] ]

  _tile_img: (tx, ty) ->
    @tile_images[@zoom] ?= []
    @tile_images[@zoom][tx] ?= []
    
    unless @tile_images[@zoom][tx][ty]?
      # This calculates the lower left corner in pixels first, and adds half a 
      # tile to the offset to arrive at the tile's center in pixels
      tile_center_latlon = @pixels_to_latlon(
        tx*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2, 
        ty*RENDER_TILE_SIZE+RENDER_TILE_SIZE/2)

      src_parts = ["#{STATICMAP_URL}?center=#{tile_center_latlon.join(',')}",
        "zoom=#{@zoom}","size=#{RENDER_TILE_SIZE}x#{RENDER_TILE_SIZE}",
        'maptype=satellite', 'sensor=false',"format=png32"]
      if @debug_rendering
        src_parts.push @_google_marker('F', 'red', tile_center_latlon...)

      tile = new Image()
      tile.src = src_parts.join('&')
      tile.onload = -> @is_loaded = true
      @tile_images[@zoom][tx][ty] = tile

    # Return the tile from the cache 
    @tile_images[@zoom][tx][ty]

  _google_marker: (label, color, lat, lon) ->
    "markers=color:#{color}%7Clabel:#{label}%7C#{lat},#{lon}"

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

  focus: (lat,lon) ->
    @focus_latlon = [lat, lon]
    @background_tiles = []

    # So - to make things easier in the render loop, to preload the image (and 
    # make the render faster in general) we pre-calculate our background tile 
    # rendering parameters here.
    viewport_pixels = @_viewport_in_pixels()
    viewport_top_pixels = viewport_pixels[0]
    viewport_right_pixels = viewport_pixels[1]
    viewport_bottom_pixels = viewport_pixels[2]
    viewport_left_pixels = viewport_pixels[3]

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
