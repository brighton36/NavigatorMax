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

create_axis = (scene, p1, p2, cap_rotation, color) ->
  line = new THREE.Geometry()
  lineGeometry = new THREE.Geometry()
  lineMat = new THREE.LineBasicMaterial({color: color, linewidth: 3})
  lineGeometry.vertices.push(p1, p2)
  cap = new THREE.Mesh( 
    new THREE.CylinderGeometry(1, 20, 50, 10, 10)
    new THREE.MeshBasicMaterial( { color: color } )
  )
  scene.add cap
  rotate_around_world_axis(cap, cap_rotation, Math.PI)
  cap.position = p2

  scene.add new THREE.Line(lineGeometry, lineMat)
    
debug_axis = (scene, axisLength) ->
  origin = v(0,0,0)
  create_axis(scene, origin, v(axisLength, 0, 0), v(1,1,0), 0xFF0000)
  create_axis(scene, origin, v(0, axisLength, 0), v(0,1,0), 0x00FF00)
  create_axis(scene, origin, v(0, 0, axisLength), v(0,1,1), 0x0000FF)

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

      # window.mesh.rotation.x = 
      # console.log "huh"+data.spatial_data['gyroscope'][0]
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
    setInterval ( -> ws.send "get spatial_data" ), 100

  gyro_cxt = $('#gyroscope_vis')[0].getContext( '2d' )

  camera = new THREE.PerspectiveCamera( 30, gyro_cxt.canvas.width / gyro_cxt.canvas.height , 1, 10000 )
  camera.position.z = 1000
  camera.position.y = -1000
  camera.position.x = 1000

  camera.lookAt(new THREE.Vector3(0,0,0))
  camera.rotation.z = 0.5

  scene = new THREE.Scene()

  # Debug elements:
  debug_axis_length = 200
  debug_axis(scene, debug_axis_length)
  scene.add(debug_plane(50,50,50,50))

  # The actual model
  window.mesh = new THREE.Mesh( new THREE.CubeGeometry( 200, 200, 200 ), 
    new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } ) )

  scene.add( mesh )

  renderer = new THREE.CanvasRenderer(canvas: gyro_cxt.canvas)
  renderer.setSize gyro_cxt.canvas.width, gyro_cxt.canvas.height

  window.animate = ->
    requestAnimationFrame window.animate 
   
    # 0-6 is the range?
    window.mesh.rotation.x = 1.5
    window.mesh.rotation.x += 0.01
    window.mesh.rotation.y += 0.02

    renderer.render scene, camera

    # Draw Debug axis labels
    draw_text(gyro_cxt, camera, '+x', v(debug_axis_length*1.2, 0, 0), 0xff0000)
    draw_text(gyro_cxt, camera, '+y', v(0, debug_axis_length*1.2, 0), 0x00ff00)
    draw_text(gyro_cxt, camera, '+z', v(0, 0, debug_axis_length*1.2), 0x0000ff)
    
  window.animate()
