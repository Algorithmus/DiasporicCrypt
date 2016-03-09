
extends "res://scenes/common/damagables/RushEnemy.gd"

func _ready():
	is_consumable = true
	consumable_size = Vector2(4, 1)
	consumable_sprite_offset = Vector2(-32, 0)