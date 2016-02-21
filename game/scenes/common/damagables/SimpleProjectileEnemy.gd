
extends "res://scenes/common/damagables/BaseEnemy.gd"

# Base class for patrol enemy that fires simple projectiles.

var projectile = preload("res://scenes/common/damagables/attacks/fireball.scn")

func _ready():
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
		projectile_obj.set("direction", direction)
		projectile_obj.set_global_pos(Vector2(get_global_pos().x + (sprite_offset.x + TILE_SIZE) * direction, get_global_pos().y))
		get_parent().add_child(projectile_obj)
	if (is_attacking && animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()):
		is_attacking = false
		current_attack_delay += 1

func do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY):
	var new_animation = .do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY)
	if (is_attacking && !is_dying):
		new_animation = "attack"
	return new_animation

func can_attack():
	return !is_attacking && current_attack_delay == 0

func step_player(delta):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	var animation_speed = 1

	ai_obj.step(space_state)

	# position at character's feet
	var forwardY = get_global_pos().y + sprite_offset.y
	var leftX = get_global_pos().x - sprite_offset.x
	var rightX = get_global_pos().x + sprite_offset.x

	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(leftX, forwardY-1), Vector2(leftX, forwardY+16), [self, player.get_node("player")])
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(rightX, forwardY-1), Vector2(rightX, forwardY+16), [self, player.get_node("player")])

	# check regular blocks
	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()

	# check moving platforms before everything else
	var oneWayTile = getOneWayTile(space_state, max(accel, TILE_SIZE))
	var onOneWayTile = check_moving_platforms(normalTileCheck, relevantTileA, relevantTileB, space_state, oneWayTile)

	var areaTiles = damage_rect.get_overlapping_areas()
	# check underwater
	check_underwater(areaTiles)

	# check taking damage
	check_damage()

	# step horizontal motion first
	var horizontal = step_horizontal(space_state)
	var new_animation = horizontal["animation"]
	var horizontal_motion = horizontal["motion"]
	var onSlope = horizontal["slope"]
	var slopeX = horizontal["slopeX"]
	var relevantSlopeTile = horizontal["slopeTile"]
	forwardY = get_global_pos().y + sprite_offset.y

	# check vertical motion
	var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)

	relevantSlopeTile = vertical["slopeTile"]
	var onSlope = vertical["slope"]
	var abSlope = vertical["abSlope"]
	var desiredY = vertical["desiredY"]
	animation_speed = vertical["animationSpeed"]
	var ladderY = vertical["ladderY"]

	# final falling status check for all kinds of collisions
	check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, null, oneWayTile)

	# don't fall while standing on moving platforms moving up
	check_on_moving_platform(desiredY)

	position.y = accel

	check_attack()

	# check status
	check_frozen()
	
	check_stunned()

	if (current_delay > 0):
		current_delay += 1
	if (current_delay >= hurt_delay):
		current_delay = 0

	# check animations
	var animations = check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	animation_speed = animations["animationSpeed"]
	new_animation = animations["animation"]

	calculate_fall_height()

	move(position)
	play_animation(new_animation, animation_speed)
	
	update_status()
	
	cleanup_bloodparticles()