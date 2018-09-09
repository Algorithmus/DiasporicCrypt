
extends "res://scenes/common/BaseCharacter.gd"

# Base class for enemy interaction. Takes an ai class for input while
# applying regular collisions.
# Also contains basic enemy behaviors such as status changes and consumable
# enemies.

var is_dying = false
var player
var hurt_delay = 10
var current_delay = 0
var current_walk_delay = 0
var walk_delay = 60
var frozen = false
const FREEZE_DELAY = 360
var freeze_counter = 0
var freezeblock = preload("res://scenes/common/iceblock.tscn")
var freezeblock_obj
var stun_obj
var stun_delay = 300
var stun_current_delay = 0
var is_stunned = false
var gustx = 0 # add extra velocity from gust attack
var ai = preload("res://scenes/common/damagables/ai/patrol.gd")
var ai_obj
var magic_only = false # only hurt by magic attacks
var ignore_collision = false # turn this on for flying enemies
var floortile_check_requested = true
var is_rush = false
var player_loaded = false
var adjusted_freeze_delay = FREEZE_DELAY

# variables for consumable enemies
var is_consumable = false
var consumable = false
var base_consume_value = 10
var blood = preload("res://scenes/common/blood.tscn")
var blood_particles = []
var current_consume_value
var color_increments = Color()
var consumable_instance = preload("res://scenes/common/damagables/consumable.tscn")
var consumable_offset
var consumable_sprite_offset = Vector2()
var consumable_size = Vector2(1, 1)
var consume_factor = 1 # scale amount of blood consumed
var die_animation_complete = false

var is_attacking = false
var attack_delay = 100
var current_attack_delay = 0
var follow_player = false # sprite faces player regardless of what direction the enemy is moving in

var sunbeam_immunity = true
var sunbeam_strength = 0.5

var gold = 100
var custom_drop # drop another item instead of gold

var expclass = preload("res://scenes/items/exporb/exporb.tscn")
var goldclass = preload("res://scenes/items/gold/gold.tscn")

func get_player_direction():
	if (get_global_position().x > player.get_node("player").get_global_position().x):
		return -1
	return 1

func complete_die_animation():
	die_animation_complete = true

func can_attack():
	return false

func check_dying():
	if (is_consumable):
		bleed()
	if (current_hp <= 0):
		is_stunned = false
		if (stun_obj != null):
			stun_obj.hide()
		is_dying = true
		is_hurt = false
		if (has_node(damage_rect.get_name())):
			remove_child(damage_rect)

func request_stun():
	if (stun_obj != null):
		is_stunned = true
		stun_obj.show()
		stun_obj.get_node("AnimationPlayer").play("rotate")

