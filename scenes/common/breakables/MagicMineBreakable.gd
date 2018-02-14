
extends "res://scenes/common/breakables/BaseBreakable.gd"

# member variables here, example:
# var a=2
# var b="textvar"

func check_crumble(i):
	return i.get_parent() != null && i.get_parent().get_name() == "MagicMine"

func sprite_opacity(alpha):
	.sprite_opacity(alpha)
	get_node("KinematicBody2D/magicmine").modulate.a = alpha

func remove_visuals():
	var fire = get_node("KinematicBody2D/magicmine")
	remove_child(fire)
	fire.queue_free()

