extends Spatial

onready var camera =  get_node("Camera")

func _input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_RIGHT):
			rotate(Vector3(1,0,0), -event.relative.y*0.02)
