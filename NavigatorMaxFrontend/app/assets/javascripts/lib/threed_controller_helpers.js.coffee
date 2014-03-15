window.ThreedControllerHelpers = class extends Controller
  debug_axis: (scene, position, axisLength) ->
    @add_axis(scene, position, v(axisLength, 0, 0), v(1,1,0), COLORS.x_axis)
    @add_axis(scene, position, v(0, axisLength, 0), v(0,1,0), COLORS.y_axis)
    @add_axis(scene, position, v(0, 0, axisLength), v(0,1,1), COLORS.z_axis)

  debug_plane: (planeW, planeH, numW, numH) -> 
    new THREE.Mesh( 
      new THREE.PlaneGeometry( planeW*50, planeH*50, numW, numH),
      new THREE.MeshBasicMaterial( { color: 0xaaaaaa, wireframe: true } ) )

  add_axis: (scene, position, length, cap_rotation, color) ->
    lineGeometry = new THREE.Geometry()
    lineMat = new THREE.LineBasicMaterial({color: color, linewidth: 3})
    lineGeometry.vertices.push(v(0,0,0), length)
    cap = new THREE.Mesh( 
      new THREE.CylinderGeometry(1, 20, 50, 10, 10)
      new THREE.MeshBasicMaterial( { color: color } )
    )

    scene.add cap
    @rotate_around_world_axis(cap, cap_rotation, Math.PI)
    cap_position = position.clone()
    cap_position.add(length)

    cap.position = cap_position

    axis_line = new THREE.Line(lineGeometry, lineMat)
    axis_line.position = position
    scene.add axis_line

  arrow_geometry: (length) ->
    lineGeometry = new THREE.CubeGeometry( 10, length, 10 )
    cylGeometry = new THREE.CylinderGeometry(1, 20, 50, 10, 10)
   
    # Move the arrow head down a bit:
    cylGeometry.applyMatrix( new THREE.Matrix4().makeTranslation( 0, length, 0))
    lineGeometry.applyMatrix( new THREE.Matrix4().makeTranslation( 0, length/2, 0))
    
    THREE.GeometryUtils.merge(lineGeometry, cylGeometry)

    lineGeometry

  # beam is width, carlin is length, height is 
  phidget_geometry: (beam, carlin, height) ->
    extents = new THREE.CubeGeometry( beam, carlin, height )
    usb_jack = new THREE.CubeGeometry( beam / 3, carlin/4, height/2 )
    usb_jack.applyMatrix( new THREE.Matrix4().makeTranslation( 0, 0-carlin*0.50, 0))
    THREE.GeometryUtils.merge(extents, usb_jack)
    extents

  rotate_around_world_axis: (object, axis, radians) ->
    rotWorldMatrix = new THREE.Matrix4()
    rotWorldMatrix.makeRotationAxis(axis.normalize(), radians)
    object.matrix = rotWorldMatrix.multiply(object.matrix)
    object.rotation.setEulerFromRotationMatrix(object.matrix)

