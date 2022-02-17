extends Label

const TIMER_LIMIT = 0.1
var timer = 0.05

var surface
var res = [64, 256, 512, 1024]

func _ready():
	surface = get_tree().get_nodes_in_group("surface")[0]

func _process(delta):
	text = "fps: " + str(Engine.get_frames_per_second()) + "\n"\
	 + "cards:" + str(surface.get_children().size()) + "\n"
	if Globals.stack_over and is_instance_valid(Globals.stack_over):
		text += "stack:" + Globals.stack_over.name + str(Globals.stack_over.components.size())+">"
		for component in Globals.stack_over.components:
			text += component.name + " "
		text += "\n"
	if Globals._mouse_over and is_instance_valid(Globals._mouse_over):
		text += "over:" + Globals._mouse_over.name + "\n"

func _input(event):
	if event is InputEventKey and not event.is_pressed() and event.scancode == KEY_S:
		var light = get_tree().get_nodes_in_group("light")[0]
		light.set("shadow_enabled", not light.get("shadow_enabled"))
