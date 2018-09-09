
extends "res://scenes/common/damagables/BoomerangProjectileEnemy.gd"

func _ready():
	atk = 80
	def = 10
	hp = 5000
	gold = 200
	ep = 5000

	current_hp = hp

	follow_player = true

	is_consumable = true
	consume_factor = 20
	consumable_size = Vector2(5, 2)
	consumable_sprite_offset = Vector2(-32, -16)

	elemental_protection = ["thunder"]

	var follow_ai = preload("res://scenes/common/damagables/ai/follow.gd")
	ai_obj = follow_ai.new()
	ai_obj.set("target", self)
	ai_obj.set("preferred_distance", 256)
