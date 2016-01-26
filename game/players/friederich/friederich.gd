
extends "res://players/player.gd"

# member variables here, example:
# var a=2
# var b="textvar"

# use for demonic

#func check_ladder_up(a):
#	return 0

#func check_ladder_down(a, b, c, d, e, f):
#	return {"ladderY": 0, "animationSpeed": 1}

#func check_ladder_top(a, b, c):
#	pass

func step_player():
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	var animation_speed = 1

	# position at character's feet
	var forwardY = get_global_pos().y + sprite_offset.y
	var leftX = get_global_pos().x - sprite_offset.x
	var rightX = get_global_pos().x + sprite_offset.x
	
	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(leftX, forwardY-1), Vector2(leftX, forwardY+16), [self])
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(rightX, forwardY-1), Vector2(rightX, forwardY+16), [self])

	# check regular blocks
	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()
	
	# check moving platforms before everything else
	var oneWayTile = getOneWayTile(space_state, max(accel, TILE_SIZE))
	var onOneWayTile = check_moving_platforms(normalTileCheck, relevantTileA, relevantTileB, space_state, oneWayTile)
	
	var areaTiles = damage_rect.get_overlapping_areas()

	# check underwater
	check_underwater(areaTiles)

	# check taking damage
	check_damage(areaTiles)
	
	# step horizontal motion first
	var horizontal = step_horizontal(space_state)
	var new_animation = horizontal["animation"]
	var horizontal_motion = horizontal["motion"]
	var onSlope = horizontal["slope"]
	var slopeX = horizontal["slopeX"]
	var relevantSlopeTile = horizontal["slopeTile"]
	forwardY = get_global_pos().y + sprite_offset.y
	
	# disengage hanging if hurt
	check_hanging_damage()
	
	# check platform climbing after horizontal movement requested
	var climb_vertically = check_climb_platform_horizontal(space_state)

	step_horizontal_damage_throwback()
	
	# check vertical motion
	var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)

	relevantSlopeTile = vertical["slopeTile"]
	var onSlope = vertical["slope"]
	var abSlope = vertical["abSlope"]
	var desiredY = vertical["desiredY"]
	animation_speed = vertical["animationSpeed"]
	var ladderY = vertical["ladderY"]
	
	if (!on_ladder):
		# final falling status check for all kinds of collisions
		check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, ladder_top, oneWayTile)

		# handle crouching now that we know if we are standing on ground blocks
		check_crouch(normalTileCheck, abSlope, onSlope, onOneWayTile)
		
		check_climb_platform_vertical(climb_vertically)

		# don't fall while standing on moving platforms moving up
		check_on_moving_platform(desiredY)

		check_attacking()
	
		position.y = accel
		
	# check animations
	var animations = check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	animation_speed = animations["animationSpeed"]
	new_animation = animations["animation"]

	calculate_fall_height()
	
	move(position)
	play_animation(new_animation, animation_speed)

func _init():
	weapon = preload("res://scenes/weapons/sword.xml")