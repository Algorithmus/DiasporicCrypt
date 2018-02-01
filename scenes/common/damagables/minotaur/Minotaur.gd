
extends "res://scenes/common/damagables/BoomerangProjectileEnemy.gd"

func _ready():
	atk = 60
	def = 10
	hp = 500
	gold = 2000
	ep = 500

	current_hp = hp

	follow_player = true

	is_consumable = true
	consumable_size = Vector2(5, 2)
	consumable_sprite_offset = Vector2(-32, -16)

	var follow_ai = preload("res://scenes/common/damagables/ai/follow.gd")
	ai_obj = follow_ai.new()
	ai_obj.set("target", self)
	ai_obj.set("preferred_distance", 256)
