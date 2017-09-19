
extends "res://players/player.gd"

var attack_buffer = ""
var chaingui
var chain_counter = 0
var chain_delay = 25
var current_chain_delay = 0
var chain_next = false # whether or not to show the second chain attack animation
var chain_animation = ""
var chain_collider
var chain_collided = false
var attack_reset_interrupt = false
var direction_requested = ""
var chain_specials = [
	{"combo":"a a d", "id":"chop", "replace":"aad", "collider":preload("res://scenes/weapons/chop.tscn"), "collider_offset":Vector2(0, 0), "db":10, "hurt_delay":10},
	{"combo":"aad u", "id":"slice", "replace":"aadu", "collider":preload("res://scenes/weapons/slice.tscn"), "collider_offset":Vector2(0, -96), "db":10, "hurt_delay":8},
	{"combo":"a a u", "id":"skewer", "replace":"aau", "collider":preload("res://scenes/weapons/skewer.tscn"), "collider_offset":Vector2(0, -32), "db":10, "hurt_delay":8},
	{"combo":"aau d", "id":"stab", "replace":"aaud", "collider":preload("res://scenes/weapons/stab.tscn"), "collider_offset":Vector2(0, 80), "db":10, "hurt_delay":7},
	{"combo":"a a a", "id":"thrust", "replace":"aaa", "collider":preload("res://scenes/weapons/thrust.tscn"), "collider_offset":Vector2(0, -32), "db":10, "hurt_delay":10},
	{"combo":"aaa a", "id":"swift", "replace":"aaaa", "collider":preload("res://scenes/weapons/swift.tscn"), "collider_offset":Vector2(0, 0), "db":10, "hurt_delay":6},
	{"combo":"a a f", "id":"dualspin", "replace":"aaf", "collider":preload("res://scenes/weapons/dualspin.tscn"), "collider_offset":Vector2(0, 0), "db":10, "hurt_delay":8},
	{"combo":"aaa f", "id":"rush", "replace":"aaaf", "collider":preload("res://scenes/weapons/rush.tscn"), "collider_offset":Vector2(0, 0), "db":10, "hurt_delay":2},
	{"combo":"aaf d", "id":"void", "replace":"aafd", "collider":preload("res://scenes/weapons/void.tscn"), "collider_offset":Vector2(32, 0), "db":10, "hurt_delay":4}
	]
var demonic_void = preload("res://scenes/weapons/demonic.tscn")
var target_enemy
var is_chain_special = false
var current_chain_special
var special_collider
var target_enemy_offset
#delay after special attack finishes so that attacks afterwards hit enemies
#seamlessly
var special_delay = 10
const static_enemy = preload("res://scenes/common/damagables/Static.gd")
const nontarget = preload("res://scenes/common/NonTarget.gd")
const chain_target = preload("res://scenes/bergfortress/boss/ChainTarget.gd")
var jump_requested = false

const MAX_CHAIN = 100

func attack_buffer_size():
	return attack_buffer.split(" ").size()

# disable ladder detection for demonic ability
func check_ladder_up(a):
	if (is_demonic):
		return 0
	else:
		return .check_ladder_up(a)

func check_ladder_down(a, b, c, d, e, f):
	if (is_demonic):
		return {"ladderY": 0, "animationSpeed": 1}
	else:
		return .check_ladder_down(a, b, c, d, e, f)

func check_ladder_top(a, b, c):
	if (!is_demonic):
		.check_ladder_top(a, b, c)

func _ready():
	base_hp = 250
	base_mp = 80
	current_mp = base_mp
	current_hp = base_hp
	hp = base_hp
	mp = base_mp
	base_atk = 10
	base_def = 15
	base_mag = 12
	base_luck = 15

	set_stats()

	demonic_atk = 0.2
	demonic_def = 0.15
	demonic_hp = 0.2
	demonic_mp = 0.1
	demonic_mag = 0.15
	demonic_luck = 1
	
	exp_growth = preload("res://players/friederich/FriederichExpGrowth.gd")
	exp_growth_obj = exp_growth.new()
	exp_growth_obj.setup(level)
	
	chaingui = get_tree().get_root().get_node("world/gui/CanvasLayer/chain")

	weapon_offset.y -= 64

	chain_collider = weapon.instance()

	chain_collider.connect("area_enter", self, "_on_chain_collision")
	
	demonic_sprite = preload("res://players/friederich/demonic/demonic.tscn")
	demonic_sprite_obj = demonic_sprite.instance()
	
	default_sprite = get_node("NormalSpriteGroup")
	
	demonic_display.get_node("demonic/sprite/friederich").show()
	
	weapon_type = "sword"
	var available_spells = Globals.get("available_spells")
	if (available_spells != null && available_spells.size() > 0):
		magic_spells = available_spells
	else:
		var spells = Globals.get("magic_spells")
		for i in range(0, spells.size()):
			if (spells[i].id == "fire"):
				magic_spells.append(spells[i])
		Globals.set("available_spells", magic_spells)
	selected_spell = 0
	spell_icons.get_node(magic_spells[selected_spell]["id"]).show()
	update_fusion()

