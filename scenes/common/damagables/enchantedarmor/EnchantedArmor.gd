
extends "res://scenes/common/damagables/BaseEnemy.gd"

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	atk = 100
	def = 0
	hp = 1000
	gold = 150
	ep = 6000
	
	current_hp = hp

	magic_only = true
