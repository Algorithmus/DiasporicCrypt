
extends "res://scenes/common/damagables/Flying.gd"

func _ready():
	atk = 1
	def = 0
	hp = 20
	gold = 50
	ep = 50

	current_hp = hp
	sunbeam_immunity = false
