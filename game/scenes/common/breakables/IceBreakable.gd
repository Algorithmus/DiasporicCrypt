
extends "res://scenes/common/breakables/BaseBreakable.gd"

# member variables here, example:
# var a=2
# var b="textvar"

func check_crumble(i):
	return i.get_parent() != null && i.get_parent().get_name() == "Ice"

func sprite_opacity(alpha):
	.sprite_opacity(alpha)
	get_node("KinematicBody2D/ice").set_opacity(alpha)