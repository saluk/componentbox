tool
extends Button

var iterations = 1000
var ignore_paths = ["addons",".","..",".git",".import"]

func _ready():
	connect("button_down", self, "click")
	
func list_dir(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			iterations -= 1
			if iterations <= 0:
				return
			if file_name in ignore_paths:
				pass
			elif dir.current_is_dir():
				list_dir(path+"/"+file_name)
			else:
				operate_on(path+"/"+file_name)
			file_name = dir.get_next()
	else:
		print("!ERROR accessing:"+path)

func click():
	print("\nstart\n")
	list_dir("res://")

func operate_on(path):
	if not path.ends_with(".gd"):
		return
	print("checking gd file "+path)
	# Group linter:
	#   - define groups
	#   - ensure all calls to find a node in a group belong to defined group
	#   - ensure all nodes that are defined in a group are one of the defined groups
	#   - add a button to the group screen to only select from defined groups?
