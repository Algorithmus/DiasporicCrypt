
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	atk = 5
	def = 0
	hp = 100
	gold = 150
	ep = 300

	current_hp = hp
	elemental_weaknesses.append("ice")
	sunbeam_immunity = true
	set_fixed_process(true)

# unfortunately needed to be active off screen for some puzzles...
func enter_screen():
	pass

func exit_screen():
	pass
