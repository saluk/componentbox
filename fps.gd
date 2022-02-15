extends Label

const TIMER_LIMIT = 0.1
var timer = 0.05

var surface
var res = [64, 256, 512, 1024]

func _ready():
	surface = get_tree().get_nodes_in_group("surface")[0]

func _process(delta):
	text = "fps: " + str(Engine.get_frames_per_second()) + "\n"\
	 + "cards:" + str(surface.get_children().size()) + "\n"\
	 #+ "res:" + str(res[0])

func _input(event):
	if event is InputEventKey and not event.is_pressed() and event.scancode == KEY_S:
		var light = get_tree().get_nodes_in_group("light")[0]
		light.set("shadow_enabled", not light.get("shadow_enabled"))
	if event is InputEventKey and not event.is_pressed() and event.scancode == KEY_R:
		var b = res.pop_front()
		res.append(b)
		for child in surface.get_children():
			child.texture_resolution = res[0]
			Globals.build_cards.append(child)
