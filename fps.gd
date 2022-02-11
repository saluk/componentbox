extends Label

const TIMER_LIMIT = 0.1
var timer = 0.05

func _process(delta):
	text = "fps: " + str(Engine.get_frames_per_second())
