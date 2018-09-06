
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	atk = 60
	def = 10
	hp = 500
	gold = 80
	ep = 2000

	current_hp = hp

	is_consumable = true
	consumable_size = Vector2(4, 1)
	consumable_sprite_offset = Vector2(-48, 0)

	elemental_weaknesses.append("ice")
	sunbeam_immunity = true
	set_physics_process(true)
