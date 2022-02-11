extends Node

var nodes = {}
var messages = {}
var _mouse_over:Node

func register_node(key, node):
	nodes[key] = node

func get_registered_node(key):
	return nodes[key]

func register_message(func_name, node):
	if not func_name in messages:
		messages[func_name] = []
	messages[func_name].append(node)
	
func call_message(func_name, values):
	for ob in messages[func_name]:
		ob.callv(func_name, values)

func empty_node(node):
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func mouse_over(node):
	if _mouse_over != node:
		_mouse_over = node
		
func mouse_exit(node):
	if _mouse_over == node:
		_mouse_over = null
		
func current_mouse_component():
	return _mouse_over
