extends "res://scenes/common/breakables/pot.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func check_crumble(i):
	return .check_crumble(i) || i.get_parent() != null && i.get_parent().get_name() == "Fire"
