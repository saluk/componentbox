extends ViewportContainer

onready var vp = get_node("Viewport")

var card_copy

func _ready():
	Globals.register_message("hover", self)
	Globals.register_message("clear_hover", self)

func hover(node):
	clear_hover()
	card_copy = node.duplicate()
	card_copy.translation = Vector3(0,0,0)
	vp.get_node("Preview/Component").add_child(card_copy)
	
func clear_hover():
	if card_copy != null:
		card_copy = null
		Globals.empty_node(vp.get_node("Preview/Component"))
