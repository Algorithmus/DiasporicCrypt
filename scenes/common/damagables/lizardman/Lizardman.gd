
extends "res://scenes/common/damagables/BaseEnemy.gd"

export var level = 1

const LEVEL2_COLOR = Color(1, 67 / 255.0, 159 / 255.0)

func _ready():
	if (level == 1):
		atk = 5
		def = 0
		hp = 100
		gold = 30
		ep = 300

	elif (level == 2):
		atk = 80
		def = 10
		hp = 1000
		gold = 120
		ep = 5000

		get_node("walk").set_modulate(LEVEL2_COLOR)
		get_node("die").set_modulate(LEVEL2_COLOR)
		get_node("hurt").set_modulate(LEVEL2_COLOR)

	current_hp = hp
	elemental_weaknesses.append("ice")
	sunbeam_immunity = true
	set_physics_process(true)

# unfortunately needed to be active off screen for some puzzles...
func enter_screen():
	pass

func exit_screen():
	pass

