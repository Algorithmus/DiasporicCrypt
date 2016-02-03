
extends "res://players/player.gd"

var attack_buffer = []
var chaingui
var chain_counter = 0
var chain_delay = 60
var current_chain_delay = 0
var chain_next = false # whether or not to show the second chain attack animation
var chain_animation = ""
var chain_collider
var chain_collided = false
var attack_reset_interrupt = false
var direction_requested = ""
var chain_specials = [{"combo":"a, a, d", "id":"chop", "replace":"aad", "collider":preload("res://scenes/weapons/chop.scn"), "collider_offset":Vector2(0, 0), "db":10}]
var target_enemy
var is_chain_special = false
var current_chain_special
var special_collider
var target_enemy_offset

const MAX_CHAIN = 100

# use for demonic

#func check_ladder_up(a):
#	return 0

#func check_ladder_down(a, b, c, d, e, f):
#	return {"ladderY": 0, "animationSpeed": 1}

#func check_ladder_top(a, b, c):
#	pass

func _ready():
	chaingui = get_tree().get_root().get_node("world/gui/CanvasLayer/chain")
	
	chain_collider = weapon.instance()

	chain_collider.connect("area_enter", self, "_on_chain_collision")

func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	if (!is_chain_special):
		return .check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	else:
		get_node("NormalSpriteGroup/"+new_animation).set_scale(Vector2(direction, 1))
		return {"animationSpeed": animation_speed, "animation": new_animation}

func check_attack_animation(new_animation):
	if (is_attacking):
		var modifier = ""
		if (is_crouching):
			modifier = "d"
			chain_animation = ""
		if (falling):
			modifier = "a"
		new_animation = modifier + chain_animation + "attack"
	return new_animation

func check_attacking():
	.check_attacking()
	if (chain_collided):
		chain_collided = false
		remove_chain_collider()
	
	if ((animation_player.get_current_animation().match("*chainattack") && animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()) || climbing_platform || hanging || on_ladder):
		remove_chain_collider()

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
	
	var new_animation = current_animation
	var horizontal_motion = false
	var ladderY = 0
	
	# chain specials are "choreographed". So ignore all other 
	# collision detections while it is in progress.
	if (!is_chain_special):
		# step horizontal motion first
		var horizontal = step_horizontal(space_state)
		new_animation = horizontal["animation"]
		horizontal_motion = horizontal["motion"]
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
		ladderY = vertical["ladderY"]
		
		if (!on_ladder):
			# final falling status check for all kinds of collisions
			check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, ladder_top, oneWayTile)
	
			# handle crouching now that we know if we are standing on ground blocks
			check_crouch(normalTileCheck, abSlope, onSlope, onOneWayTile)
			
			check_climb_platform_vertical(climb_vertically)
	
			# don't fall while standing on moving platforms moving up
			check_on_moving_platform(desiredY)
	
			check_attacking()
			
			# chaining system
			# Chain attacks are a series of consecutive attacks. They are
			# only triggered while attacking enemies or certain other objects.
			# There are two types of basic chain attack animations.
			# All valid chain attacks and directional inputs (well, just three of them anyways)
			# are stored in the attack buffer.
			# When a special attack combo is recognized, remove all the inputs required to
			# create it and merge it into a single input. Special attacks work slightly
			# differently from regular attacks and are handled differently.
			# chain attacking is cancelled when the player is hurt, there is no attack input
			# after a certain amount of time or the maximum number of chain attacks are reached. 
			# when cancelling the chain, clear the attack buffer.
			
			# add direction buttons to chain specials if applicable
			if (direction_requested != ""):
				attack_buffer.append(direction_requested)
				direction_requested = ""
			
			# check attack buffer for chain special combos
			if (attack_buffer.size() > 1):
				var combos = str(attack_buffer)
				for combo in chain_specials:
					var combopos = combos.rfind(combo["combo"])
					if(combopos >= 0):
						hit_enemy = false
						remove_weapon_collider()
						remove_chain_collider()
						weapon_collided = false
						chain_collided = false
						is_attacking = false
						attack_requested = false
						chain_next = false
						chain_counter += 1
						chaingui.get_node("chaintext/counterGroup/counter").set_text(str(chain_counter))
						chaingui.get_node("AnimationPlayer").play("counter")
						# merge combo in attack buffer
						var parta = combos.substr(0, combopos)
						var partb = combos.substr(combopos+combo["combo"].length(), combos.length())
						attack_buffer = convert(str(parta + combo["replace"] + partb).split(", "), TYPE_ARRAY)
						# setup special attack
						is_chain_special = true
						current_chain_special = combo
						current_chain_delay = 0
						special_collider = current_chain_special["collider"].instance()
						var special_offset = special_collider.get_node("weapon").get_shape().get_extents()
						special_collider.set_pos(Vector2(((special_offset.x + sprite_offset.x + 4) + current_chain_special["collider_offset"].x) * direction, current_chain_special["collider_offset"].y))
						add_child(special_collider)
						get_node("sound").set_volume_db(get_node("sound").play(current_chain_special["id"]), current_chain_special["db"])
						new_animation = current_chain_special["id"]
						special_collider.connect("area_enter", self, "_on_special_collision")
			
			# if attack connects with an enemy, count it as an attack in the attack buffer
			if (hit_enemy):
				hit_enemy = false
				attack_reset_interrupt = true
				current_chain_delay = 0
				attack_buffer.append("a")
				chain_counter += 1
				chaingui.get_node("chaintext/counterGroup/counter").set_text(str(chain_counter))
				# secondary chain attack
				if (chain_next && !is_crouching):
					chain_animation = "chain"
					chain_collider.set_pos(Vector2((weapon_offset.x + sprite_offset.x + 4) * -direction, -sprite_offset.y + weapon_offset.y))
					add_child(chain_collider)
					chain_collided = false
					get_node("sound").stop_all()
					get_node("sound").set_volume_db(get_node("sound").play("chain"), 3)
				else:
					chain_animation = ""
				chain_next = !chain_next
				if (chain_counter > 1 && !chaingui.is_visible()):
					chaingui.show()
					chaingui.get_node("AnimationPlayer").play("appear")
				else:
					chaingui.get_node("AnimationPlayer").play("counter")
			else:
				current_chain_delay += 1
	
			position.y = accel
			
			check_blood(areaTiles)
	else:
		# check special attack
		new_animation = current_chain_special["id"]
		horizontal_motion = false
		ladderY = 0
		# make sure the target is still in the world before matching up coordinates
		if (target_enemy != null && target_enemy.get_parent() != null):
			position.y = target_enemy.get_global_pos().y - get_global_pos().y + target_enemy_offset.y
		if (animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()):
			is_chain_special = false
			remove_special_collider()
			if (target_enemy == null):
				reset_chain()
			target_enemy = null
			hit_enemy = false
		
	# check animations
	var animations = check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	animation_speed = animations["animationSpeed"]
	new_animation = animations["animation"]

	calculate_fall_height()
	
	move(position)
	play_animation(new_animation, animation_speed)
	
	if (is_hurt || on_ladder || current_chain_delay >= chain_delay || chain_counter > MAX_CHAIN):
		reset_chain()
		is_chain_special = false
	
	#clear attack buffer overflow
	while (attack_buffer.size() >= 10):
		attack_buffer.remove(0)