func check_damage():
	if (!is_dying && !frozen && !consumable):
		if(current_delay == 0):
			var damageTiles = damage_rect.get_overlapping_areas()
			for i in damageTiles:
				var collider
				var damage = 0
				if (i.has_node("weapon") && !magic_only):
					var type = i.get("type")
					collider = i.get_node("weapon")
					player.get_node("player").set("hit_enemy", true)
					var special_factor = 1
					if (i.get("atk")):
						special_factor = i.get("atk")
					var atk_adjusted = get_atk_adjusted_damage(player.get_node("player").get("atk")*special_factor, type)
					var critical = player.get_node("player").get_critical_bonus(atk_adjusted)
					damage = max(get_def_adjusted_damage(atk_adjusted + critical), 0)
				if (i.has_node("magic") || (!sunbeam_immunity && i.get_name() == "sunbeam")):
					var type = i.get_parent().get("type")
					# freeze in collision block if hit with an ice attack
					# freeze blocks are essentially one way platforms
					# it's to allow any overlapping enemies to walk past
					# without messing up collision detection
					if (i.get_parent() != null && type == "ice"):
						frozen = true
						var bonus = ProjectSettings.get("bonus_effects")
						freezeblock_obj = freezeblock.instance()
						var freezescale = sprite_offset.y * 2 / TILE_SIZE
						var freezescalex = sprite_offset.x * 2.0 / TILE_SIZE
						freezeblock_obj.get_node("sprite").set_scale(Vector2(freezescalex, freezescale))
						freezeblock_obj.get_node("sprite").set_position(Vector2(0, sprite_offset.y - TILE_SIZE / 2))
						freezeblock_obj.get_node("oneway").set_scale(Vector2(freezescalex, 1))
						var shiny = freezeblock_obj.get_node("shiny")
						if (bonus.ice):
							adjusted_freeze_delay = FREEZE_DELAY * 2
							shiny.show()
							shiny.amount = 4 * freezescalex * freezescale
							shiny.process_material.emission_box_extents = Vector3(16 * freezescalex, 16 * freezescale, 0)
							shiny.position.y = sprite_offset.y - TILE_SIZE / 2
						else:
							adjusted_freeze_delay = FREEZE_DELAY
							shiny.hide()
						if (sprite_offset.y > TILE_SIZE / 2):
							freezeblock_obj.get_node("block").set_position(Vector2(0, sprite_offset.y * 2 - TILE_SIZE))
							freezeblock_obj.get_node("block").set_scale(Vector2(sprite_offset.x * 2.0 / TILE_SIZE, 1))
						else:
							freezeblock_obj.remove_child(freezeblock_obj.get_node("block"))
						freezeblock_obj.set_position(Vector2(0, -sprite_offset.y + TILE_SIZE / 2))
						add_child(freezeblock_obj)
						if (has_node(damage_rect.get_name())):
							remove_child(damage_rect)
					collider = i.get_node("magic")
					damage = max(get_def_adjusted_damage(get_atk_adjusted_damage(calculate_atk_value(i), type)), 0)
					if (collider == null):
						collider = i.get_node("CollisionShape2D")
						damage = max(get_def_adjusted_damage(hp * sunbeam_strength), 0)
					# some magic spells will disappear if hit too frequently
					var magic_hp = i.get_parent().get("hp")
					if (magic_hp != null):
						i.get_parent().set("hp", magic_hp - 1)
				if (collider != null):
					var hp_obj = hpclass.instance()
					hud.add_child(hp_obj)
					var collider_offset = collider.get_shape().get_extents()
					var hitpos = hp_obj.calculate_hitpos(i.get_global_position(), Vector2(collider_offset.x * i.get_scale().x, collider_offset.y * i.get_scale().y), get_position(), sprite_offset)
					if (damage > 0):
						current_hp -= damage
						is_hurt = true
						check_dying()
						current_delay += 1
						current_walk_delay += 1
					# TODO - calculate damage helper method
					hp_obj.display_damage(hitpos, damage)

func calculate_atk_value(obj):
	if (obj.get_parent().get("atk") != null):
		return obj.get_parent().get("atk")
	elif (obj.get_parent().get_parent() != null && obj.get_parent().get_parent().get("atk") != null):
		return obj.get_parent().get_parent().get("atk")
	else:
		return player.get_node("player").get("mag")

func horizontal_input_permitted():
	return .horizontal_input_permitted() && !is_stunned && !is_dying && !consumable && !frozen

func closestXTile(direction, desiredX, space_state):
	# add gust speed to horizontal motion
	# unfortunately, that also can change the direction of the
	# desired motion
	var netX = desiredX + gustx
	var value = .closestXTile(sign(netX), netX, space_state)
	gustx = 0
	return value

func closestXTile_area_check(desired_direction, desiredX, space_state):
	var frontTile = space_state.intersect_ray(Vector2(get_global_position().x + desired_direction * sprite_offset.x + desiredX, get_global_position().y - sprite_offset.y), Vector2(get_global_position().x + desired_direction * sprite_offset.x + desiredX, get_global_position().y + sprite_offset.y - 1), [], 524291)
	if (frontTile != null && frontTile.has("collider") && !("slope" in frontTile["collider"].get_name()) && !"(player,damage,water,lava,snow,item,damagable,consumable,sensor,magic,switch,breakable,sunbeam,ladder,fake,Thrust)".match("*" + frontTile["collider"].get_name() + "*") && !frontTile["collider"].has_node("magic") && !("target" in frontTile["collider"].get_parent().get_name())):
		return 0
	return desiredX

# ignore gravity in certain special attacks
func check_special_attack():
	var damageTiles = damage_rect.get_overlapping_areas()
	for i in damageTiles:
		if (i.has_node("weapon") && !floortile_check_requested):
			floortile_check_requested = true
			return false
	return true

func step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile):
	if (!frozen && check_special_attack()):
		return .step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)
	else:
		accel = 0
		return {"desiredY": 0, "slope": false, "slopeTile": null, "abSlope": null, "animationSpeed": animation_speed, "ladderY": 0}

