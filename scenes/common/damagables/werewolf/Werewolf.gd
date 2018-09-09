
extends "res://scenes/common/damagables/RushEnemy.gd"

func _ready():
	follow_player = true
	atk = 120
	def = 10
	hp = 800
	gold = 200
	ep = 5000

	current_hp = hp

	is_consumable = true
	consume_factor = 15
	consumable_size = Vector2(4, 1)
	consumable_sprite_offset = Vector2(-32, 0)

	elemental_weaknesses.append("magicmine")
	elemental_protection = ["earth"]
