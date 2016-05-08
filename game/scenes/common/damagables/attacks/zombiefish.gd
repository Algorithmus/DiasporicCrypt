
extends "res://scenes/common/damagables/attacks/fireball.gd"

func _ready():
	var angle = atan2(rateX, rateY)
	get_node("sprite").set_rot(angle + PI / 2)
