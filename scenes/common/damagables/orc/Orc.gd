
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	atk = 60
	def = 10
	hp = 500
	gold = 2000
	ep = 300

	current_hp = hp

	is_consumable = true
	consumable_size = Vector2(5, 2)
	consumable_sprite_offset = Vector2(-32, -16)

	elemental_weaknesses.append("ice")
	sunbeam_immunity = true
	set_physics_process(true)
