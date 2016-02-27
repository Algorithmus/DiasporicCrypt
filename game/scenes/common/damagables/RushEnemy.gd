
extends "res://scenes/common/damagables/BaseEnemy.gd"

# Base class for enemy that uses charging attacks.
var default_runspeed
var rush_duration = 50
var rush_current_duration = 0
var rush_direction = 1

func _ready():
	attack_delay = 30
	var follow_ai = preload("res://scenes/common/damagables/ai/follow.gd")
	ai_obj = follow_ai.new()
	ai_obj.set("target", self)
	ai_obj.set("preferred_distance", 128)
	default_runspeed = runspeed
	is_rush = true

func check_attack():
	if (current_attack_delay > 0):
		current_attack_delay += 1
		if (current_attack_delay >= attack_delay):
			current_attack_delay = 0
	if (can_attack() && ai_obj.get("input") == "attack"):
		is_attacking = true
		runspeed = 10
		rush_direction = direction
	if (is_attacking):
		rush_current_duration += 1
		if (rush_duration <= rush_current_duration):
			rush_current_duration = 0
			is_attacking = false
			runspeed = default_runspeed
			current_attack_delay += 1

func do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY):
	var new_animation = .do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY)
	if (is_attacking && !is_dying):
		new_animation = "attack"
	return new_animation

func can_attack():
	return !is_attacking && current_attack_delay == 0

func step_player(delta):
	if (!player_loaded):
		if (player.has_node("player/damage")):
			area2d_blacklist.append(player.get_node("player/damage"))
			player_loaded = true

	# ignore expensive calculations on flying enemies
	if (ignore_collision):
		on_ladder = true
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