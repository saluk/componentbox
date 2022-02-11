extends Resource
class_name CardTemplate

#List of card component initializations
export var sides = [
	[
		{"type":"texture", "width":483, "height":715, "path":"card_template.png", "stretch":true},
		{"type":"label", "left":151, "top":36, "right":333, "bottom":81, "var":"name"}
	],
	[
		{"type":"texture", "width":483, "height":715, "path":"cardBack_blue1.png", "stretch":true}
	]
]
