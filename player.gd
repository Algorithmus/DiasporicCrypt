
extends KinematicBody2D

const DEFAULT_GRAVITY = 1
const RUN_SPEED = 6
const JUMP_SPEED = 20
const TILE_SIZE = 32
const SPEED_LIMIT = 50

var position = Vector2()
var current_animation = "idle"
var direction = 1
var falling = false
var accel = DEFAULT_GRAVITY
var sprite_offset = Vector2()
var tilemap
var collision
var animation_player
var jumpPressed = false

func min_array(array):
	if (array.size() == 1):
		return array[0]
	elif (array.size() > 1):
		var min_float = array[0]
		for i in range(1, array.size() - 1):
			min_float = min(array[i], min_float)
		return min_float
	else:
		return null

func isSlope(name):
	return name.match("slope*-*")

func getSlopes(space_state):
	var relevantSlopeTileA = space_state.intersect_ray(Vector2(get_global_pos().x-sprite_offset.x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x-sprite_offset.x, get_global_pos().y+sprite_offset.y+8), [self], 2147483647, 16)
	var relevantSlopeTileB = space_state.intersect_ray(Vector2(get_global_pos().x+sprite_offset.x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x+sprite_offset.x, get_global_pos().y+sprite_offset.y+8), [self], 2147483647, 16)
	
	var relevantSlopeTiles = []
	
	if (relevantSlopeTileA.has("collider")):
		var colliderA = relevantSlopeTileA["collider"]
		#print(relevantSlopeTileA["normal"])
		if (isSlope(colliderA.get_name())):
			relevantSlopeTiles.append(colliderA)
	if (relevantSlopeTileB.has("collider")):
		var colliderB = relevantSlopeTileB["collider"]
		#print(relevantSlopeTileB["normal"])
		if (isSlope(colliderB.get_name())):
			relevantSlopeTiles.append(colliderB)	
	return relevantSlopeTiles

func parseSlopeType(name):
	var values = name.split("slope")
	# slope#-#
	# extract #; first is left corner and last is right corner
	var slopes = values[1].split("-")
	if (slopes[0] == "a" && slopes[1] == "b"):
		#print("a-b slope detected")
		return null
	return values[1].split_floats("-")

func closestXTile(direction, desiredX):
	#print("check h collision")
	#print(direction)
	#print(is_colliding())
	#print(str(get_collision_pos().x) + ", " + str(get_collision_pos().y))
	#print(get_global_pos().x)
	#print(desiredX)
	# true = check left side
	# false = check right side
	if (is_colliding()):
		return 0
		#if (get_collision_pos().y <= get_pos().y + sprite_offset.y && get_collision_pos().y >= get_pos().y - sprite_offset.y):
			#if (direction):
			#	return get_pos().x - sprite_offset.x - get_collision_pos().x
			#else:
			#	return get_collision_pos().x - get_pos().x - sprite_offset.x
	
	return desiredX

