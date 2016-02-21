
extends "res://scenes/common/damagables/SimpleProjectileEnemy.gd"

# Base class for boomerang attack enemies.

func _ready():
	projectile = preload("res://scenes/common/damagables/attacks/boomerang.scn")
	attack_delay = 30
	pass

func check_attack():
	if (current_attack_delay > 0):
		current_attack_delay += 1
		if (current_attack_delay >= attack_delay):
			current_attack_delay = 0
	if (can_attack() && ai_obj.get("input") == "attack"):
		is_attacking = true
		var projectile_obj = projectile.instance()
		projectile_obj.set("camera", player.get_node("player/Camera2D"))
		projectile_obj.set("origin", weakref(self))
		projectile_obj.set("direction", direction)
		projectile_obj.set_global_pos(Vector2(get_global_pos().x + (sprite_offset.x + TILE_SIZE) * direction, get_global_pos().y))
		get_parent().add_child(projectile_obj)
	if (is_attacking && animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()):
		is_attacking = false
		current_attack_delay += 1