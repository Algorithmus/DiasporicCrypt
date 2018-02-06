
extends "res://players/player.gd"

var MAX_SWING_SPEED = PI/12
const MAX_SWING_RADIUS = 96
const MIN_SWING_RADIUS = 32
var MIN_SWING_RANGE = PI/16
var SWING_RANGE_DELTA = PI/24
var SWING_RADIUS_DELTA = 5
var HANG_SPEED = 5

var swing_angle = 0
var swing_radius = 0
var swing_speed = 0
var swing_range = 0
var is_swinging = false
var swing_block = null
var swing_direction = 0
var swing_speed_frame = 0
var attack_modifier = ""

var whip_hanging = false
var wall_hanging = false
var jump_requested = false
var wall_direction
var air_jump = 0
var MAX_JUMP = 2

var wall_hanging_delay = 30
var current_wall_hanging_delay = 0

# Unfortunately, double jumps off of walls are hard to execute properly since some players may not notice that you have to press
# the jump button at least slightly before the direction keys to get the extra jump (or else disengaging the wall counts as a "jump"
# but not in an obvious way, especially if you press the jump button just after the direction keys). This also gives you less control
# as well since you are forced to move up rather than away at first if you want the extra jump. So we give players an extra 10 frames 
# in which to press the jump button after disengaging, and we won't count that jump as the extra jump, and players will still have an
# extra jump they can use later.
var wall_jump_max_period = 10
var wall_jump_grace_period = 0

var whipswing = preload("res://players/adela/actions/whipswing.tscn")
var whipswing_obj

func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	var animations = .check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	if (!gameover):
		if ((is_swinging || whip_hanging) && !is_transforming):
			animations["animation"] = "swing"
			animations["animationSpeed"] = 0
			get_node("NormalSpriteGroup/"+new_animation).set_scale(Vector2(direction, 1))
		if (wall_hanging):
			animations["animation"] = "wall"
			get_node("NormalSpriteGroup/wall").set_scale(Vector2(wall_direction, 1))
	return animations

func closestXTile(desired_direction, desiredX, space_state):
	var xpos = .closestXTile(desired_direction, desiredX, space_state)
	if (falling && is_demonic && !is_hurt):
		var wallcheck = closestXTile_area_check(desired_direction, desiredX, space_state)
		if (wallcheck == 0 && current_wall_hanging_delay == 0):
			wall_hanging = true
			air_jump = 0
			jump_requested = false
			current_wall_hanging_delay = 1
			accel = 0
			wall_direction = desired_direction
	return xpos

func closestXTile_area_check(desired_direction, desiredX, space_state):
	var frontTile = space_state.intersect_ray(Vector2(get_global_position().x + desired_direction * sprite_offset.x + desiredX, get_global_position().y - sprite_offset.y), Vector2(get_global_position().x + desired_direction * sprite_offset.x + desiredX, get_global_position().y + sprite_offset.y - 1), [self], 524288)
	if (frontTile != null && frontTile.has("collider") && !frontTile["collider"].has_node("climbable")):
		return 0
	return desiredX

func check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, ladder_top, oneWayTile):
	.check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, ladder_top, oneWayTile)
	if (wall_hanging):
		falling = false

func jumping_allowed():
	if (is_demonic):
		var allowed = ((air_jump < MAX_JUMP || (!falling && air_jump == 0) || wall_hanging) && !is_attacking && jump_requested) || .jumping_allowed()
		return allowed
	else:
		return .jumping_allowed()

func check_jump():
	.check_jump()
	if (jumpPressed):
		jump_requested = false
		wall_hanging = false
		current_wall_hanging_delay += 1

func do_attack():
	weapon_collider.rotation = 0
	.do_attack()
	if (!is_crouching):
		weapon_collider.set_position(Vector2(weapon_collider.get_position().x, weapon_collider.get_position().y + TILE_SIZE))
	attack_modifier = ""
	if (input_up() && !is_crouching):
		if (input_left() || input_right()):
			weapon_collider.rotation = -direction*PI/4
			weapon_collider.set_position(Vector2(direction*(weapon_offset.x/2 + TILE_SIZE), -sprite_offset.y - sqrt(pow(weapon_offset.x, 2)/2) - 2))
			attack_modifier = "dg"
		else:
			weapon_collider.rotation = PI/2
			weapon_collider.set_position(Vector2(0, -sprite_offset.y - weapon_offset.x - 2))
			attack_modifier = "u"
	if (input_down() && falling):
		if (input_left() || input_right()):
			weapon_collider.rotation = direction*PI/4
			weapon_collider.set_position(Vector2(direction*(weapon_offset.x/2 + TILE_SIZE), sprite_offset.y + sqrt(pow(weapon_offset.x, 2)/2) + 2 - TILE_SIZE))
			attack_modifier = "ddg"
		else:
			weapon_collider.rotation = PI/2
			weapon_collider.set_position(Vector2(0, sprite_offset.y + weapon_offset.x + 2))
			attack_modifier = "d"

