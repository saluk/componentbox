extends KinematicBody
class_name Stack

var dragging = false
var push_up = true # pushes up any components dragged on top of it

export var group_with:String

onready var body:Spatial = get_node("Body")
var collision:CollisionShape

var drop_vector = Vector3(0, -1, 0)

var components = []
var top_component = null
export var delete_when_empty = true
export var delete_when_one = true

var stack_scale = 0.1

func build():
	# TODO - Should base this on the component size
	body.scale.x = 501.0/512.0
	body.scale.z = 701.0/512.0
	body.scale.y = (1 * stack_scale * components.size())
	collision.shape.extents.x = 501 * (1.0/512) * 0.5
	collision.shape.extents.z = 701 * (1.0/512) * 0.5
	collision.shape.extents.y = body.scale.y * 0.5 * (stack_scale*.01) #Reverse scaling set in the mesh
	#body.translation.y = collision.shape.extents.y
	#collision.translation.y = collision.shape.extents.y
	reveal_top()
	
func validate():
	if not components and delete_when_empty:
		queue_free()
		return
	if components.size() == 1 and delete_when_one:
		expel_card(components[-1], Vector3(0,0,0))
		queue_free()
		return
	
func reveal_top():
	if top_component and is_a_parent_of(top_component):
		remove_child(top_component)
	if components:
		top_component = components[components.size()-1]
		add_child(top_component)
		top_component.translation = Vector3(
			0,
			body.scale.y * 0.01,  # Convert from base height of mesh
			0)
		top_component.rotation_degrees.y = rand_range(-6.0, 6.0)
		top_component.collision.disabled = true
		
func add_component_to_top(component):
	print("add to top ", component.name)
	if component.get_parent():
		print("remove component from parent")
		component.get_parent().remove_child(component)
	components.append(component)
	build()
	
func add_component_to_bottom(component):
	print("add to bottom ", component.name)
	if component.get_parent():
		component.get_parent().remove_child(component)
	components.insert(0, component)
	build()

func _ready():
	connect("mouse_entered", self, "over_card")
	connect("mouse_exited", self, "left_card")
	collision = get_node("CollisionShape")
	#var card1 = load("res://Card.tscn").instance()
	#card1.template = load("res://templates/magic.tres")
	#components.append(card1)
	#var card2 = load("res://Card.tscn").instance()
	#card2.template = load("res://templates/skeleton.tres")
	#components.append(card2)
	
func move_down():
	var orig_x = translation.x
	var orig_z = translation.z
	var orig_y = translation.y
	var new_y = orig_y
	var new_x = orig_x
	var new_z = orig_z
	var move_again = false
	var col
	while translation.y > 0:
		col = move_and_collide(Vector3(1,1,1) * (drop_vector*0.01))
		new_y = translation.y
		new_x = translation.x
		new_z = translation.z
		if col:
			break
	translation = Vector3(orig_x, orig_y, orig_z)
	var steps = 5.0
	for i in range(steps+1.0):
		var weight = i/steps
		translation = Vector3(
			lerp(translation.x, new_x, weight),
			lerp(translation.y, new_y, weight),
			lerp(translation.z, new_z, weight)
		)
		yield(get_tree(), "idle_frame")
	if col and try_to_group(col.collider):
		if col.collider.has_method("add_component_to_top"):
			print("stack on stack")
			for component in components:
				col.collider.add_component_to_top(component)
			queue_free()
			return
		else:
			add_component_to_bottom(col.collider)

func try_to_group(card):
	if not "group_with" in card:
		return false
	if card.group_with != group_with:
		return false
	translation.x = card.translation.x
	translation.z = card.translation.z
	return true

func grab_stack():
	Globals.call_message("clear_hover", [])
	dragging = true
	translation.y = max(1.0, translation.y+0.5)
	collision.disabled = true
	
func expel_card(card:Card, offset:Vector3):
	if card in components:
		components.erase(card)
	if card == top_component:
		top_component = null
	if is_a_parent_of(card):
		remove_child(card)
	if card.get_parent():
		card.get_parent().remove_child(card)
	get_parent().add_child(card)
	card.owner = get_parent()
	card.rotation_degrees = Vector3(0,-90,0)
	card.rebuild()
	card.translation = translation + offset
	card.collision.disabled = false
	build()
	validate()
	return card
	
func grab_card():
	if not components:
		return
	var card = expel_card(components[-1], Vector3(0,-1,0))
	card.collision.disabled = true
	card.grab()
	
func drop():
	dragging = false
	collision.disabled = false
	move_down()
	Globals.call_message("drop_node", [self])

func get_plane_point(camera:Camera, mouse_position:Vector2):
	var n = Vector3(0, -1, 0)
	var p = camera.project_ray_origin(mouse_position)
	var v = camera.project_ray_normal(mouse_position)
	var d = translation.y
	var t = -(n.dot(p)+d)/n.dot(v)
	return p+t*v
	
func get_drop_vector(mouse_position:Vector2):
	var camera = get_viewport().get_camera()
	var hit_point = get_plane_point(camera, mouse_position)
	return (hit_point - camera.global_transform.origin).normalized()

func translate_movement(event):
	var camera = get_viewport().get_camera()
	var cur_pos = get_viewport().get_mouse_position()
	var prev_pos = cur_pos - event.relative
	var final_3d = get_plane_point(
		camera, cur_pos
	)
	var trans_vector = final_3d - get_plane_point(
		camera, prev_pos
	)
	translation.x = final_3d.x
	translation.z = final_3d.z
	#translation += trans_vector
	
func adjust_height():
	var camera = get_viewport().get_camera()
	var cur_pos = get_viewport().get_mouse_position()
	var _drop_vector = get_drop_vector(cur_pos)
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(
		camera.global_transform.origin, 
		camera.global_transform.origin+_drop_vector*100,[], 1)
	if result.collider and "push_up" in result.collider:
		if translation.y < result.collider.translation.y:
			translation.y = result.collider.translation.y + 1

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			if dragging:
				drop_vector = get_drop_vector(event.position)
				drop()
	if event is InputEventMouseMotion and dragging:
		translate_movement(event)
		adjust_height()
	if event is InputEventKey and event.pressed and event.scancode == KEY_F and Globals.current_mouse_component() == self:
		body.rotation_degrees.z += 180
		Globals.call_message("hover", [self])
	if event is InputEventKey and event.pressed and event.scancode == KEY_D and Globals.current_mouse_component() == self:
		var new_card = duplicate()
		get_parent().add_child(new_card)
		new_card.translation.y = max(2, translation.y+0.5)
		new_card.move_down()

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if not dragging:
				if Input.is_key_pressed(KEY_G):
					grab_stack()
				else:
					grab_card()

func over_card():
	Globals.stack_over = self
	if top_component:
		Globals.mouse_over(top_component)
		if not dragging:
			Globals.call_message("hover", [top_component])

func left_card():
	if top_component:
		Globals.mouse_exit(top_component)
	Globals.stack_over = null
