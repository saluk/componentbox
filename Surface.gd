## 		Container of the rest of the components
## - Forces all of the components to be sorted by height so they are never
##   inside each other

extends Spatial
class_name Surface

export var separation = 0.005

func _ready():
	Globals.register_node("surface", self)
	Globals.register_message("drop_node", self)

func update_heights():
	var y = 0
	for n in get_children():
		n.translation.y = y
		y += separation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_heights()

# Drop a component - move it to the top of the stack
func drop_node(node):
	remove_child(node)
	add_child(node)
