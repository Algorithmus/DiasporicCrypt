
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	atk = 1
	def = 0
	hp = 50
	gold = 50
	ep = 100

	current_hp = hp
	elemental_weaknesses.append("fire")
	sunbeam_immunity = false
	set_physics_process(true)

# unfortunately needed to be active off screen for some puzzles...
func enter_screen():
	pass

func exit_screen():
	pass