func jumping_allowed():
	return .jumping_allowed() || (is_demonic && !is_attacking && jump_requested)

func check_jump():
	.check_jump()
	if (jumpPressed):
		jump_requested = false

func falling_modifier(desiredY):
	var modifier = .falling_modifier(desiredY)
	if (is_demonic && desiredY > 0):
		var modifier = modifier * 0.1
		if (desiredY + modifier > 10 || is_attacking || is_charging || is_magic):
			return 0
		return modifier
	else:
		return modifier

func check_climb_platform_horizontal(space_state):
	var climb_vertically = .check_climb_platform_horizontal(space_state)
	if (is_demonic):
		hanging = false
		climb_platform = null
		climb_vertically = false
	return climb_vertically

func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	if (!is_chain_special || gameover):
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

func do_attack():
	.do_attack()
	weapon_collider.set_scale(Vector2(1, 1))
	if (is_crouching):
		weapon_collider.set_scale(Vector2(0.5, 0.75))
		weapon_collider.set_pos(Vector2(weapon_collider.get_pos().x - 42 * direction, weapon_collider.get_pos().y + 16))

func check_attacking():
	.check_attacking()
	if (chain_collided):
		chain_collided = false
		remove_chain_collider()
		hit_enemy = false
	
	if ((animation_player.get_current_animation().match("*chainattack") && animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()) || climbing_platform || hanging || on_ladder):
		remove_chain_collider()

