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

draw_line_2d = (cxt, a_x, a_y, b_x, b_y, color, line_width = 1) ->
  cxt.strokeStyle = color
  cxt.lineWidth = line_width
  cxt.beginPath()
  cxt.moveTo(a_x, a_y)
  cxt.lineTo(b_x, b_y)
  cxt.stroke()

draw_2d_plane_grid = (cxt) -> 
  # Let's draw the basis vectors around the origin:
  for i in [1..10] by 1
    color = if i==5 then "000000" else cxt.strokeStyle = "aaaaaa"

    # Horizontal Lines:
    horiz_line = Math.floor( cxt.canvas.height / 10 )*i + 0.5
    draw_line_2d(cxt, 0, horiz_line, cxt.canvas.width, horiz_line, color)

    # Vertical Axis
    vert_line = Math.floor( cxt.canvas.width / 10 )*i + 0.5
    draw_line_2d(cxt, vert_line, 0, vert_line, cxt.canvas.height, color)

$(document).ready ->
  Socket = if ("MozWebSocket" in window) then MozWebSocket else WebSocket
  ws = new Socket "ws://localhost:8080/"
  ws.onmessage = (evt) ->
    data = $.parseJSON(evt.data)

    # Update the coords:
    if data.spatial_data
      $('#last_update').html(data.ts)
      for sensor in ['acceleration', 'gyroscope', 'compass']
        $(['x', 'y', 'z']).each (i,coord) ->
          $("##{sensor}_data_#{coord}").html data.spatial_data[sensor][i].toFixed(2)

      # Update the 2d planes:
      norm_accel = new THREE.Vector3().fromArray( data.spatial_data['acceleration'] ).normalize()
      window.xy_plane_cxt.clear()
      draw_2d_plane_grid(window.xy_plane_cxt)
      draw_line_2d( window.xy_plane_cxt, window.twod_plane_origin.x, window.twod_plane_origin.y, 
        window.twod_plane_origin.x+norm_accel.x*70, window.twod_plane_origin.y+norm_accel.y*-70, 
        'cc00ff', 3 )

      window.yz_plane_cxt.clear()
      draw_2d_plane_grid(window.yz_plane_cxt)
      draw_line_2d( window.yz_plane_cxt, window.twod_plane_origin.x, window.twod_plane_origin.y, 
        window.twod_plane_origin.x+norm_accel.y*70, window.twod_plane_origin.y+norm_accel.z*-70, 
        'cc00ff', 3 )

      window.xz_plane_cxt.clear()
      draw_2d_plane_grid(window.xz_plane_cxt)
      draw_line_2d( window.xz_plane_cxt, window.twod_plane_origin.x, window.twod_plane_origin.y, 
        window.twod_plane_origin.x+norm_accel.x*70, window.twod_plane_origin.y+norm_accel.z*-70, 
        'cc00ff', 3 )

      # Let's try out our rotation matrix:
      if data.spatial_data['orientation']
        orient = data.spatial_data['orientation']
        $(['x','y','z']).each (i,coord) ->
          $("#orientation_#{coord}").html( orient[i].toFixed(2) )

        orientation = new THREE.Matrix4().makeRotationFromEuler( v(orient[0],orient[1],orient[2]), 'ZYX' )
        #window.mesh.rotation.x = orient[2]
        #window.mesh.rotation.y = orient[0]
        #window.mesh.rotation.z = orient[1]
        #window.accelerometer_arrow.rotation.x = orient[0]
        #window.accelerometer_arrow.rotation.y = orient[1]
        #window.accelerometer_arrow.rotation.z = orient[2]


        orient = data.spatial_data['orientation_matrix']
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

    if data.spatial_attributes
      $('#spatial_attributes_summary').html(["Version (#{data.spatial_attributes.version})",
        "Serial (#{data.spatial_attributes.serial_number})"].join(' '))

    if data.spatial_extents
      for sensor in ['acceleration', 'gyroscope', 'compass']
        $(['min', 'max']).each (i,ext) ->
          $("##{sensor}_extent_#{ext}").html data.spatial_extents["#{sensor}_#{ext}"]
        
  ws.onclose = -> 
    console.log "socket closed"
  ws.onopen = ->
    ws.send 'get spatial_attributes'
    ws.send 'get spatial_extents'
    setInterval ( -> ws.send "get spatial_data" ), 50

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
    new THREE.MeshBasicMaterial( { color: 0xcc00ff } )
  )
  scene.add(window.accelerometer_arrow)
  

  # The actual model
  window.mesh = new THREE.Mesh( phidget_geometry( 200, 200, 50 ), 
    new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } ) )

  scene.add( window.mesh )

  renderer = new THREE.CanvasRenderer(canvas: gyro_cxt.canvas)
  renderer.setSize gyro_cxt.canvas.width, gyro_cxt.canvas.height

  window.xy_plane_cxt = $('#xy_plane')[0].getContext( '2d' )
  window.yz_plane_cxt = $('#yz_plane')[0].getContext( '2d' )
  window.xz_plane_cxt = $('#xz_plane')[0].getContext( '2d' )

  # This will come in handy later:
  window.twod_plane_origin = new THREE.Vector2().fromArray(
    $([ window.xy_plane_cxt.canvas.width, window.xy_plane_cxt.canvas.height ]).map( (i,n) -> Math.floor(n) / 2 + 0.5  ) )

  $([window.xy_plane_cxt, window.yz_plane_cxt, window.xz_plane_cxt]).each (i,cxt) ->
    draw_2d_plane_grid(cxt)

  window.animate = ->
    # 3D Visualization
    requestAnimationFrame window.animate 

    renderer.render scene, camera

    # Draw Debug axis labels
    draw_text(gyro_cxt, camera, '+x', debug_axis_position.clone().add(v(debug_axis_length*1.2, 0, 0)), 0xff0000)
    draw_text(gyro_cxt, camera, '+y', debug_axis_position.clone().add(v(0, debug_axis_length*1.2, 0)), 0x00ff00)
    draw_text(gyro_cxt, camera, '+z', debug_axis_position.clone().add(v(0, 0, debug_axis_length*1.2)), 0x0000ff)
    
    
  window.animate()
