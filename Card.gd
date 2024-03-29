extends KinematicBody
class_name Card

var dragging = false
var push_up = true # pushes up any components dragged on top of it

export var template:Resource
export var values:Dictionary
export var group_with:String

var texts = ["Card One1", "Card Two2", "Card Three3"]
var index = 0

onready var body:Spatial = get_node("Body")
var collision:CollisionShape

var texture_resolution:int

var dirty_jobs = []
var dirty_frames = 2

var drop_vector = Vector3(0, -1, 0)

func get_texture_string(var side_name):
	var s = str(template.get_instance_id()) + "S("+side_name+")"
	s += "G("+group_with+")"
	s += "T("+str(texture_resolution)+")"
	var keys = values.keys()
	keys.sort()
	for k in keys:
		s += "K("+k+")"+"V("+str(values[k])+")"
	return s
	
func get_texture_hash(var side_name):
	return hash(get_texture_string(side_name))
	
func rebuild():
	if not self in Globals.build_cards:
		Globals.build_cards.append(self)

func build():
	var side_obs = [
		"Front",
		"Back"
	]
	body.scale.x = 501.0/512.0
	body.scale.z = 701.0/512.0
	for side in template.sides:
		var side_name = side_obs.pop_front()
		var side_mesh:MeshInstance = get_node("Body/"+side_name)
		build_side(side_name, side, side_mesh)
		
func build_side(side_name, side, side_mesh):
	side_mesh.set("material/0", side_mesh.get("material/0").duplicate())
	if get_texture_hash(side_name) in Globals.cache_tex:
		var tex = Globals.cache_tex[get_texture_hash(side_name)]
		side_mesh.get("material/0").set("albedo_texture", tex)
		return

	Globals.building_card = self

	var vp = Viewport.new()
	vp.name = side_name
	get_node("Viewports").add_child(vp)
	# TODO Get 501, 701 from the texture or maybe the template size
	var tw = 256
	var th = 256
	var ta = tw/th
	var rw = 501
	var rh = 701
	var ra = rw/rh
	var skew_w = rw/tw
	var skew_h = rh/th
	vp.size = Vector2(501, 701)
	vp.usage = vp.USAGE_2D
	vp.set_update_mode(Viewport.UPDATE_ALWAYS)
	var c = Control.new()
	c.margin_right = 501
	c.margin_bottom = 701
	vp.add_child(c)

	#side_mesh.mesh.size = Vector2(501 * (1.0/512), 701 * (1.0/512))
	for component in side:
		if component['type'] == 'texture':
			var tr = TextureRect.new()
			var file = File.new()
			file.open("user://"+component['path'], File.READ)
			var texdat = file.get_buffer(file.get_len())
			var img = Image.new()
			img.load_png_from_buffer(texdat)
			var teximg = ImageTexture.new()
			teximg.create_from_image(img)
			tr.texture = teximg
			tr.expand = true
			tr.margin_right = 501
			tr.margin_bottom = 701
			c.add_child(tr)
		if component['type'] == 'label':
			var lbl:Label = Label.new()
			c.add_child(lbl)
			lbl.set("custom_fonts/font", load("res://fonts/robotto/robotto.tres"))
			lbl.get("custom_fonts/font").size = 42
			lbl.set("custom_colors/font_color", Color(0,0,0))
			lbl.set("custom_colors/font_outline_modulate", Color(1,1,1))
			lbl.text = values.get(component['var'], 'default')
			lbl.margin_left = component['left']
			lbl.margin_right = component['right']
			lbl.margin_top = component['top']
			lbl.margin_bottom = component['bottom']
	
	# get the texture from the viewport
	#copy_to_texture(vp, side_mesh, side_name)
	dirty_jobs.append([vp, side_mesh, side_name])
	dirty_frames = 2
		
func copy_to_texture(vp:Viewport, side_mesh:MeshInstance, side_name:String):
	if not vp or not side_mesh or not side_name:
		return
	var img = vp.get_texture().get_data()
	img.resize(texture_resolution, texture_resolution)
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	side_mesh.get("material/0").set("albedo_texture", tex)
	print("caching", get_texture_string(side_name))
	Globals.cache_tex[get_texture_hash(side_name)] = tex
	get_node("Viewports").remove_child(vp)
	vp.queue_free()
	Globals.building_card = null
	
func _process(_delta):
	if dirty_frames > 0 and dirty_jobs:
		dirty_frames -= 1
		if dirty_frames == 0:
			for job in dirty_jobs:
				copy_to_texture(job[0], job[1], job[2])
			dirty_jobs.empty()
			collision.shape.extents.x = 501 * (1.0/512) * 0.5
			collision.shape.extents.z = 701 * (1.0/512) * 0.5
			rotation_degrees.y = -90 + rand_range(-6.0,6.0)

func _ready():
	connect("mouse_entered", self, "over_card")
	connect("mouse_exited", self, "left_card")
	if not texture_resolution:
		texture_resolution = Globals.tex_res_low
	collision = get_node("CollisionShape")
	rebuild()
	#translation.y = 1
	#move_down()
	
func move_down(instant=false):
	if not is_instance_valid(self) or is_queued_for_deletion() or not get_owner():
		print(name+" not valid")
		return
	if not get_tree():
		print(name+" not in tree")
		return
	print("move down "+name)
	var orig_x = translation.x
	var orig_z = translation.z
	var orig_y = translation.y
	var new_y = orig_y
	var new_x = orig_x
	var new_z = orig_z
	var move_again = false
	var col
	while translation.y > 0.1:
		col = move_and_collide(Vector3(1,1,1) * (drop_vector*0.25))
		new_y = translation.y
		new_x = translation.x
		new_z = translation.z
		if col:
			print(col.position)
			translation.y = col.position.y-0.24
			new_y = translation.y
			break
	if not instant:
		translation = Vector3(orig_x, orig_y, orig_z)
		var steps = 5.0
		for i in range(steps+1.0):
			var weight = i/steps
			translation = Vector3(
				lerp(translation.x, new_x, weight),
				lerp(translation.y, new_y, weight),
				lerp(translation.z, new_z, weight)
			)
			if not get_tree():
				return
			yield(get_tree(), "idle_frame")
	if col and try_to_group(col.collider):
		if col.collider.has_method("add_component_to_top"):
			print("add card "+name+" to stack "+col.collider.name)
			col.collider.add_component_to_top(self)
		else:
			print("create stack for ", col.collider.name, " and ", name)
			var stack = load("res://Stack.tscn").instance()
			get_parent().add_child(stack)
			stack.group_with = group_with
			stack.translation = translation
			stack.add_component_to_top(col.collider)
			stack.add_component_to_top(self)
	else:
		print(name+" didn't hit anything to group with. col was "+str(col))

func try_to_group(card):
	if not "group_with" in card:
		return false
	if card.group_with != group_with:
		return false
	translation.x = card.translation.x
	translation.z = card.translation.z
	return true

func grab():
	Globals.call_message("clear_hover", [])
	dragging = true
	translation.y = max(1.0, translation.y+0.5)
	collision.disabled = true
	
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
	if "collider" in result and "push_up" in result.collider:
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
		copy_card()
		
func copy_card():
	var new_card = duplicate()
	get_parent().add_child(new_card)
	new_card.owner = get_parent()
	new_card.translation.y = max(2, translation.y+0.5)
	new_card.move_down()

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if not dragging:
				grab()

func over_card():
	Globals.mouse_over(self)
	if not dragging:
		Globals.call_message("hover", [self])

func left_card():
	Globals.mouse_exit(self)
