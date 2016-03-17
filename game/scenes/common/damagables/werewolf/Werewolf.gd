
extends "res://scenes/common/damagables/RushEnemy.gd"

func _ready():
	follow_player = true
	atk = 50
	def = 10
	hp = 450
	gold = 1500
	ep = 400

	current_hp = hp

	is_consumable = true
	consumable_size = Vector2(4, 1)
	consumable_sprite_offset = Vector2(-32, 0)