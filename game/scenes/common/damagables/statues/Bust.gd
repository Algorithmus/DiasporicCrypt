extends "res://scenes/common/damagables/Static.gd"

# Static enemy that only fires in one orthogonal direction.

export var rateX = 1
export var rateY = 0

func _ready():
	ignore_collision = true
	follow_player = false

func set_animation_direction(new_animation):
	pass

func check_damage():
	pass

func check_attack():
	if (current_attack_delay > 0):
		current_attack_delay += 1
		if (current_attack_delay >= attack_delay):
			current_attack_delay = 0
	if (can_attack() && ai_obj.get("input") == "attack"):
		is_attacking = true
		var projectile_obj = projectile.instance()
		projectile_obj.set("rateX", rateX)
		projectile_obj.set("rateY", rateY*6)
		projectile_obj.set("camera", player.get_node("player/Camera2D"))
		projectile_obj.set("direction", rateX)
		projectile_obj.set_global_pos(Vector2(get_global_pos().x + projectile_offset.x, get_global_pos().y + projectile_offset.y))
		get_parent().add_child(projectile_obj)
	if (is_attacking && animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()):
		is_attacking = false
		current_attack_delay += 1

func step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile):
	accel = 0
	var desiredY = 0
	if (ai_obj.get("vertical_input") == "up"):
		desiredY = -runspeed
		accel = -runspeed
	elif (ai_obj.get("vertical_input") == "down"):
		desiredY = runspeed
		accel = runspeed
	return {"desiredY": desiredY, "slope": false, "slopeTile": null, "abSlope": null, "animationSpeed": animation_speed, "ladderY": 0}

func closestXTile(direction, desiredX, space_state):
	var x = desiredX
	gustx = 0
	return x