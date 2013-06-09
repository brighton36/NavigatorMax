class VectorPlot2D
  constructor: (canvas, title, x_label, y_label, x_color, y_color, vector_colors) ->
    @title = title
    @x_label = x_label
    @y_label = y_label
    @vector_colors = vector_colors
    @x_axis_color = decimal_to_hex_string(x_color)
    @y_axis_color = decimal_to_hex_string(y_color)
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
      @_draw_vector @vectors[label], decimal_to_hex_string( @vector_colors[label] )
    @cxt.fillStyle = '000000'
    @cxt.font = '10pt Arial'
    @cxt.fillText(@title, 5,14)
    @cxt.fillStyle = @y_axis_color
    @cxt.fillText(@y_label, @origin.x+5,14)
    @cxt.fillStyle = @x_axis_color
    @cxt.fillText(@x_label, @cxt.canvas.width-18,@origin.y+14)

  _draw_grid: -> 
    # Let's draw the basis vectors around the origin:
    for i in [1..10] by 1
      color = if i==5 then 0x000000 else @cxt.strokeStyle = 0xaaaaaa
      
      # Horizontal Lines:
      horiz_line = Math.floor( @cxt.canvas.height / 10 )*i + 0.5
      @_draw_line(0, horiz_line, @cxt.canvas.width, horiz_line, 
        (if i == 5 then @x_axis_color else 'aaaaaa')
        (if i == 5 then 2 else 1) )

      # Vertical Axis
      vert_line = Math.floor( @cxt.canvas.width / 10 )*i + 0.5
      @_draw_line(vert_line, 0, vert_line, @cxt.canvas.height, 
        (if i == 5 then @y_axis_color else 'aaaaaa'), 
        (if i == 5 then 2 else 1) )

  _draw_line: (a_x, a_y, b_x, b_y, color, line_width = 1) ->
    @cxt.strokeStyle = color
    @cxt.lineWidth = line_width
    @cxt.beginPath()
    @cxt.moveTo(a_x, a_y)
    @cxt.lineTo(b_x, b_y)
    @cxt.stroke()

  _draw_vector: (vector, color) ->
    @_draw_line( @origin.x, @origin.y, 
      @origin.x+vector.x*@vector_scale, @origin.y+vector.y*-@vector_scale, 
      color, 3 )


CanvasRenderingContext2D.prototype.clear = (preserveTransform) ->
  if (preserveTransform)
    @save()
    @setTransform(1, 0, 0, 1, 0, 0)
  @clearRect(0, 0, @canvas.width, @canvas.height)
  @restore() if (preserveTransform)

decimal_to_hex_string = (d) ->
  hex = Number(d).toString(16)
  "000000".substr(0, 6 - hex.length) + hex

v = (x,y,z) ->
  new THREE.Vector3(x,y,z)

projection_in_2d = (camera, pos, canvas) ->
  projector = new THREE.Projector()
  vector = projector.projectVector(pos.clone(), camera)
  new THREE.Vector2( (vector.x + 1)/2 * canvas.width, 
    -(vector.y - 1)/2 * canvas.height )

rotate_around_world_axis = (object, axis, radians) ->
  rotWorldMatrix = new THREE.Matrix4()
  rotWorldMatrix.makeRotationAxis(axis.normalize(), radians)
  object.matrix = rotWorldMatrix.multiply(object.matrix)
  object.rotation.setEulerFromRotationMatrix(object.matrix)

add_axis = (scene, position, length, cap_rotation, color) ->
  lineGeometry = new THREE.Geometry()
  lineMat = new THREE.LineBasicMaterial({color: color, linewidth: 3})
  lineGeometry.vertices.push(v(0,0,0), length)
  cap = new THREE.Mesh( 
    new THREE.CylinderGeometry(1, 20, 50, 10, 10)
    new THREE.MeshBasicMaterial( { color: color } )
  )

  scene.add cap
  rotate_around_world_axis(cap, cap_rotation, Math.PI)
  cap_position = position.clone()
  cap_position.add(length)

  cap.position = cap_position

  axis_line = new THREE.Line(lineGeometry, lineMat)
  axis_line.position = position
  scene.add axis_line