func _fixed_process(delta):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	
	position.y = 0
	var new_animation = current_animation
	var horizontal_motion = false
	if (Input.is_action_pressed("ui_left")):
		position.x = -min(RUN_SPEED, closestXTile(true, RUN_SPEED))
		new_animation = "run"
		direction = -1
		horizontal_motion = true
	elif (Input.is_action_pressed("ui_right")):
		position.x = min(RUN_SPEED, closestXTile(false, RUN_SPEED))
		new_animation = "run"
		direction = 1
		horizontal_motion = true
	else:
		position.x = 0
		new_animation = "idle"
	
	#print("position x")
	#print(position.x)
	
	move(position)
	
	position.x = 0
	
	var relevantSlopeTiles = getSlopes(space_state)
	
	var onZeroSlope = false
	var onSlope = false
	var currentSlopeTile = null
	var b = null
	if (relevantSlopeTiles.size() > 0):
		#print("on slope")
		#print(relevantSlopeTiles)
		for i in relevantSlopeTiles:
			b = parseSlopeType(i.get_name())
			if (b != null && (get_global_pos().x >= i.get_global_pos().x - TILE_SIZE/2 && get_global_pos().x < i.get_global_pos().x + TILE_SIZE/2)):
				currentSlopeTile = i
		
		if (currentSlopeTile != null):
			#print("current slope tile")
			#print(currentSlopeTile)
			onSlope = true
			b = parseSlopeType(currentSlopeTile.get_name())
			#print(b)
			#print(currentSlopeTile.get_global_pos())
			#print(get_pos())
			if ((b[0] == TILE_SIZE - 1 || b[1] == TILE_SIZE - 1) && (get_global_pos().x < currentSlopeTile.get_global_pos().x - TILE_SIZE / 2 || get_global_pos().x > currentSlopeTile.get_global_pos().x + TILE_SIZE / 2)):
				#print("too far away")
				pass
			else:
				#print("calculate slope position")
				var t = (get_global_pos().x - currentSlopeTile.get_global_pos().x + TILE_SIZE / 2)/TILE_SIZE
				var slopeY = (1 - t) * b[0] + t * b[1]
				
				#print(t)
				#print(slopeY)
				
				if ((get_pos().y + sprite_offset.y > currentSlopeTile.get_global_pos().y - TILE_SIZE / 2 + int(slopeY) - JUMP_SPEED + 5) || !jumpPressed):
					var desiredSlopeY = currentSlopeTile.get_global_pos().y - TILE_SIZE / 2 + int(slopeY)
					#print("desired slope y")
					#print(desiredSlopeY)
					#print(get_pos().y + sprite_offset.y)
					print("clamp to slope")
					position.y = desiredSlopeY - get_pos().y - sprite_offset.y
					move(position)
	
	jumpPressed = false
	
	if (Input.is_action_pressed("ui_up")):
		if (!falling):
			accel = -JUMP_SPEED
			falling = true
			jumpPressed = true
			print("jumppressed")

	var desiredY = accel
	
	"""
	if (on_ground()):
		falling = false
	else:
		falling = true
	"""
	
	if (falling):
		desiredY += 1
	else:
		desiredY = 1
	
	var s = 1
	
	if (desiredY < 0):
		s = -1
		
	#print("desiredY")
	#print(desiredY)
	#print(accel)
	
	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(get_global_pos().x-sprite_offset.x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x-sprite_offset.x, get_global_pos().y+sprite_offset.y+16), [self])
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(get_global_pos().x+sprite_offset.x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x+sprite_offset.x, get_global_pos().y+sprite_offset.y+16), [self])
	
	space = get_world_2d().get_space()
	space_state = Physics2DServer.space_get_direct_state(space)
	
	relevantSlopeTiles = getSlopes(space_state)
	
	var closestTileY = desiredY

	var zeroSlope = null

	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()

	if (normalTileCheck):
		if (!relevantTileA.has("position")):
			closestTileY = relevantTileB["position"].y
		elif (!relevantTileB.has("position")):
			closestTileY = relevantTileA["position"].y
		else:
			closestTileY = min(relevantTileA["position"].y, relevantTileB["position"].y)

		closestTileY -= get_pos().y+sprite_offset.y
			
		#print("closestTileY")
		#print(relevantTileA)
		#print(relevantTileB)
		#print(get_pos().y+ sprite_offset.y)
		#print(closestTileY)
		#print(desiredY)
		
		closestTileY = int(closestTileY)
	
		if (closestTileY == 0):
			if s == -1:
				closestTileY = JUMP_SPEED
			if s == 1:
				falling = false
	
		if (abs(desiredY) < abs(closestTileY)):
			falling = true
	if (relevantSlopeTiles.size() > 0):
		#print("check vertical slope tiles")
		var distance = []
		var closestSlopeTile = null
		var t
		var b
		var slopeY = 0
		var closest_level = null
		for i in relevantSlopeTiles:
			b = parseSlopeType(i.get_name())
			if (b != null):
				t = (get_global_pos().x - i.get_global_pos().x + TILE_SIZE/2) / TILE_SIZE
				slopeY = (1 - t) * b[0] + t * b[1]
				if (get_pos().y + sprite_offset.y <= i.get_global_pos().y - TILE_SIZE/2 + int(slopeY)):
					var d = i.get_global_pos().y - TILE_SIZE/2 - get_pos().y - sprite_offset.y
					distance.append(d)
			else:
				zeroSlope = i
		
		#print("min distance")
		#print(distance)
		#print(min_array(distance))
		#print("closest level")
		
		closest_level = min_array(distance)
		
		#print(closest_level)
		
		if (closest_level != null):
			for j in relevantSlopeTiles:
				b = parseSlopeType(j.get_name())
				if (b != null):
					#print("check for relevant tiles")
					#print(b)
					#print(get_global_pos().x)
					#print(str(j.get_global_pos().x - (TILE_SIZE/2)) + ", " + str(j.get_global_pos().x + (TILE_SIZE/2)))
					if (j.get_global_pos().y - TILE_SIZE/2 - get_pos().y - sprite_offset.y <= closest_level && get_global_pos().x >= j.get_global_pos().x - TILE_SIZE/2 && get_global_pos().x <= j.get_global_pos().x + TILE_SIZE/2):
						closestSlopeTile = j

		if (zeroSlope != null && closestSlopeTile == null):
			#print("zero slope")
			#print(desiredY)
			#print(zeroSlope.get_global_pos().y - TILE_SIZE/2)
			#print(get_pos().y + sprite_offset.y)
			#print(get_global_pos().y + sprite_offset.y)
			#print(s)
			if (zeroSlope.get_global_pos().y - TILE_SIZE/2 <= get_pos().y + sprite_offset.y):
				move(Vector2(0, zeroSlope.get_global_pos().y - TILE_SIZE/2 - get_pos().y - sprite_offset.y - 1))
			closestTileY = min(zeroSlope.get_global_pos().y - TILE_SIZE/2 - get_pos().y - sprite_offset.y - 1, desiredY)
			closestTileY = int(closestTileY)
			falling = false

		if (closestSlopeTile != null):
			#print("check closest slope tile")
			b = parseSlopeType(closestSlopeTile.get_name())
			t = (get_global_pos().x - closestSlopeTile.get_global_pos().x + TILE_SIZE/2)/TILE_SIZE
			slopeY = (1 - t) * b[0] + t * b[1]
			
			#print(t)
			#print(slopeY)
			
			#print(closestSlopeTile.get_global_pos())
			#print(get_pos().y + sprite_offset.y)
			
			if (closestSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY - get_pos().y - sprite_offset.y < JUMP_SPEED - 1):
				#print("detect on slope")
				onSlope = true
				falling = false
				
			if (get_pos().y + sprite_offset.y >= closestSlopeTile.get_global_pos().y + TILE_SIZE/2):
				closestTileY = get_pos().y + sprite_offset.y - closestSlopeTile.get_global_pos().y - TILE_SIZE/2 - TILE_SIZE
			elif (get_pos().y + sprite_offset.y <= closestSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY):
				closestTileY = closestSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY - get_pos().y - sprite_offset.y
				#print("final slope value")
				#print(closestTileY)
				#print(desiredY)
				#print(str(get_pos().y + sprite_offset.y) + ", " + str(closestSlopeTile.get_global_pos().y - TILE_SIZE/2))
				if (jumpPressed):
					closestTileY = desiredY

			#print(closestTileY)
			closestTileY = int(closestTileY)
	#print("slope falling?")
	#print(zeroSlope == null)
	#print(normalTileCheck)
	#print(onSlope)
	if (!normalTileCheck && ((relevantSlopeTiles.size() == 0 || !onSlope) && zeroSlope == null)):
		falling = true
	
	accel = min(min(abs(desiredY), abs(closestTileY)), SPEED_LIMIT) * s
	
	print("final accel")
	#print(get_pos().x)
	#print(get_global_pos().x)
	#print(falling)
	
	position.y = accel
	
	if (falling):
		if (accel < 0):
			new_animation = "jump"
		else:
			new_animation = "fall"
	
	if (!horizontal_motion):
		if (!falling && ((animation_player.get_current_animation() == "land" && animation_player.is_playing()) || current_animation == "fall")):
			new_animation = "land"
			print("land")
	
	var motion = position
	
	get_node("NormalSpriteGroup/"+new_animation).set_scale(Vector2(direction, 1))
	
	move(motion)
	play_animation(new_animation)
	
func _ready():
	# Initialization here
	collision = get_node("CollisionShape2D")
	sprite_offset = collision.get_shape().get_extents()
	animation_player = get_node("AnimationPlayer")
	
	set_fixed_process(true)

func load_tilemap(var tilemap_node):
	tilemap = tilemap_node.get_node("tilemap")

func on_ground():
	print("is colliding?")
	#print(ray_ground.is_colliding())
	#print(get_collision_normal())
	#print(get_pos().y + sprite_offset.y)
	print(get_pos().y + sprite_offset.y)
	#return ray_ground.is_colliding() && get_pos().y + sprite_offset.y >= ray_ground.get_collision_point().y - 16
	pass

func play_animation(animation):
	if (current_animation != animation):
		animation_player.play(animation)
		current_animation = animation

func loop_jump_animation():
	animation_player.seek(0.1, true)
	
func loop_fall_animation():
	animation_player.seek(0.2, true)