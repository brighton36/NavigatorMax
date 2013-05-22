# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

toXYCoords = (camera, pos, canvas) ->
  projector = new THREE.Projector()
  vector = projector.projectVector(pos.clone(), camera);
  vector.x = (vector.x + 1)/2 * canvas.width
  vector.y = -(vector.y - 1)/2 * canvas.height
  return vector;

decimal_to_hex_string = (d) ->
  hex = Number(d).toString(16)
  "000000".substr(0, 6 - hex.length) + hex

v = (x,y,z) ->
  new THREE.Vector3(x,y,z)

rotateAroundWorldAxis = (object, axis, radians) ->
  rotWorldMatrix = new THREE.Matrix4();
  rotWorldMatrix.makeRotationAxis(axis.normalize(), radians);
  object.matrix = rotWorldMatrix.multiply(object.matrix)

  # new code for Three.js v50+
  object.rotation.setEulerFromRotationMatrix(object.matrix);


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
  rotateAroundWorldAxis( cap, cap_rotation, Math.PI)
  cap.position = p2

  scene.add new THREE.Line(lineGeometry, lineMat)
    
debug_axis = (scene, axisLength) ->
  origin = v(0,0,0)
  create_axis(scene, origin, v(axisLength, 0, 0), v(1,1,0), 0xFF0000)
  create_axis(scene, origin, v(0, axisLength, 0), v(0,1,0), 0x00FF00)
  create_axis(scene, origin, v(0, 0, axisLength), v(0,1,1), 0x0000FF)

draw_text = (cxt, camera, text, v, color) ->
  coords2d = toXYCoords(camera, v, cxt.canvas)
  cxt.fillStyle = decimal_to_hex_string(color)
  cxt.font = '10pt Arial';
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


  gyroscope_canvas = $('#gyroscope_vis')
  gyroscope_width = parseInt gyroscope_canvas.attr('width')
  gyroscope_height = parseInt gyroscope_canvas.attr('height')
  camera = new THREE.PerspectiveCamera( 30, gyroscope_width / gyroscope_height , 
    1, 10000 )
  camera.position.z = 1000
  camera.position.y = -1000
  camera.position.x = 1000

  camera.lookAt(new THREE.Vector3(0,0,0))
  camera.rotation.z = 0.5


  scene = new THREE.Scene()

  debug_axis_length = 200
  debug_axis(scene, debug_axis_length)

  #for color,i in [ 0x00cc00, 0xcc0000, 0x0000cc, 0xffff66 ]
    #x_coord = y_coord = 200
    #x_coord = x_coord *-1 if i > 1 
    #y_coord = y_coord *-1 if i % 2 == 1 

    #console.log "Color : #{color} x_coord: #{x_coord}"
    #z_plane_anchor = new THREE.Mesh( 
      #new THREE.TetrahedronGeometry( 20.0 ) , 
      #new THREE.MeshBasicMaterial( { color: color } )
    #)
    #z_plane_anchor.position = new THREE.Vector3( x_coord, y_coord, 0)
    #scene.add z_plane_anchor
  

  geometry = new THREE.CubeGeometry( 200, 200, 200 )
  material = new THREE.MeshBasicMaterial( { color: 0xff0000, wireframe: true } )

  window.mesh = new THREE.Mesh( geometry, material )
  scene.add( mesh )

  # Draw a plane 
  planeW = 50
  planeH = 50
  numW = 50
  numH = 50
  plane = new THREE.Mesh( 
    new THREE.PlaneGeometry( planeW*50, planeH*50, planeW, planeH ),
    new THREE.MeshBasicMaterial( { color: 0xaaaaaa, wireframe: true } ) )

  scene.add(plane);

  renderer = new THREE.CanvasRenderer(canvas: gyroscope_canvas[0])
  renderer.setSize gyroscope_width, gyroscope_height

  window.animate = ->
    requestAnimationFrame window.animate 
   
    # 0-6 is the range?
    window.mesh.rotation.x = 1.5
    window.mesh.rotation.x += 0.01;
    window.mesh.rotation.y += 0.02;

    # console.log "Rotation X = #{window.mesh.rotation.x} Y= #{window.mesh.rotation.y}"

    renderer.render scene, camera
    
    cxt = gyroscope_canvas[0].getContext( '2d' )

    # Debug axis labels
    draw_text(cxt, camera, '+x', v(debug_axis_length*1.2, 0, 0), 0xff0000)
    draw_text(cxt, camera, '+y', v(0, debug_axis_length*1.2, 0), 0x00ff00)
    draw_text(cxt, camera, '+z', v(0, 0, debug_axis_length*1.2), 0x0000ff)

    
  window.animate();
  

