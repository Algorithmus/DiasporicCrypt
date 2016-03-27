
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	atk = 1
	def = 0
	hp = 50
	gold = 50
	ep = 100

	current_hp = hp
	elemental_weaknesses.append("fire")