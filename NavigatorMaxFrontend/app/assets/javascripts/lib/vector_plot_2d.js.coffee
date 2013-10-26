window.VectorPlot2D = class VectorPlot2D
  constructor: (canvas, title, x_label, y_label, vector_colors) ->
    @title = title
    @x_label = x_label
    @y_label = y_label
    @vector_colors = vector_colors
    @x_axis_color = decimal_to_hex_string(vector_colors["#{x_label}_axis"])
    @y_axis_color = decimal_to_hex_string(vector_colors["#{y_label}_axis"])
    @vectors = {}
    @cxt = canvas.getContext( '2d' )
    @origin = new THREE.Vector2().fromArray( 
      $([ @cxt.canvas.width, @cxt.canvas.height ]).map( 
        (i,n) -> Math.floor(n) / 2 + 0.5  ) )
    @vector_scale = 0.75 * canvas.width / 2
    @render()

  plot: (label, v) -> 
    @vectors[label] = v

  render: ->
    @cxt.clear()
    @_draw_grid()
    for label, vector of @vectors
      @_draw_vector @vectors[label], decimal_to_hex_string( @vector_colors[label] ) if vector?
    @cxt.fillStyle = '000000'
    @cxt.font = '10pt Arial'
    @cxt.fillText(@title, 5,14)
    @cxt.fillStyle = @y_axis_color
    @cxt.fillText("+#{@y_label}", @origin.x+5,14)
    @cxt.fillStyle = @x_axis_color
    @cxt.fillText("+#{@x_label}", @cxt.canvas.width-18,@origin.y+14)

  _draw_grid: -> 
    min_basis_lines = 10 # We're guaranteed this many lines on an axis
    vert_offset = 0
    horz_offset = 0
    vert_lines = min_basis_lines
    horz_lines = min_basis_lines
    if @cxt.canvas.height >= @cxt.canvas.width
      grid_unit = @cxt.canvas.width / min_basis_lines
      horz_offset = (@cxt.canvas.height % grid_unit) / -4
      horz_lines = Math.floor(@cxt.canvas.height / grid_unit)
    else 
      grid_unit = @cxt.canvas.height / min_basis_lines
      vert_offset = (@cxt.canvas.width % grid_unit) / -4
      vert_lines = Math.floor(@cxt.canvas.width / grid_unit)

    for i in [1..(if (horz_lines >= vert_lines) then horz_lines else vert_lines)]
      # Horizontal lines:
      if i <= horz_lines
        is_origin = if (Math.round(horz_lines / 2) == i) then true else false
        horz_line = Math.floor(i*grid_unit+horz_offset)+0.5
        @_draw_line(0, horz_line, @cxt.canvas.width, horz_line,
          (if is_origin then @x_axis_color else 'aaaaaa'),
          (if is_origin then 2 else 1) )
      # Vertical lines:
      if i <= vert_lines
        is_origin = if (Math.round(vert_lines / 2) == i) then true else false
        vert_line = Math.floor(i*grid_unit+vert_offset)+0.5
        @_draw_line(vert_line, 0, vert_line, @cxt.canvas.height,
          (if is_origin then @y_axis_color else 'aaaaaa'),
          (if is_origin then 2 else 1) )


    # Let's draw the basis vectors around the origin:
    #for i in [1..10] by 1
      #color = if i==5 then 0x000000 else @cxt.strokeStyle = 0xaaaaaa
      
      ## Horizontal Lines:
      #horiz_line = Math.floor( @cxt.canvas.height / 10 )*i + 0.5
      #@_draw_line(0, horiz_line, @cxt.canvas.width, horiz_line, 
        #(if i == 5 then @x_axis_color else 'aaaaaa')
        #(if i == 5 then 2 else 1) )

      ## Vertical Axis
      #vert_line = Math.floor( @cxt.canvas.width / 10 )*i + 0.5
      #@_draw_line(vert_line, 0, vert_line, @cxt.canvas.height, 
        #(if i == 5 then @y_axis_color else 'aaaaaa'), 
        #(if i == 5 then 2 else 1) )

  _draw_line: (a_x, a_y, b_x, b_y, color, line_width = 1) ->
    @cxt.strokeStyle = color
    @cxt.lineWidth = line_width
    @cxt.beginPath()
    @cxt.moveTo(a_x, a_y)
    @cxt.lineTo(b_x, b_y)
    @cxt.stroke()
    @cxt.closePath()

  _draw_vector: (vector, color) ->
    @_draw_line( @origin.x, @origin.y, 
      @origin.x+vector.x*@vector_scale, @origin.y+vector.y*-@vector_scale, 
      color, 3 )