func step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile):
	if (wall_hanging):
		accel = 0
	var step = .step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)
	return step

func disengage_hanging():
	whip_hanging = false
	falling = true
	attack_requested = false
	accel = -JUMP_SPEED * current_gravity
	swing_block = null
	whipswing_obj.hide()
	#TODO - play sounds properly
	#whipswing_obj.get_node("sound").stop_all()
	if (input_up()):
		accel -= 4

func step_player(delta):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	var animation_speed = 1

	# position at character's feet
	var forwardY = get_global_position().y + sprite_offset.y
	var leftX = get_global_position().x - sprite_offset.x
	var rightX = get_global_position().x + sprite_offset.x
	
	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(leftX, forwardY-1), Vector2(leftX, forwardY+16), [self], 524288)
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(rightX, forwardY-1), Vector2(rightX, forwardY+16), [self], 524288)

	# check regular blocks
	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()
	
	var onOneWayTile = false
	var oneWayTile = null
	
	var new_animation = current_animation
	
	if (!gameover):
		if (!is_swinging && !whip_hanging):
			# check moving platforms before everything else
			oneWayTile = getOneWayTile(space_state, max(accel, TILE_SIZE))
			onOneWayTile = check_moving_platforms(normalTileCheck, relevantTileA, relevantTileB, space_state, oneWayTile)
		
		var areaTiles = damage_rect.get_overlapping_areas()
	
		if (!is_swinging && !whip_hanging):
			# check underwater
			check_underwater(areaTiles)
	
		# check taking damage
		check_damage(areaTiles)
		
		var horizontal_motion = false
		var ladderY = 0
		if (!is_swinging && !whip_hanging):
			# step horizontal motion first
			# still allow the possibility to change direction while charging
			if (is_charging):
				var old_dir = direction
				if (input_left()):
					direction = -1
				elif (input_right()):
					direction = 1
				if (old_dir != direction && magic_spells[selected_spell]["id"] == "void"):
					void_direction = void_direction * -1
					var offset = 2 * get_global_position().x - charge_obj.get_global_position().x
					charge_obj.set_global_position(Vector2(offset, get_global_position().y))
			var horizontal = step_horizontal(space_state)
			new_animation = horizontal["animation"]
			horizontal_motion = horizontal["motion"]
			var onSlope = horizontal["slope"]
			var slopeX = horizontal["slopeX"]
			var relevantSlopeTile = horizontal["slopeTile"]
			forwardY = get_global_position().y + sprite_offset.y
			
			# disengage hanging if hurt
			check_hanging_damage()
		
			# check platform climbing after horizontal movement requested
			var climb_vertically = check_climb_platform_horizontal(space_state)
		
			step_horizontal_damage_throwback()
			
			# check vertical motion
			var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)
		
			relevantSlopeTile = vertical["slopeTile"]
			onSlope = vertical["slope"]
			var abSlope = vertical["abSlope"]
			var desiredY = vertical["desiredY"]
			animation_speed = vertical["animationSpeed"]
			ladderY = vertical["ladderY"]
			
			check_magic_allowed()
			
			if (!on_ladder):
				# final falling status check for all kinds of collisions
				check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, ladder_top, oneWayTile)
		
				# handle crouching now that we know if we are standing on ground blocks
				check_crouch(space_state, normalTileCheck, abSlope, onSlope, onOneWayTile)
				
				check_climb_platform_vertical(climb_vertically)
		
				# don't fall while standing on moving platforms moving up
				check_on_moving_platform(desiredY)
		
				check_attacking()
			
				pos.y = accel
				
				check_blood(areaTiles)
				
				check_magic()
			else:
				step_shield()
		elif (is_swinging):
			request_spell_change = 0
			# disable attacking from fixed process rather than when exactly collision is detected
			if (weapon_collided):
				remove_weapon_collider()
				weapon_collided = false
	
			# swinging algorithm is not in the blog article
			# I made my own. Loosely modelled after the swinging mechanics
			# and behavior in Super Castlevania IV (or what I could gleam from it anyways).
			
			# Swinging is treated similarly to ladders. Presumably, you will only use these where
			# the blocks are positioned far away from any collision type objects except damagables.
			# Also, this is not tested for swinging 2PI cycles. It is only guaranteed to work for swinging
			# between 0 and PI angles.
			# So ignore all collision detection except taking damage while swinging.
			# First, detect that your attack hits the appropriate block (see below on overriden weapon collision signal)
			# Then determine:
			
			# -the current radius (hypotenuse/distance away from the swing block)
			# -current angle. Treat the swing block as the origin, and the angle is between the
			# x-axis and the current radius.
			# -range. This determines the angles between 0 and PI that the player is allowed to swing between. 
			# If it is PI/2, no "swinging" occurs. The swinging range is basically PI - range * 2 (on both ends)
			# -swinging speed. On smaller range values, swinging speed will be higher. You can always get a swing speed
			# value so long as the range is determined.
			# -swinging direction. Default to the player's current direction on entering swinging.
			# We also assume the swinging range is based on the current angle so that the player is
			# at the start of the swing.
			
			# When swinging, first determine changes to speed/range and/or radius from
			# player interaction. Then update the angle a specific amount depending on range and speed.
			# If reaching the end, we change the swinging direction and decrease the swing speed and range. We update the angle a small amount because
			# being stuck at 0 is undesirable.
			# The appropriate player coordinates are determined from the updated angle. Also update
			# the whip display based on updated variables.
			
			# Swinging is only active when the attack button is held down. When released, we provide a small amount of vertical thrust
			# depending on the current speed and position of the player during the end of the swing.
			
			# update swing speed from user interaction, but only once per swing
			if (swing_speed_frame < 2 && ((input_left() && (swing_direction < 0 || swing_speed == 0)) || (input_right() && (swing_direction > 0 || swing_speed == 0)))):
				swing_range = max(swing_range - SWING_RANGE_DELTA, MIN_SWING_RANGE)
				swing_speed = MAX_SWING_SPEED * cos(swing_range)
				# still allow increase in swing speed from either direction when completely stopped
				if (input_left()):
					swing_direction = -1
				else:
					swing_direction = 1
				swing_speed_frame += 1
			# update swing radius from user interaction
			if (input_up()):
				swing_radius = max(MIN_SWING_RADIUS, swing_radius - SWING_RADIUS_DELTA)
	
			if (input_down()):
				swing_radius = min(MAX_SWING_RADIUS, swing_radius + SWING_RADIUS_DELTA)
			# don't bother calculating swinging position and just clamp to position directly below swing block if there is not enough
			# swinging speed
			#TODO - play sounds properly
			#$if (!whipswing_obj.get_node("sound").is_active()):
			#	whipswing_obj.get_node("sound").play("whipswing")
			if (swing_speed != 0 && PI/2 - swing_range != 0):
				var angle_delta = sin((PI/2)*(swing_angle - swing_range)/(PI/2 - swing_range)) * swing_direction
				# don't get stuck at updating angle with 0 change
				angle_delta = max(deg2rad(1), abs(angle_delta)) * swing_direction
				swing_angle += angle_delta * swing_speed
				# detect reaching end of swing
				if ((swing_angle >= PI - swing_range && swing_direction > 0) || (swing_angle <= swing_range && swing_direction < 0)):
					swing_direction = swing_direction * -1
					swing_range = min(PI/2, swing_range + SWING_RANGE_DELTA)
					swing_angle = PI * (swing_direction - 1) / -2 + (swing_range + deg2rad(1))* swing_direction
					swing_speed = MAX_SWING_SPEED * cos(swing_range)
					# clamp to exactly 0 speed if we've reached that point and stop moving
					if (int(swing_speed*1000) == 0 || swing_speed == 0):
						swing_speed = 0
						swing_angle = PI/2
						swing_range = PI/2
					swing_speed_frame = 0
			else:
				swing_angle = PI/2
				swing_range = PI/2
			var swingX = swing_block.get_global_position().x - cos(swing_angle)*swing_radius
			var swingY = swing_block.get_global_position().y + sin(swing_angle)*swing_radius
			var swingPlayerY = swingY - get_global_position().y + sprite_offset.y
			_collider = move_and_collide(Vector2(swingX - get_global_position().x, swingPlayerY))
			whipswing_obj.set_global_position(swing_block.get_global_position())
			whipswing_obj.rotation = -swing_angle + PI/2
			whipswing_obj.get_node("whip").set_scale(Vector2(1, swing_radius-4))
			if(!Input.is_action_pressed("ui_attack")):
				stop_swinging()
		elif(whip_hanging):
			if (swing_block.get_parent().get_parent() != null && swing_block.get_global_position().y < get_global_position().y):
				request_spell_change = 0
				if (weapon_collided):
					weapon_collided = false
					remove_weapon_collider()
				#TODO - play sounds properly
				#if (!whipswing_obj.get_node("sound").is_active()):
				#	whipswing_obj.get_node("sound").play("whipswing")
				if (Input.is_action_pressed("ui_attack")):
					var deltaX = 0
					if (input_up()):
						swing_radius = max(MIN_SWING_RADIUS, swing_radius - SWING_RADIUS_DELTA)
					elif (input_down()):
						swing_radius = min(MAX_SWING_RADIUS, swing_radius + SWING_RADIUS_DELTA)
					_collider = move_and_collide(Vector2(0, swing_block.get_global_position().y + swing_radius - get_position().y + sprite_offset.y))
					whipswing_obj.rotation = 0
					whipswing_obj.set_position(Vector2(0, -sprite_offset.y - swing_radius))
					whipswing_obj.get_node("whip").set_scale(Vector2(1, swing_radius-4))
				else:
					disengage_hanging()
			else:
				disengage_hanging()

		check_demonic()
		
		var disengage_wall = wall_hanging && ((wall_direction > 0 && input_left()) || (wall_direction < 0 && input_right()))
		if (is_hurt || input_down() || !is_demonic || disengage_wall):
			wall_hanging = false
			if (wall_direction && wall_direction != 0 && is_demonic):
				falling = false
			current_wall_hanging_delay += 1
			if (disengage_wall && wall_jump_grace_period == 0):
				wall_jump_grace_period = 1
	
		regenerate_mp()
	
		# check animations
		var animations = check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
		animation_speed = animations["animationSpeed"]
		new_animation = animations["animation"]
	
		calculate_fall_height()
		
		if (wall_hanging):
			pos.y = min(pos.y, 0)
			
		if (current_wall_hanging_delay > 0):
			current_wall_hanging_delay += 1
			if (current_wall_hanging_delay >= wall_hanging_delay):
				current_wall_hanging_delay = 0
	
		if (wall_jump_grace_period > 0):
			wall_jump_grace_period += 1
			if (wall_jump_grace_period >= wall_jump_max_period):
				wall_jump_grace_period = 0

		if (!falling):
			air_jump = 0
	
		if (!is_swinging && !whip_hanging):
			_collider = move_and_collide(pos)

		step_camera()
	else:
		new_animation = "gameover"
		animation_speed = 1
		if (!animation_player.is_playing()):
			get_tree().get_root().get_node("world").show_gameover()
			get_tree().set_pause(true)
	play_animation(new_animation, animation_speed)