func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	new_animation = do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY)
	set_animation_direction(new_animation)
	return {"animationSpeed": animation_speed, "animation": new_animation}

func set_animation_direction(new_animation):
	var sprite_direction = direction
	if (follow_player):
		sprite_direction = 1
		if (player.get_node("player").get_global_position().x < get_global_position().x):
			sprite_direction = -1
	if (!frozen):
		get_node(new_animation).set_scale(Vector2(sprite_direction, 1))

func do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY):
	new_animation = "walk"
	if (is_dying):
		new_animation = "die"
	if (is_hurt):
		new_animation = "hurt"
	if (is_consumable && consumable):
		new_animation = "die"
		if (die_animation_complete):
			new_animation = "consumable"
	return new_animation

func bleed():
	var blood_obj = blood.instance()
	add_child(blood_obj)
	blood_obj.set_position(Vector2(randf()*consumable_offset.x + consumable_offset.x/2 - 16, sprite_offset.y - randf()*consumable_offset.y*2))
	blood_obj.get_node("particles").set_emitting(true)
	blood_obj.get_node("sound/blood").play()
	blood_particles.append(blood_obj)

	if (consumable):
		current_consume_value -= 1
		var color = get_node("die").get_modulate()
		get_node("die").set_modulate(Color(color.r + color_increments.r, color.g + color_increments.g, color.b + color_increments.b))
		if (current_consume_value <= 0):
			get_node("die").hide()

func die():
	var drop
	var bonus = ProjectSettings.get("bonus_effects")
	var goldrate = 1
	var eprate = 1
	if (bonus.gold):
		goldrate = 2
	if (bonus.exp):
		eprate = 2
	if (custom_drop != null):
		var custom = custom_drop.instance()
		drop = custom
	else:
		var gold_obj = goldclass.instance()
		gold_obj.set("value", gold * goldrate)
		drop = gold_obj
	var exporb = expclass.instance()
	exporb.set_value(ep * eprate)
	drop.set_global_position(Vector2(get_global_position().x - sprite_offset.x, get_global_position().y + sprite_offset.y - TILE_SIZE/2))
	exporb.set_global_position(Vector2(get_global_position().x + sprite_offset.x, get_global_position().y + sprite_offset.y - TILE_SIZE/2))
	get_parent().add_child(drop)
	get_parent().add_child(exporb)
	if (is_consumable):
		# turn into consumable object instead of disappearing
		consumable = true
		follow_player = false
		is_dying = false
		if (has_node(damage_rect.get_name())):
			remove_from_blacklist(damage_rect)
			remove_child(damage_rect)
		damage_rect = consumable_instance.instance()
		damage_rect.set_scale(consumable_size)
		consumable_offset = damage_rect.get_node("CollisionShape2D").get_shape().get_extents()
		damage_rect.set_position(Vector2(consumable_sprite_offset.x * direction, sprite_offset.y - consumable_offset.y + consumable_sprite_offset.y))
		add_to_blacklist(damage_rect)
		add_child(damage_rect)
	else:
		player.get_node("player").remove_from_blacklist(get_node("damagable"))
		queue_free()

func input_left():
	return ai_obj.get("input") == "left"

func input_right():
	return ai_obj.get("input") == "right"

func input_up():
	return ai_obj.get("vertical_input") == "up"

func input_down():
	return ai_obj.get("vertical_input") == "down"

func input_jump():
	return ai_obj.get("jump_input") == "jump"

func update_status():
	if (frozen || is_stunned):
		animation_player.stop()
	
	if (is_hurt && !animation_player.is_playing()):
		is_hurt = false
	
	if (is_dying && !animation_player.is_playing()):
		die()

func check_frozen():
	if (frozen):
		freeze_counter += 1
		# flash to warn player that frozen state is almost over
		if (fmod(freeze_counter, 4) == 0 && float(freeze_counter)/adjusted_freeze_delay > 0.75):
			freezeblock_obj.modulate.a = 0
		else:
			freezeblock_obj.modulate.a = 1
		if (freeze_counter >= adjusted_freeze_delay):
			frozen = false
			freeze_counter = 0
			if (has_node(freezeblock_obj.get_name())):
				remove_child(freezeblock_obj)
			freezeblock_obj.queue_free()
			freezeblock_obj = null
			add_child(damage_rect)
			animation_player.play(current_animation)

