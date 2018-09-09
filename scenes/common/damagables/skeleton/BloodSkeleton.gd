
extends "res://scenes/common/damagables/SimpleProjectileEnemy.gd"

func _ready():
	atk = 5
	def = 5
	hp = 100
	gold = 20
	ep = 150

	current_hp = hp

	elemental_weaknesses.append("fire")


