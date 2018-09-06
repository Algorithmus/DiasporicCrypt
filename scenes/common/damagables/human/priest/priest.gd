
extends "res://scenes/common/damagables/BaseEnemy.gd"

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	hp = 1
	gold = 100
	is_consumable = true
	consumable_size = Vector2(3, 1)
	consumable_sprite_offset = Vector2(-16, 0)

	current_hp = hp