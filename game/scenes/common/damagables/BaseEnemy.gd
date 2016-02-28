
extends "res://scenes/common/BaseCharacter.gd"

# Base class for enemy interaction. Takes an ai class for input while
# applying regular collisions.
# Also contains basic enemy behaviors such as status changes and consumable
# enemies.

var is_dying = false
var player
var hpclass = preload("res://gui/hud/hp.scn")
var hud
var hp = 10
var hurt_delay = 10
var current_delay = 0
var current_walk_delay = 0
var walk_delay = 60
var frozen = false
const FREEZE_DELAY = 300
var freeze_counter = 0
var freezeblock = preload("res://scenes/common/iceblock.scn")
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

# variables for consumable enemies
var is_consumable = false
var consumable = false
var base_consume_value = 10
var blood = preload("res://scenes/common/blood.xml")
var blood_particles = []
var current_consume_value
var color_increments = Color()
var consumable_instance = preload("res://scenes/common/damagables/consumable.xml")
var consumable_offset
var consume_factor = 1 # scale amount of blood consumed

var is_attacking = false
var attack_delay = 100
var current_attack_delay = 0
var follow_player = false # sprite faces player regardless of what direction the enemy is moving in

func can_attack():
	return false

func check_dying():
	if (is_consumable):
		bleed()
	if (hp <= 0):
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
				if (i.has_node("weapon") && !magic_only):
					collider = i.get_node("weapon")
					player.get_node("player").set("hit_enemy", true)
				if (i.has_node("magic")):
					# freeze in collision block if hit with an ice attack
					# freeze blocks are essentially one way platforms
					# it's to allow any overlapping enemies to walk past
					# without messing up collision detection
					if (i.get_parent() != null && i.get_parent().get_name() == "Ice"):
						frozen = true
						freezeblock_obj = freezeblock.instance()
						var freezescale = sprite_offset.y * 2 / TILE_SIZE
						freezeblock_obj.get_node("block").set_scale(Vector2(sprite_offset.x * 2.0 / TILE_SIZE, freezescale))
						freezeblock_obj.get_node("block").set_pos(Vector2(0, sprite_offset.y - TILE_SIZE / 2))
						freezeblock_obj.set_pos(Vector2(0, -sprite_offset.y + TILE_SIZE / 2))
						add_child(freezeblock_obj)
						if (has_node(damage_rect.get_name())):
							remove_child(damage_rect)
					collider = i.get_node("magic")
					var hp = i.get_parent().get("hp")
					if (hp != null):
						i.get_parent().set("hp", hp - 1)
				if (collider != null):
					var hp_obj = hpclass.instance()
					hud.add_child(hp_obj)
					var hitpos = hp_obj.calculate_hitpos(i.get_global_pos(), collider.get_shape().get_extents(), get_pos(), sprite_offset)
					hp -= 1
					is_hurt = true
					check_dying()
					# TODO - calculate damage helper method
					hp_obj.display_damage(hitpos, 1)
					current_delay += 1
					current_walk_delay += 1

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
	var frontTile = space_state.intersect_ray(Vector2(get_global_pos().x + desired_direction * sprite_offset.x + desiredX, get_global_pos().y - sprite_offset.y), Vector2(get_global_pos().x + desired_direction * sprite_offset.x + desiredX, get_global_pos().y + sprite_offset.y - 1))
	if (frontTile != null && frontTile.has("collider") && frontTile["collider"].get_name() != "player"):
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
		if (player.get_node("player").get_global_pos().x < get_global_pos().x):
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
	return new_animation

func bleed():
	var blood_obj = blood.instance()
	add_child(blood_obj)
	blood_obj.set_pos(Vector2(randf()*consumable_offset.x + consumable_offset.x/2 - 16, sprite_offset.y - randf()*consumable_offset.y*2))
	blood_obj.get_node("particles").set_emitting(true)
	blood_obj.get_node("sound").play("blood")
	blood_particles.append(blood_obj)

	if (consumable):
		current_consume_value -= 1
		var color = get_node("die").get_modulate()
		get_node("die").set_modulate(Color(color.r + color_increments.r, color.g + color_increments.g, color.b + color_increments.b))
		if (current_consume_value <= 0):
			get_node("die").hide()

func die():
	if (is_consumable):
		# turn into consumable object instead of disappearing
		consumable = true
		is_dying = false
		if (has_node(damage_rect.get_name())):
			remove_child(damage_rect)
		damage_rect = consumable_instance.instance()
		consumable_offset = damage_rect.get_node("CollisionShape2D").get_shape().get_extents()
		damage_rect.set_pos(Vector2(0, sprite_offset.y - consumable_offset.y))
		add_child(damage_rect)
	else:
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
		if (fmod(freeze_counter, 4) == 0 && float(freeze_counter)/FREEZE_DELAY > 0.75):
			freezeblock_obj.set_opacity(0)
		else:
			freezeblock_obj.set_opacity(1)
		if (freeze_counter >= FREEZE_DELAY):
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
			stun_obj.set_opacity(0)
		else:
			stun_obj.set_opacity(1)
		if (stun_current_delay >= stun_delay):
			is_stunned = false
			stun_current_delay = 0
			stun_obj.hide()
			stun_obj.get_node("AnimationPlayer").stop()
			animation_player.play(current_animation)

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

func cleanup_bloodparticles():
	# clean up blood particles
	for i in blood_particles:
		if(!i.get_node("particles").is_emitting()):
			if (has_node(i.get_name())):
				remove_child(i)
			blood_particles.erase(i)
	if (blood_particles.empty() && current_consume_value <= 0):
		queue_free()

func _ready():
	runspeed = 3
	damage_rect = get_node("damagable")
	sprite_offset = damage_rect.get_node("CollisionShape2D").get_shape().get_extents()
	animation_player = get_node("AnimationPlayer")
	player = get_tree().get_root().get_node("world/playercontainer")
	hud = get_tree().get_root().get_node("world/gui/hpcontainer")
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