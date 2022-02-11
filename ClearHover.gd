extends StaticBody


func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseMotion:
		Globals.call_message("clear_hover", [])
