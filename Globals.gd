extends Node

var nodes = {}
var messages = {}
var _mouse_over:Node
var stack_over:Node

var build_cards = []
var MAX_CARDS = null
var cache_tex = {}
var building_card = false
var tex_res_low = 256
var tex_res_high = 512
var tex_res_very_high = 512

func _ready():
	randomize()

func _process(_delta):
	var i = 0
	# TODO this should be a signal
	if building_card and is_instance_valid(building_card) and not building_card.is_queued_for_deletion():
		return
	var high_amount = build_cards.size() if MAX_CARDS == null else MAX_CARDS
	if build_cards.size():
		while i<min(build_cards.size(), high_amount):
			var c = build_cards.pop_back()
			if is_instance_valid(c) and not c.is_queued_for_deletion():
				c.build()
				if building_card:
					return

func register_node(key, node):
	nodes[key] = node

func get_registered_node(key):
	return nodes[key]

func register_message(func_name, node):
	if not func_name in messages:
		messages[func_name] = []
	messages[func_name].append(node)
	
func call_message(func_name, values):
	if func_name in messages:
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
