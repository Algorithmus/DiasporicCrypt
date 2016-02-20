
extends "res://scenes/common/BaseCharacter.gd"

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
var gustx = 0
var ai_input = "right"

func check_dying():
	if (hp <= 0):
		is_stunned = false
		if (stun_obj != null):
			stun_obj.hide()
		is_dying = true
		is_hurt = false
		if (has_node("damagable")):
			remove_child(get_node("damagable"))

func request_stun():
	if (stun_obj != null):
		is_stunned = true
		stun_obj.show()
		stun_obj.get_node("AnimationPlayer").play("rotate")

func check_damage():
	if (!is_dying && !frozen):
		if(current_delay == 0):
			var damageTiles = damage_rect.get_overlapping_areas()
			for i in damageTiles:
				var collider
				if (i.has_node("weapon")):
					collider = i.get_node("weapon")
					player.get_node("player").set("hit_enemy", true)
				if (i.has_node("magic")):
					# freeze in collision block if hit with an ice attack
					if (i.get_parent() != null && i.get_parent().get_name() == "Ice"):
						frozen = true
						freezeblock_obj = freezeblock.instance()
						freezeblock_obj.set_scale(Vector2(sprite_offset.x * 2 / TILE_SIZE, sprite_offset.y * 2 / TILE_SIZE))
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
	return .horizontal_input_permitted() && !is_stunned && !is_dying

func closestXTile(direction, desiredX, space_state):
	var value = .closestXTile(direction, desiredX + gustx, space_state)
	gustx = 0
	return value

func step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile):
	if (!frozen):
		return .step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile)
	else:
		return {"desiredY": 0, "slope": false, "slopeTile": null, "abSlope": null, "animationSpeed": animation_speed, "ladderY": 0}

func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	new_animation = "walk"
	if (is_dying):
		new_animation = "die"
	if (is_hurt):
		new_animation = "hurt"
	get_node(new_animation).set_scale(Vector2(direction, 1))
	return {"animationSpeed": animation_speed, "animation": new_animation}

func die():
	queue_free()

func input_left():
	return ai_input == "left"

func input_right():
	return ai_input == "right"

func step_ai_input(space_state):
	var change_direction = false
	if (!is_hurt && !is_stunned):
		var is_wall = false
		var frontX = get_global_pos().x + direction * (sprite_offset.x + runspeed * current_gravity)
		var frontTile = space_state.intersect_ray(Vector2(frontX, get_global_pos().y - sprite_offset.y), Vector2(frontX, get_global_pos().y + sprite_offset.y - 1), [self, player.get_node("player")])
		if (frontTile != null && frontTile.has("position") && frontTile.has("collider")):
			change_direction = true
			is_wall = true
				
		frontTile = space_state.intersect_ray(Vector2(frontX + direction*runspeed, get_global_pos().y + sprite_offset.y), Vector2(frontX + direction*runspeed, get_global_pos().y + sprite_offset.y + TILE_SIZE), [self, player.get_node("player")])

		if (frontTile == null || !frontTile.has("position") && !falling):
			change_direction = true
		if (frontTile != null && frontTile.has("collider")):
			var collider = frontTile["collider"]
			if (collider.get_name() == "player" && collider.get_global_pos().y - collider["sprite_offset"].y > get_global_pos().y + sprite_offset.y):
				change_direction = true
		# slope tiles and one way tiles don't count
		var areaTile = space_state.intersect_ray(Vector2(frontX + direction*runspeed, get_global_pos().y + sprite_offset.y - TILE_SIZE), Vector2(frontX + direction*runspeed, get_global_pos().y + sprite_offset.y + TILE_SIZE), area2d_blacklist, 2147483647, 16)
		if (areaTile != null && areaTile.has("collider")):
			if (isSlope(areaTile["collider"].get_name())):
				change_direction = false
			if (!is_wall && areaTile["collider"].get_name() == "oneway" && areaTile["collider"].get_global_pos().y - TILE_SIZE / 2 > get_global_pos().y + sprite_offset.y - 1):
				change_direction = false

		if (change_direction):
			if (direction > 0):
				ai_input = "left"
			else:
				ai_input = "right"
		else:
			if (direction > 0):
				ai_input = "right"
			else:
				ai_input = "left"
	else:
		ai_input = ""

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
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	var animation_speed = 1

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
	
	step_ai_input(space_state)

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
	area2d_blacklist = [self, damage_rect, player.get_node("player/damage")]