func check_stunned():
	if (is_stunned):
		stun_current_delay += 1
		# flash to warn stun is almost over
		if (fmod(stun_current_delay, 4) == 0 && float(stun_current_delay)/stun_delay > 0.75):
			stun_obj.modulate.a = 0
		else:
			stun_obj.modulate.a = 1
		if (stun_current_delay >= stun_delay):
			is_stunned = false
			stun_current_delay = 0
			stun_obj.hide()
			stun_obj.get_node("AnimationPlayer").stop()
			animation_player.play(current_animation)

func step_player(delta):
	"""
	if (!player_loaded):
		if (player.has_node("player/damage")):
			area2d_blacklist.append(player.get_node("player/damage"))
			player_loaded = true
	"""
	# ignore expensive calculations on flying enemies
	if (ignore_collision):
		on_ladder = true
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	var animation_speed = 1

	ai_obj.step(space_state)

	# position at character's feet
	var forwardY = get_global_position().y + sprite_offset.y
	var leftX = get_global_position().x - sprite_offset.x
	var rightX = get_global_position().x + sprite_offset.x

	var blacklist = merge([self, player.get_node("player")], area2d_blacklist)

	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(leftX, forwardY-1), Vector2(leftX, forwardY+31), blacklist, 524288)
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(rightX, forwardY-1), Vector2(rightX, forwardY+31), blacklist, 524288)

	# check regular blocks
	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()

	# check moving platforms before everything else
	var oneWayTile = getOneWayTile(space_state, max(accel, TILE_SIZE-1))
	
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
	forwardY = get_global_position().y + sprite_offset.y

	# check vertical motion
	var vertical = step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)

	relevantSlopeTile = vertical["slopeTile"]
	onSlope = vertical["slope"]
	var abSlope = vertical["abSlope"]
	var desiredY = vertical["desiredY"]
	animation_speed = vertical["animationSpeed"]
	var ladderY = vertical["ladderY"]

	# final falling status check for all kinds of collisions
	check_falling(normalTileCheck, relevantSlopeTile, onSlope, abSlope, null, oneWayTile)

	# don't fall while standing on moving platforms moving up
	check_on_moving_platform(desiredY)

	pos.y = accel

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

	_collider = move_and_collide(pos)
	play_animation(new_animation, animation_speed)
	
	update_status()
	
	cleanup_bloodparticles()

func cleanup_bloodparticles():
	# clean up blood particles
	for i in blood_particles:
		if(!i.get_node("particles").is_emitting()):
			if (has_node(i.get_name())):
				remove_child(i)
			blood_particles.erase(i)
	if (blood_particles.empty() && current_consume_value <= 0):
		ProjectSettings.set("blood_count", ProjectSettings.get("blood_count") + 1)
		var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
		if (level.type == "bonus" && ProjectSettings.get("blood_count") >= level.mincounter && !ProjectSettings.get("current_quest_complete")):
			ProjectSettings.set("current_quest_complete", true)
			level.complete = true
			ProjectSettings.get("levels")[ProjectSettings.get("current_level")] = level
			var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
			level_display.get_node("title/newlevel").hide()
			level_display.get_node("title").set_text("KEY_COMPLETE")
			level_display.get_node("AnimationPlayer").play("quest")
		player.get_node("player").remove_from_blacklist(get_node("damagable"))
		queue_free()

func _ready():
	runspeed = 3
	hp = 10
	atk = 1
	def = 0
	ep = 50
	current_hp = hp
	damage_rect = get_node("damagable")
	sprite_offset = damage_rect.get_node("CollisionShape2D").get_shape().get_extents()
	animation_player = get_node("AnimationPlayer")
	player = get_tree().get_root().get_node("world/playercontainer")
	stun_obj = get_node("Stun")
	if (stun_obj != null):
		stun_obj.hide()
	area2d_blacklist = [self, damage_rect]
	ai_obj = ai.new()
	ai_obj.set("target", self)
	has_kinematic_collision = false
	
	current_consume_value = base_consume_value * (randf() * 0.5 - 0.25) + base_consume_value
	var color = get_node("die").get_modulate()
	color_increments = Color((1 - color.r)/current_consume_value, -color.g/current_consume_value, -color.b/current_consume_value)
	consumable_offset = sprite_offset
	set_physics_process(false)
	player.get_node("player").add_to_blacklist(get_node("damagable"))

func enter_screen():
	set_physics_process(true)

func exit_screen():
	set_physics_process(false)
