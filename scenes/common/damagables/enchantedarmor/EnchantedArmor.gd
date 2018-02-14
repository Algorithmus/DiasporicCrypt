
extends "res://scenes/common/damagables/BaseEnemy.gd"

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	atk = 20
	def = 0
	hp = 200
	gold = 500
	ep = 300
	
	current_hp = hp

	magic_only = true
