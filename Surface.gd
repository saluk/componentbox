## 		Container of the rest of the components
## - Forces all of the components to be sorted by height so they are never
##   inside each other

extends Spatial
class_name Surface

export var separation = 0.02
var stable = false

func _ready():
	Globals.register_node("surface", self)
	#Globals.register_message("drop_node", self)
		
func stablize():
	#yield(get_tree(), "idle_frame")
	#yield(get_tree(), "idle_frame")
	var children = get_children()
	for i in range(0, children.size()):
		var card = children[i]
		print("init "+card.name+" "+str(card.translation))
		card.translation.y = 2
		yield(get_tree(), "idle_frame")
		card.move_down(true)
		yield(get_tree(), "idle_frame")

# This is setting heights of the cards in order so that there are no overlaps
# But it's probably better to handle this with collisions
func update_heights():
	var y = 0
	for n in get_children():
		n.translation.y = y
		y += separation

func _process(_delta):
	if not stable and Globals.build_cards.size() == 0:
		stablize()
		stable = true

# Drop a component - move it to the top of the stack
func drop_node(node:Node):
	node.get_parent().remove_child(node)
	if not is_a_parent_of(node):
		add_child(node)
