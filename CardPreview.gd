extends ViewportContainer

onready var vp = get_node("Viewport")

var card_copy
var hovered

func _ready():
	Globals.register_message("hover", self)
	Globals.register_message("clear_hover", self)

func hover(node):
	clear_hover()
	hovered = node
	#hovered.texture_resolution = Globals.tex_res_high
	#hovered.rebuild()
	card_copy = load("res://Card.tscn").instance()
	card_copy.template = node.template
	card_copy.values = node.values
	card_copy.translation = Vector3(0,0,0)
	card_copy.texture_resolution = Globals.tex_res_very_high
	vp.get_node("Preview/Component").add_child(card_copy)
	
func clear_hover():
	# TODO should wait here until the preview card is finished rebuilding
	if card_copy != null:
		card_copy = null
		Globals.empty_node(vp.get_node("Preview/Component"))
	#if hovered != null:
	#	hovered.texture_resolution = Globals.tex_res_low
	#	hovered.rebuild()