func reset_chain():
	attack_buffer.clear()
	chain_counter = 0
	chaingui.hide()
	current_chain_delay = 0
	chain_next = false
	chain_animation = ""
	remove_chain_collider()
	chain_collided = false

func remove_chain_collider():
	if (has_node(chain_collider.get_name())):
		remove_child(chain_collider)

func remove_special_collider():
	if (has_node(special_collider.get_name())):
		remove_child(special_collider)

func do_attack():
	.do_attack()
	if (!attack_reset_interrupt):
		reset_chain()
	attack_reset_interrupt = false

func _on_chain_collision(area):
	var collisions = chain_collider.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() != "damage" && i != chain_collider && i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder"):
			chain_collided = true
	if(area.get_name() != "damage" && area != chain_collider && area.get_name() != "oneway" && !area.get_name().match("slope*") && area.get_name() != "ladder"):
		chain_collided = true

func _on_special_collision(area):
	var collisions = special_collider.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() != "damage" && i != special_collider && i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder"):
			target_enemy = i
	if(area.get_name() != "damage" && area != special_collider && area.get_name() != "oneway" && !area.get_name().match("slope*") && area.get_name() != "ladder"):
		target_enemy = area
	if (target_enemy != null):
		target_enemy_offset = Vector2(get_global_pos().x - target_enemy.get_global_pos().x, get_global_pos().y - target_enemy.get_global_pos().y)

func _input(event):
	if (chain_counter > 1):
		if (event.is_action_pressed("ui_up") && event.is_pressed() && !event.is_echo()):
			direction_requested = "u"
		if (event.is_action_pressed("ui_down") && event.is_pressed() && !event.is_echo()):
			direction_requested = "d"
		if (((event.is_action_pressed("ui_right") && direction > 0) || (event.is_action_pressed("ui_left") && direction < 0)) && event.is_pressed() && !event.is_echo()):
			direction_requested = "f"

func _init():
	weapon = preload("res://scenes/weapons/sword.xml")