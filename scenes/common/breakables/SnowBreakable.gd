
extends "res://scenes/common/breakables/BaseBreakable.gd"

# member variables here, example:
# var a=2
# var b="textvar"

var snow

func _ready():
	snow = get_node("TestSnowSurface")

func crumble():
	remove_child(snow)
	get_tree().get_root().get_node("world/playercontainer/player").remove_from_blacklist(snow.get_node("snow"))