func _init():
	weapon = preload("res://scenes/weapons/whip.tscn")

func stop_swinging():
	is_swinging = false
	attack_requested = false
	accel = min(-JUMP_SPEED*abs(cos((PI/2)*(swing_angle - swing_range)/(PI/2 - swing_range))), 0)
	whipswing_obj.hide()
	#TODO - play sounds properly
	#whipswing_obj.get_node("sound").stop_all()
	swing_speed_frame = 0

func _ready():
	runspeed = 9
	jumpspeed = 22
	defaultfallheight = jumpspeed * (jumpspeed - 1)/2

	base_hp = 200
	base_mp = 120
	current_mp = base_mp
	current_hp = base_hp
	hp = base_hp
	mp = base_mp
	base_atk = 45
	base_def = 13
	base_mag = 18
	base_luck = 15

	set_stats()

	demonic_atk = 0.15
	demonic_def = 0.15
	demonic_hp = 0.15
	demonic_mp = 0.2
	demonic_mag = 0.2
	demonic_luck = 1

	exp_growth = preload("res://players/adela/AdelaExpGrowth.gd")
	exp_growth_obj = exp_growth.new()
	exp_growth_obj.setup(level)

	demonic_sprite = preload("res://players/adela/demonic/demonic.tscn")
	demonic_sprite_obj = demonic_sprite.instance()
	
	default_sprite = get_node("NormalSpriteGroup")

	demonic_display.get_node("demonic/sprite/adela").show()

	weapon_collider.disconnect("body_entered", self, "_on_weapon_body_collision")

	whipswing_obj = whipswing.instance()
	add_child(whipswing_obj)
	whipswing_obj.hide()
	
	weapon_type = "whip"
	var available_spells = ProjectSettings.get("available_spells")
	if (available_spells != null && available_spells.size() > 0):
		magic_spells = available_spells
	else:
		var spells = ProjectSettings.get("magic_spells")
		for i in range(0, spells.size()):
			if (spells[i].id == "ice"):
				magic_spells.append(spells[i])
		ProjectSettings.set("available_spells", magic_spells)
	selected_spell = 0
	spell_icons.get_node(magic_spells[selected_spell]["id"]).show()
	update_fusion()