arrow_geometry = (length) ->
  lineGeometry = new THREE.CubeGeometry( 10, length, 10 )
  cylGeometry = new THREE.CylinderGeometry(1, 20, 50, 10, 10)
 
  # Move the arrow head down a bit:
  cylGeometry.applyMatrix( new THREE.Matrix4().makeTranslation( 0, length, 0))
  lineGeometry.applyMatrix( new THREE.Matrix4().makeTranslation( 0, length/2, 0))
  
  THREE.GeometryUtils.merge(lineGeometry, cylGeometry)

  lineGeometry

# beam is width, carlin is length, height is 
phidget_geometry = (beam, carlin, height) ->
  extents = new THREE.CubeGeometry( beam, carlin, height )
  usb_jack = new THREE.CubeGeometry( beam / 3, carlin/4, height/2 )
  usb_jack.applyMatrix( new THREE.Matrix4().makeTranslation( 0, 0-carlin*0.50, 0))
  THREE.GeometryUtils.merge(extents, usb_jack)
  extents

debug_axis = (scene, position, axisLength) ->
  add_axis(scene, position, v(axisLength, 0, 0), v(1,1,0), 0xFF0000)
  add_axis(scene, position, v(0, axisLength, 0), v(0,1,0), 0x00FF00)
  add_axis(scene, position, v(0, 0, axisLength), v(0,1,1), 0x0000FF)

debug_plane = (planeW, planeH, numW, numH) -> 
  new THREE.Mesh( 
    new THREE.PlaneGeometry( planeW*50, planeH*50, numW, numH),
    new THREE.MeshBasicMaterial( { color: 0xaaaaaa, wireframe: true } ) )

draw_text = (cxt, camera, text, v, color) ->
  coords2d = projection_in_2d(camera, v, cxt.canvas)
  cxt.fillStyle = decimal_to_hex_string(color)
  cxt.font = '10pt Arial'
  cxt.fillText(text,coords2d.x, coords2d.y)

