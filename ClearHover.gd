extends StaticBody
class_name TableInteract

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseMotion:
		Globals.call_message("clear_hover", [])
	if event is InputEventMouseButton:
		if event.pressed:
			var control:Spatial = get_tree().root.get_node("Tabletop/CameraControl")
			control.translation = click_position
