
CanvasRenderingContext2D.prototype.clear = (preserveTransform) ->
  if (preserveTransform)
    @save()
    @setTransform(1, 0, 0, 1, 0, 0)
  @clearRect(0, 0, @canvas.width, @canvas.height)
  @restore() if (preserveTransform)

window.decimal_to_hex_string = (d) ->
  hex = Number(d).toString(16)
  "000000".substr(0, 6 - hex.length) + hex

window.v = (x,y,z) ->
  new THREE.Vector3(x,y,z)


window.draw_text = (cxt, camera, text, v, color) ->
  coords2d = projection_in_2d(camera, v, cxt.canvas)
  cxt.fillStyle = decimal_to_hex_string(color)
  cxt.font = '10pt Arial'
  cxt.fillText(text,coords2d.x, coords2d.y)


window.projection_in_2d = (camera, pos, canvas) ->
  projector = new THREE.Projector()
  vector = projector.projectVector(pos.clone(), camera)
  new THREE.Vector2( (vector.x + 1)/2 * canvas.width, 
    -(vector.y - 1)/2 * canvas.height )
