extends Spatial

onready var camera =  get_node("Camera")

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			rotate(Vector3(1,0,0), -event.relative.y*0.02)
		else:
			# Disable as it messes with the projection math
			#return
			var mp = get_viewport().get_mouse_position()
			var w = get_viewport().size.x
			var h = get_viewport().size.y
			var x_quad = (mp[0]-w/2)/w
			var y_quad = (mp[1]-h/2)/h
			rotation_degrees.z = -x_quad * 30
			rotation_degrees.x = y_quad * 30
			camera.rotation_degrees.x = -80 -y_quad * 20
			camera.rotation_degrees.y = -x_quad* 50
			camera.rotation_degrees.z = x_quad * 50
			camera.translation.x = x_quad * 4
			camera.translation.z = y_quad * 4
