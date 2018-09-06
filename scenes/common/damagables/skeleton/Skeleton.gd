
extends "res://scenes/common/damagables/BaseEnemy.gd"

export var level = 1

const LEVEL2_COLOR = Color(1, 1, 98.57 / 255)

func _ready():
	if (level == 1):
		atk = 1
		def = 0
		hp = 50
		gold = 10
		ep = 100

	if (level == 2):
		atk = 60
		def = 10
		hp = 700
		gold = 150
		ep = 4000

		get_node("walk").set_modulate(LEVEL2_COLOR)
		get_node("die").set_modulate(LEVEL2_COLOR)
		get_node("hurt").set_modulate(LEVEL2_COLOR)

	current_hp = hp
	elemental_weaknesses.append("fire")
	sunbeam_immunity = false
	set_physics_process(true)

# unfortunately needed to be active off screen for some puzzles...
func enter_screen():
	pass

func exit_screen():
	pass