func step_player(delta):
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
	var new_animation = current_animation
	var onSlope
	var relevantSlopeTile
	var abSlope
	var desiredY
	if (!gameover):
		# check underwater
		check_underwater(areaTiles)
	
		# check taking damage
		check_damage(areaTiles)
		
		var horizontal_motion = false
		var ladderY = 0
		
		# chain specials are "choreographed". So ignore all other 
		# collision detections while it is in progress.
		if (!is_chain_special):
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
					var offset = 2 * get_global_pos().x - charge_obj.get_global_pos().x
					charge_obj.set_global_pos(Vector2(offset, get_global_pos().y))
			var horizontal = step_horizontal(space_state)
			new_animation = horizontal["animation"]
			horizontal_motion = horizontal["motion"]
			onSlope = horizontal["slope"]
			var slopeX = horizontal["slopeX"]
			relevantSlopeTile = horizontal["slopeTile"]
			forwardY = get_global_pos().y + sprite_offset.y
			
			# disengage hanging if hurt
			check_hanging_damage()
			
			# check platform climbing after horizontal movement requested
			var climb_vertically = check_climb_platform_horizontal(space_state)
		
			step_horizontal_damage_throwback()
			
			# check vertical motion
			var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)
		
			relevantSlopeTile = vertical["slopeTile"]
			onSlope = vertical["slope"]
			abSlope = vertical["abSlope"]
			desiredY = vertical["desiredY"]
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
				if (direction_requested != "" && chain_counter > 1):
					attack_buffer = attack_buffer + direction_requested + " "
					direction_requested = ""
				
				# check attack buffer for chain special combos
				if (attack_buffer_size() > 1):
					var combos = attack_buffer
					for combo in chain_specials:
						var combopos = combos.rfind(combo["combo"])
						if(combopos == 0 || (combopos > 0 && combos[combopos-1] == " ")):
							# only allow void attack if void spell is available
							if (combo["id"] != "void" || (combo["id"] == "void" && find_spell("void") != null)):
								hit_enemy = false
								remove_weapon_collider()
								remove_chain_collider()
								weapon_collided = false
								chain_collided = false
								is_attacking = false
								attack_requested = false
								chain_next = false
								# already counted the chain since attack button is required to trigger it
								if (combo["id"] != "swift" && combo["id"] != "thrust"):
									chain_counter += 1
								chaingui.get_node("chaintext/counterGroup/counter").set_text(str(chain_counter))
								chaingui.get_node("AnimationPlayer").play("counter")
								# merge combo in attack buffer
								var parta = combos.substr(0, combopos)
								var partb = combos.substr(combopos+combo["combo"].length(), combos.length())
								attack_buffer = parta + combo["replace"] + partb
								# setup special attack
								is_chain_special = true
								current_chain_special = combo
								current_chain_delay = 0
								if (!Globals.get("chain")[combo["id"]]):
									Globals.get("chain")[combo["id"]] = true
									chaingui.get_node("newattack").show()
									chaingui.get_node("AnimationPlayer").play("newattack")
								remove_special_collider()
								special_collider = current_chain_special["collider"].instance()
								add_to_blacklist(special_collider)
								if (magic_spells[selected_spell].has("type")):
									special_collider.set("type", magic_spells[selected_spell]["type"])
								var special_offset = 0
								if (current_chain_special["id"] == "void"):
									if (is_demonic):
										var sprite = demonic_void.instance()
										special_collider.remove_child(special_collider.get_node("attack"))
										special_collider.add_child(sprite)
									special_offset = special_collider.get_node("weapon").get_shape().get_extents()
									special_collider.set_pos(Vector2(((special_offset.x + sprite_offset.x + 4) + current_chain_special["collider_offset"].x) * direction, current_chain_special["collider_offset"].y))
									if (target_enemy != null && target_enemy.get_ref()):
										special_collider.set_pos(Vector2(target_enemy.get_ref().get_global_pos().x - get_global_pos().x + (target_enemy.get_ref().get_node("CollisionShape2D").get_shape().get_extents().x + special_offset.x) * direction))
									special_collider.get_node("attack").set_scale(Vector2(direction*-1, 1))
									special_collider.get_node("AnimationPlayer").play("attack")
									special_collider.connect("area_enter", self, "_on_special_collision")
									
									var spell = magic_spells[selected_spell]
									var auracolor = spell["auracolor"]
									var weaponcolor1 = spell["weaponcolor1"]
									var weaponcolor2 = spell["weaponcolor2"]
									special_collider.get_node("attack/aura").set_modulate(auracolor)
									special_collider.get_node("attack/sword").get_material().set_shader_param("modulate", weaponcolor1)
									special_collider.get_node("attack/sword").get_material().set_shader_param("aura_color", weaponcolor2)
								else:
									if (current_chain_special["id"] != "dualspin"):
										special_offset = special_collider.get_node("weapon").get_shape().get_extents()
										special_collider.set_pos(Vector2(((special_offset.x + sprite_offset.x + 4) + current_chain_special["collider_offset"].x) * direction, current_chain_special["collider_offset"].y))
										special_collider.connect("area_enter", self, "_on_special_collision")
									else:
										special_collider.set_pos(Vector2(0, -16))
										special_collider.get_node("Dualspin Part").connect("area_enter", self, "_on_special_collision")
										special_collider.get_node("Dualspin Part 2").connect("area_enter", self, "_on_special_collision")
									add_child(special_collider)
								new_animation = current_chain_special["id"]
								get_node("sound").set_volume_db(get_node("sound").play(current_chain_special["id"]), current_chain_special["db"])
								if (current_chain_special["id"] == "slice"):
									accel = -10
								if (current_chain_special["id"] == "skewer"):
									accel = -16
								if (current_chain_special["id"] == "stab"):
									accel = -5
				
				# if attack connects with an enemy, count it as an attack in the attack buffer
				if (hit_enemy):
					hit_enemy = false
					attack_reset_interrupt = true
					current_chain_delay = 0
					attack_buffer = attack_buffer + "a "
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
						chaingui.get_node("chaintext").show()
						chaingui.get_node("AnimationPlayer").play("appear")
					else:
						chaingui.get_node("AnimationPlayer").play("counter")
				else:
					current_chain_delay += 1
		
				position.y = accel
				check_blood(areaTiles)
				
				check_magic()
			else:
				step_shield()
			check_demonic()
		else:
			request_spell_change = 0
			# check special attack
			new_animation = current_chain_special["id"]
			horizontal_motion = false
			ladderY = 0
			var target_exists = false
			var newpos = position.y
			var animation_pos = animation_player.get_current_animation_pos()
			var animation_length = animation_player.get_current_animation_length()
			var animation_end = animation_length - special_delay * delta
			var is_valid_target = false
			# make sure the target is still in the world before matching up coordinates
			if (target_enemy != null && target_enemy.get_ref() && target_enemy.get_ref().get_parent() != null):
				target_exists = true
				newpos = target_enemy.get_ref().get_global_pos().y - get_global_pos().y + target_enemy_offset.y
				is_valid_target = target_enemy.get_ref().get_name() == "damagable" && !(target_enemy.get_ref().get_parent() extends chain_target)
			# do special attack specific actions
			# unfortunately, some attacks require collision checks anyways especially on slopes, so we do them
			if (current_chain_special["id"] == "thrust"):
				if (target_exists && hit_enemy && is_valid_target):
					target_enemy.get_ref().get_parent().set_global_pos(Vector2(target_enemy.get_ref().get_global_pos().x + direction * 5, target_enemy.get_ref().get_global_pos().y))
				accel += falling_modifier(accel)
				var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, false, oneWayTile, null)
				newpos = accel
			elif (current_chain_special["id"] == "slice"):
				newpos = min(newpos + 1, 0)
				if (target_exists && hit_enemy && is_valid_target):
					target_enemy.get_ref().get_parent().set("floortile_check_requested", false)
					target_enemy.get_ref().get_parent().set_global_pos(Vector2(target_enemy.get_ref().get_global_pos().x, target_enemy.get_ref().get_global_pos().y + target_enemy_offset.y))
			elif (current_chain_special["id"] == "skewer"):
				newpos = min(position.y + 1, 0)
				if (target_exists && hit_enemy && is_valid_target):
					target_enemy.get_ref().get_parent().set("floortile_check_requested", false)
					target_enemy.get_ref().get_parent().set_global_pos(Vector2(target_enemy.get_ref().get_global_pos().x, get_global_pos().y - TILE_SIZE))
			elif (current_chain_special["id"] == "stab" || current_chain_special["id"] == "chop"):
				accel += falling_modifier(accel)
				var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, false, oneWayTile, null)
				newpos = accel
			# prevent enemy dropping through the floor on certain attacks
			elif (current_chain_special["id"] == "dualspin"):
				if (target_exists && hit_enemy && is_valid_target):
					target_enemy.get_ref().get_parent().set("floortile_check_requested", true)
				accel += falling_modifier(accel)
				var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, false, oneWayTile, null)
				newpos = accel
			elif (current_chain_special["id"] == "swift"):
				if (target_exists && hit_enemy && is_valid_target):
					target_enemy.get_ref().get_parent().set("floortile_check_requested", true)
				accel += falling_modifier(accel)
				var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, false, oneWayTile, null)
				newpos = accel
			elif (current_chain_special["id"] == "rush"):
				runspeed = 15
				var horizontal = step_horizontal(space_state)
				onSlope = horizontal["slope"]
				relevantSlopeTile = horizontal["slopeTile"]
				accel += falling_modifier(accel)
				var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)
				newpos = accel
			elif (current_chain_special["id"] == "void"):
				if (animation_pos >= 0.3 && animation_end > animation_pos && !has_node(special_collider.get_name())):
					add_child(special_collider)
				accel += falling_modifier(accel)
				var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, false, oneWayTile, null)
				newpos = accel
			position.y = newpos
			if (hit_enemy):
				hit_enemy = false
			# remove collider by [hurt delay] before end of the special animation
			# this prevents stray attacks from not being counted for special attacks
			# since they only count if they hit enemies, and enemies have hurt delays
			if (animation_end <= animation_pos):
				if (animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()):
					is_chain_special = false
					runspeed = RUN_SPEED
					remove_special_collider()
					if (target_enemy == null):
						reset_chain()
					target_enemy = null
					hit_enemy = false
					attack_requested = false
				else:
					remove_special_collider()
					reset_target_delay()
		
		regenerate_mp()
		
		# check animations
		var animations = check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
		animation_speed = animations["animationSpeed"]
		new_animation = animations["animation"]
	
		calculate_fall_height()
		
		move(position)

		step_camera()
		if (is_hurt || on_ladder || current_chain_delay >= chain_delay || chain_counter > MAX_CHAIN):
			reset_chain()
			is_chain_special = false
			runspeed = RUN_SPEED
	else:
		#if (!get_tree().is_paused() && get_pause_mode() == 2):
			#get_tree().set_pause(true)
		new_animation = "gameover"
		animation_speed = 1
		if (!animation_player.is_playing()):
			get_tree().get_root().get_node("world").show_gameover()
			get_tree().set_pause(true)
	
	play_animation(new_animation, animation_speed)
	
	#clear attack buffer overflow
	while (attack_buffer_size() >= 10):
		var new_buffer = attack_buffer.split(" ")
		attack_buffer = attack_buffer.substr(new_buffer[0].length() + 1, attack_buffer.length() - new_buffer[0].length() - 1)

