
extends "res://scenes/bergfortress/boss/ChainTarget.gd"
const RED = Color(1, 58 / 255.0, 58 / 255.0)

func _ready():
	collision_rect.set_name("collision")

func check_hp(damage):
	.check_hp(damage)
	var color = Color(1, 1, 1).linear_interpolate(RED, float(current_hp/hp))
	get_node("sprite").set_modulate(color)
	if (current_hp <= 0):
		queue_free()