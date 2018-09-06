extends "res://scenes/common/damagables/Flying.gd"

export var level = 1

const LEVEL2_COLOR = Color(162 / 255.0, 166 / 255.0, 1)

func _ready():
	if (level == 1):
		atk = 1
		def = 0
		hp = 100
		gold = 10
		ep = 50
	elif (level == 2):
		atk = 80
		def = 0
		hp = 600
		gold = 100
		ep = 3500

		get_node("walk").set_modulate(LEVEL2_COLOR)
		get_node("die").set_modulate(LEVEL2_COLOR)
		get_node("hurt").set_modulate(LEVEL2_COLOR)

	current_hp = hp
	ignore_gravity = true