func check_damage(damageTiles):
	if (current_chain_special == null || (current_chain_special != null && current_chain_special["id"] != "rush" && current_chain_special["id"] != "void")):
		.check_damage(damageTiles)

func reset_target_delay():
	if (target_enemy != null && target_enemy.get_ref() && target_enemy.get_ref().get_parent() != null):
		target_enemy.get_ref().get_parent().set("hurt_delay", 10)

func reset_chain():
	attack_buffer = ""
	chain_counter = 0
	current_chain_special = null
	chaingui.get_node("chaintext").hide()
	chaingui.get_node("newattack").hide()
	chaingui.hide()
	current_chain_delay = 0
	chain_next = false
	chain_animation = ""
	remove_weapon_collider()
	chain_collided = false
	remove_special_collider()

func remove_chain_collider():
	if (has_node(chain_collider.get_name())):
		remove_child(chain_collider)

func remove_special_collider():
	if (special_collider != null && has_node(special_collider.get_name())):
		remove_from_blacklist(special_collider)
		remove_child(special_collider)

func _on_chain_collision(area):
	var collisions = chain_collider.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() != "damage" && i != chain_collider && i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder"):
			chain_collided = true
	if(area.get_name() != "damage" && area != chain_collider && area.get_name() != "oneway" && !area.get_name().match("slope*") && area.get_name() != "ladder"):
		chain_collided = true

