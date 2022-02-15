extends KinematicBody

var dragging = false

export var template:Resource
export var values:Dictionary

var texts = ["Card One1", "Card Two2", "Card Three3"]
var index = 0

onready var body:Spatial = get_node("Body")
onready var collision:CollisionShape = get_node("CollisionShape")

func build():
	print("build card for:", template.sides)
	# Create objects from template
	# Set values from variables
	# For a 2d component like a card:
	#   for each side
	#   create a quad viewport
	#     inside the quad viewport
	#     create components
	var side_obs = [
		"Front",
		"Back"
	]
	for side in template.sides:
		#var vp = Viewport.new()
		var side_name = side_obs.pop_front()
		var vp = get_node("Viewports/"+side_name)
		#vp.name = side_name
		# TODO Get 501, 701 from the texture or maybe the template size
		vp.size = Vector2(501, 701)
		#vp.own_world = true
		#vp.world = World.new()
		#vp.usage = vp.USAGE_2D
		#vp.set_update_mode(Viewport.UPDATE_ALWAYS)
		#get_node("Viewports").add_child(vp)
		#vp.owner = get_node("Viewports")
		#var c = Control.new()
		var c = vp.get_node("Control")
		c.margin_right = 501
		c.margin_bottom = 701
		#c.owner = vp
		#vp.add_child(c)
		var side_mesh = get_node("Body/"+side_name)
		side_mesh.mesh.size = Vector2(501 * (1.0/512), 701 * (1.0/512))
		var mat:Material = side_mesh.get('material/0')
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
				#tr.owner = c
				c.add_child(tr)
				#mat.albedo_texture = teximg
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
		#mat.albedo_texture = ViewportTexture.new()
		#mat.albedo_texture.viewport_path = "Viewports/"+vp.name
		collision.shape.extents.x = vp.size.x * (1.0/512) * 0.5
		collision.shape.extents.z = vp.size.y * (1.0/512) * 0.5

#func update_viewport():
#	viewport.set_update_mode(Viewport.UPDATE_ONCE)
	
#func set_text(t):
#	label.text = t
#	update_viewport()
	
#func set_size():
#	viewport.size = Vector2(control.margin_right, control.margin_bottom)
#	csg.depth = viewport.size.x * (1.0/512)
#	csg.width = viewport.size.y * (1.0/512)
#	collision.shape.extents.x = viewport.size.x * (1.0/512) * 0.5
#	collision.shape.extents.z = viewport.size.y * (1.0/512) * 0.5

func _ready():
	connect("mouse_entered", self, "over_card")
	connect("mouse_exited", self, "left_card")
	build()
	
func drop():
	#translation.y -= 0.5
	for step in range(1/0.01):
		move_and_collide(Vector3(0,-0.01,0))
	Globals.call_message("drop_node", [self])

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			if dragging:
				dragging = false
				drop()
	if event is InputEventMouseMotion and dragging:
		translation += Vector3(event.relative.x / 100, 0, event.relative.y/100)
	if event is InputEventKey and event.pressed and event.scancode == KEY_F and Globals.current_mouse_component() == self:
		body.rotation_degrees.z += 180
		Globals.call_message("hover", [self])
	if event is InputEventKey and event.pressed and event.scancode == KEY_D and Globals.current_mouse_component() == self:
		var new_card = duplicate()
		get_parent().add_child(new_card)

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if not dragging:
				Globals.call_message("clear_hover", [])
				dragging = true
				translation.y = 1

func over_card():
	Globals.mouse_over(self)
	if not dragging:
		Globals.call_message("hover", [self])

func left_card():
	Globals.mouse_exit(self)