$(document).ready ->
  COLOR_ACCELERATION = 0xcc00ff
  COLOR_GYROSCOPE = 0xd2691e
  COLOR_COMPASS = 0x20b2aa

  VECTOR_COLORS = { acceleration: COLOR_ACCELERATION, compass: COLOR_COMPASS, gyroscope: COLOR_GYROSCOPE}

  $('.acceleration').css('background-color', '#'+decimal_to_hex_string(COLOR_ACCELERATION) )
  $('.gyroscope').css('background-color', '#'+decimal_to_hex_string(COLOR_GYROSCOPE) )
  $('.compass').css('background-color', '#'+decimal_to_hex_string(COLOR_COMPASS) )

  Socket = if ("MozWebSocket" in window) then MozWebSocket else WebSocket
  ws = new Socket "ws://localhost:8080/"
  ws.onmessage = (evt) ->
    data = $.parseJSON(evt.data)

    # Update the coords:
    if data.spatial_data
      $('#last_update').html(data.ts)
      for sensor in ['acceleration', 'gyroscope', 'compass']
        $(['x', 'y', 'z']).each (i,coord) ->
          $("##{sensor}_data_#{coord}").html data.spatial_data.raw[sensor][i].toFixed(2)

      # Update the 2d planes:
      norm_accel = new THREE.Vector3().fromArray( data.spatial_data.raw['acceleration'] ).normalize()
      window.xy_plane_vectors.plot( 'acceleration', new THREE.Vector2(norm_accel.x, norm_accel.y) )
      window.yz_plane_vectors.plot( 'acceleration', new THREE.Vector2(norm_accel.y, norm_accel.z) )
      window.xz_plane_vectors.plot( 'acceleration', new THREE.Vector2(norm_accel.x, norm_accel.z) )

      # Let's try out our rotation matrix:
      if data.spatial_data.euler_angles
        orient = data.spatial_data.euler_angles['acceleration']
        $(['heading','pitch','bank']).each (i,coord) ->
          $("#euler_acceleration_#{coord}").html( orient[i].toFixed(2) )

        orientation = new THREE.Matrix4().makeRotationFromEuler( v(orient[0],orient[1],orient[2]), 'ZYX' )
        #window.mesh.rotation.x = orient[2]
        #window.mesh.rotation.y = orient[0]
        #window.mesh.rotation.z = orient[1]
        #window.accelerometer_arrow.rotation.x = orient[0]
        #window.accelerometer_arrow.rotation.y = orient[1]
        #window.accelerometer_arrow.rotation.z = orient[2]


        orient = data.spatial_data.direction_cosine_matrix['acceleration']
        #for i in [0,1,2]
          #for j in [0,1,2]
            #$("#orientation_#{i}_#{j}").html( orient[i][j].toFixed(2) )

        orientation = new THREE.Matrix4( 
          orient[0][0], orient[0][1], orient[0][2], 0, 
          orient[1][0], orient[1][1], orient[1][2], 0, 
          orient[2][0], orient[2][1], orient[2][2], 0, 
          0, 0, 0, 1 
        )
        #window.mesh.matrix = new THREE.Matrix4()
        #window.mesh.applyMatrix(orientation)
      
        window.accelerometer_arrow.matrix = new THREE.Matrix4()
        window.accelerometer_arrow.applyMatrix(orientation)

    if data.spatial_extents
      for sensor in ['acceleration', 'gyroscope', 'compass']
        $(['min', 'max']).each (i,ext) ->
          $("##{sensor}_extent_#{ext}").html data.spatial_extents["#{sensor}_#{ext}"]
        
  ws.onclose = -> 
    console.log "socket closed"
  ws.onopen = ->
    ws.send 'get spatial_extents'
    setInterval ( -> ws.send "get spatial_data" ), 25

  gyro_cxt = $('#gyroscope_vis')[0].getContext( '2d' )

  camera = new THREE.PerspectiveCamera( 30, gyro_cxt.canvas.width / gyro_cxt.canvas.height , 1, 10000 )
  camera.position.z = 1000
  camera.position.y = -1000
  camera.position.x = 1000

  camera.lookAt(new THREE.Vector3(0,0,0))
  camera.rotation.z = 0.5

  scene = new THREE.Scene()

  # Debug elements:
  debug_axis_length = 150
  debug_axis_position = v(-50,-600,0)
  debug_axis(scene, debug_axis_position, debug_axis_length)
  scene.add(debug_plane(50,50,50,50))

  # Accelerometer Arrow:
  window.accelerometer_arrow = new THREE.Mesh( 
    arrow_geometry(250),
    new THREE.MeshBasicMaterial( { color: COLOR_ACCELERATION } )
  )
  scene.add(window.accelerometer_arrow)
  

  # The actual model
  window.mesh = new THREE.Mesh( phidget_geometry( 200, 200, 50 ), 
    new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } ) )

  scene.add( window.mesh )

  renderer = new THREE.CanvasRenderer(canvas: gyro_cxt.canvas)
  renderer.setSize gyro_cxt.canvas.width, gyro_cxt.canvas.height

  window.xy_plane_vectors = new VectorPlot2D $('#xy_plane')[0], 'X/Y Plane', 
    '+x', '+y', 0xff0000, 0x00ff00, VECTOR_COLORS
  window.yz_plane_vectors = new VectorPlot2D $('#yz_plane')[0], 'Y/Z Plane', 
    '+y', '+z', 0x00ff00, 0x0000ff, VECTOR_COLORS
  window.xz_plane_vectors = new VectorPlot2D $('#xz_plane')[0], 'X/Z Plane', 
    '+x', '+z', 0xff0000, 0x0000ff, VECTOR_COLORS

  window.animate = ->
    # 3D Visualization
    requestAnimationFrame window.animate 

    renderer.render scene, camera

    # Draw Debug axis labels
    draw_text(gyro_cxt, camera, '+x', debug_axis_position.clone().add(v(debug_axis_length*1.2, 0, 0)), 0xff0000)
    draw_text(gyro_cxt, camera, '+y', debug_axis_position.clone().add(v(0, debug_axis_length*1.2, 0)), 0x00ff00)
    draw_text(gyro_cxt, camera, '+z', debug_axis_position.clone().add(v(0, 0, debug_axis_length*1.2)), 0x0000ff)

    # 2D Visualizations:
    $([window.xy_plane_vectors, window.yz_plane_vectors, window.xz_plane_vectors]).each (i,vp) ->
      vp.render()
    
  window.animate()