func check_attack_animation(new_animation):
	if (is_attacking):
		var modifier = ""
		if (is_crouching):
			modifier = "d"
		if (falling):
			modifier = "a"
		new_animation = attack_modifier + modifier + "attack"
		# allow downward air attacks to complete if landing
		if (new_animation == "ddgattack"):
			new_animation = "ddgaattack"
		if (new_animation == "dattack" && attack_modifier == "d"):
			new_animation = "daattack"
	return new_animation

func play_animation(animation, speed):
	.play_animation(animation, speed)
	if (whip_hanging && animation == "swing"):
		animation_player.seek(0.2, true)
	if (is_swinging && animation == "swing"):
		animation_player.seek(fmod(fposmod(direction*(floor(swing_angle*4/(PI - MIN_SWING_RANGE * 2))-(direction - 1)/2), 5), 5)*0.1, true)

func update_fusion():
	.update_fusion()
	var current_spell = magic_spells[selected_spell]
	var auracolor = current_spell["auracolor"]
	var weaponcolor1 = current_spell["weaponcolor1"]
	var weaponcolor2 = current_spell["weaponcolor2"]
	
	update_attack_color("uattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("uaattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("daattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("dgattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("dgaattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("ddgaattack", auracolor, weaponcolor1, weaponcolor2)
	whipswing_obj.get_node("whipring").get_material().set_shader_param("modulate", weaponcolor1)
	whipswing_obj.get_node("whipring").get_material().set_shader_param("aura_color", weaponcolor2)
	whipswing_obj.get_node("whip").get_material().set_shader_param("modulate", weaponcolor1)
	whipswing_obj.get_node("whip").get_material().set_shader_param("aura_color", weaponcolor2)

func _input(event):
	if (!is_transforming):
		if (event.is_action_pressed("ui_jump") && event.is_pressed() && !event.is_echo()):
			if (is_demonic && falling && !wall_hanging && wall_jump_grace_period == 0):
				air_jump += 1
			jump_requested = true

func _on_weapon_collision(area):
	._on_weapon_collision(area)
	if (area.get_name() == "oneway"):
		weapon_collided = false
	# detect hitting a swinging block
	if (area.get_name() == "swingable" && !is_swinging && !is_transforming):
		weapon_collided = true
		is_attacking = false
		is_swinging = true
		swing_block = area
		swing_direction = direction
		var swingX = area.get_global_position().x - get_global_position().x
		var new_radius = sqrt(pow(swingX, 2) + pow(area.get_global_position().y - get_global_position().y + sprite_offset.y, 2))
		swing_angle = acos(swingX/new_radius)
		swing_range = fposmod(swing_angle * swing_direction, PI/2)
		swing_radius = min(new_radius, MAX_SWING_RADIUS)
		swing_speed = MAX_SWING_SPEED*cos(swing_range)
		whipswing_obj.show()
		whipswing_obj.get_node("whipring").show()
		#TODO - play sounds properly
		#whipswing_obj.get_node("sound").play("whipswing")
	if (area.get_name() == "hangable" && !whip_hanging && !is_transforming):
		weapon_collided = true
		is_attacking = false
		whip_hanging = true
		#var new_radius = sqrt(pow(area.get_global_position().x - get_global_position().x, 2) + pow(area.get_global_position().y - get_global_position().y + sprite_offset.y, 2))
		swing_radius = MIN_SWING_RADIUS
		swing_block = area
		_collider = move_and_collide(Vector2(swing_block.get_global_position().x - get_global_position().x, swing_block.get_global_position().y + TILE_SIZE/2 - get_position().y + sprite_offset.y + swing_radius))
		whipswing_obj.show()
		whipswing_obj.get_node("whipring").hide()
		#TODO - play sounds properly
		#whipswing_obj.get_node("sound").play("whipswing")
