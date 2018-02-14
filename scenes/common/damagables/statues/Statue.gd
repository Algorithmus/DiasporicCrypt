
extends "res://scenes/common/damagables/Static.gd"

func _ready():
	atk = 10
	def = 128
	hp = 50
	gold = 200
	ep = 500

	current_hp = hp

	projectile_offset.y = -72
	ai_obj.set("player_distance", 0)

func set_animation_direction(new_animation):
	#get_node(new_animation).set_scale(Vector2(1, 1))
	pass
	
func check_attack():
	if (current_attack_delay > 0):
		current_attack_delay += 1
		if (current_attack_delay >= attack_delay):
			current_attack_delay = 0
	if (can_attack() && ai_obj.get("input") == "attack"):
		is_attacking = true
		var projectile_obj = projectile.instance()
		var offsetX = player.get_node("player").get_global_position().x - (get_global_position().x + projectile_offset.x)
		var offsetY = player.get_node("player").get_global_position().y - (get_global_position().y + projectile_offset.y)
		var speed = projectile_obj.get("speed")
		var unit_length = sqrt(pow(offsetX, 2.0) + pow(offsetY, 2.0))
		var factor = speed / unit_length
		projectile_obj.set("rateX", offsetX * factor)
		projectile_obj.set("rateY", offsetY * factor)
		projectile_obj.set("camera", player.get_node("player/Camera2D"))
		projectile_obj.set("direction", direction)
		projectile_obj.set_global_position(Vector2(get_global_position().x + projectile_offset.x, get_global_position().y + projectile_offset.y))
		get_parent().add_child(projectile_obj)
	if (is_attacking && animation_player.get_current_animation_length() == animation_player.get_current_animation_position()):
		is_attacking = false
		current_attack_delay += 1