func _on_special_collision(area):
	reset_target_delay()
	var collisions = []
	if (current_chain_special["id"] == "dualspin"):
		pass
	else:
		collisions = special_collider.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() != "damage" && i != special_collider && i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder"):
			target_enemy = weakref(i)
			if (i.get_parent() != null && (i.get_parent() extends static_enemy || i.get_parent() extends nontarget)):
				target_enemy = null
	if(area.get_name() != "damage" && area != special_collider && area.get_name() != "oneway" && !area.get_name().match("slope*") && area.get_name() != "ladder"):
		target_enemy = weakref(area)
		if (area.get_parent() != null && (area.get_parent() extends static_enemy || area.get_parent() extends nontarget)):
			target_enemy = null
	if (target_enemy != null && target_enemy.get_ref() && target_enemy.get_ref().get_parent() != null):
		target_enemy_offset = Vector2(get_global_pos().x - target_enemy.get_ref().get_global_pos().x, get_global_pos().y - target_enemy.get_ref().get_global_pos().y)
		target_enemy.get_ref().get_parent().set("hurt_delay", current_chain_special["hurt_delay"])

func update_fusion():
	.update_fusion()
	var current_spell = magic_spells[selected_spell]
	var auracolor = current_spell["auracolor"]
	var weaponcolor1 = current_spell["weaponcolor1"]
	var weaponcolor2 = current_spell["weaponcolor2"]
	if (current_spell.has("type")):
		chain_collider.set("type", current_spell["type"])
	
	update_attack_color("chainattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("achainattack", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("chop", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("thrust", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("swift", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("slice", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("skewer", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("stab", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("dualspin", auracolor, weaponcolor1, weaponcolor2)
	update_attack_color("rush", auracolor, weaponcolor1, weaponcolor2)

func input_left():
	return .input_left() || (is_chain_special && current_chain_special["id"] == "rush" && direction < 0)

func input_right():
	return .input_right() || (is_chain_special && current_chain_special["id"] == "rush" && direction > 0)

func _input(event):
	if (!is_transforming):
		if (chain_counter > 1):
			if (event.is_action_pressed("ui_up") && event.is_pressed() && !event.is_echo()):
				direction_requested = "u"
			if (event.is_action_pressed("ui_down") && event.is_pressed() && !event.is_echo()):
				direction_requested = "d"
			if (((event.is_action_pressed("ui_right") && direction > 0) || (event.is_action_pressed("ui_left") && direction < 0)) && event.is_pressed() && !event.is_echo()):
				direction_requested = "f"
		if (event.is_action_pressed("ui_jump") && event.is_pressed() && !event.is_echo()):
			jump_requested = true

func _init():
	weapon = preload("res://scenes/weapons/sword.tscn")