
extends KinematicBody2D
# the great majority of player behavior and interaction implementation is modelled after this article: http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/comment-page-1/#comments
# please note that this blog link no longer exists, but you might still be able to see it through archive.org

const DEFAULT_GRAVITY = 1
const RUN_SPEED = 6
const JUMP_SPEED = 20
const TILE_SIZE = 32
# restrict vertical speed to prevent skipping and other weirdness
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

# slopes have the format slope#-#, where # denotes the 
# position (from the top) of the corner of the slope from left to right
func isSlope(name):
	return name.match("slope*-*")

func getSlopes(space_state):
	var relevantSlopeTileA = space_state.intersect_ray(Vector2(get_global_pos().x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x, get_global_pos().y+sprite_offset.y+8), [self], 2147483647, 16)
	#var relevantSlopeTileB = space_state.intersect_ray(Vector2(get_global_pos().x+sprite_offset.x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x+sprite_offset.x, get_global_pos().y+sprite_offset.y+8), [self], 2147483647, 16)
	
	var relevantSlopeTiles = []
	
	if (relevantSlopeTileA.has("collider")):
		var colliderA = relevantSlopeTileA["collider"]
		if (isSlope(colliderA.get_name())):
			relevantSlopeTiles.append(colliderA)
	"""
	if (relevantSlopeTileB.has("collider")):
		var colliderB = relevantSlopeTileB["collider"]
		if (isSlope(colliderB.get_name())):
			relevantSlopeTiles.append(colliderB)	
	"""
	return relevantSlopeTiles

func parseSlopeType(name):
	var values = name.split("slope")
	# slope#-#
	# extract #; first is left corner and last is right corner
	var slopes = values[1].split("-")
	if (slopes[0] == "a" && slopes[1] == "b"):
		return null
	return values[1].split_floats("-")

func closestXTile(direction, desiredX):
	# true = check left side
	# false = check right side
	if (is_colliding()):
		return 0
	return desiredX

func _fixed_process(delta):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)
	
	# step horizontal motion first
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
	
	move(position)
	position.x = 0
	
	# check slope tiles
	var relevantSlopeTiles = getSlopes(space_state)
	
	var onZeroSlope = false
	var onSlope = false
	var currentSlopeTile = null
	var b = null
	var forwardY = get_pos().y + sprite_offset.y
	if (relevantSlopeTiles.size() > 0):
		for i in relevantSlopeTiles:
			b = parseSlopeType(i.get_name())
			if (b != null && (get_global_pos().x >= i.get_global_pos().x - TILE_SIZE/2 && get_global_pos().x < i.get_global_pos().x + TILE_SIZE/2)):
				currentSlopeTile = i
		
		if (currentSlopeTile != null):
			onSlope = true
			b = parseSlopeType(currentSlopeTile.get_name())
			# ignore bottom slopes if we're not close enough to them
			if ((b[0] == TILE_SIZE - 1 || b[1] == TILE_SIZE - 1) && (get_global_pos().x < currentSlopeTile.get_global_pos().x - TILE_SIZE / 2 || get_global_pos().x > currentSlopeTile.get_global_pos().x + TILE_SIZE / 2)):
				pass
			else:
				var t = (get_global_pos().x - currentSlopeTile.get_global_pos().x + TILE_SIZE / 2)/TILE_SIZE
				var slopeY = (1 - t) * b[0] + t * b[1]
				
				var slopeAdjustedTileY = currentSlopeTile.get_global_pos().y - TILE_SIZE / 2 + int(slopeY)
				
				# clamp to slope only if not jumping
				# unfortunately, the extra height from the default jump speed isn't enough to clear 
				# neighboring slopes. Playing with the values yields 5 as sufficient to do so
				if ((forwardY > slopeAdjustedTileY - JUMP_SPEED + 5) || !jumpPressed):
					position.y = slopeAdjustedTileY - forwardY
					move(position)
	
	# check vertical motion
	jumpPressed = false
	
	if (Input.is_action_pressed("ui_up")):
		if (!falling):
			accel = -JUMP_SPEED
			falling = true
			jumpPressed = true
			print("jumppressed")

	var desiredY = accel
	
	if (falling):
		desiredY += 1
	else:
		desiredY = 1
	
	var s = 1
	
	if (desiredY < 0):
		s = -1
	
	forwardY = get_global_pos().y + sprite_offset.y
	var leftX = get_global_pos().x - sprite_offset.x
	var rightX = get_global_pos().x + sprite_offset.x
	# bottom left ray check
	var relevantTileA = space_state.intersect_ray(Vector2(leftX, forwardY), Vector2(leftX, forwardY+16), [self])
	# bottom right ray check
	var relevantTileB = space_state.intersect_ray(Vector2(rightX, forwardY), Vector2(rightX, forwardY+16), [self])

	relevantSlopeTiles = getSlopes(space_state)
	
	var closestTileY = desiredY

	var abSlope = null

	# check regular blocks
	var normalTileCheck = !relevantTileA.empty() || !relevantTileB.empty()

	if (normalTileCheck):
		if (!relevantTileA.has("position")):
			closestTileY = relevantTileB["position"].y
		elif (!relevantTileB.has("position")):
			closestTileY = relevantTileA["position"].y
		else:
			closestTileY = min(relevantTileA["position"].y, relevantTileB["position"].y)

		closestTileY -= get_pos().y+sprite_offset.y
		closestTileY = int(closestTileY)

		# prevent sticking to ceiling
		if (closestTileY == 0):
			if s == -1:
				closestTileY = JUMP_SPEED - 1
			# landed on a platform; not falling anymore
			if s == 1:
				falling = false
	
		# ensure we are falling if not mediated by jumping
		if (abs(desiredY) < abs(closestTileY)):
			falling = true
	forwardY = get_pos().y + sprite_offset.y
	
	# check slope tiles
	if (relevantSlopeTiles.size() > 0):
		var distance = []
		var closestSlopeTile = null
		var t
		var b
		var slopeY = 0
		var closest_level = null
		# find relevant distances to slope tiles
		for i in relevantSlopeTiles:
			b = parseSlopeType(i.get_name())
			if (b != null):
				t = (get_global_pos().x - i.get_global_pos().x + TILE_SIZE/2) / TILE_SIZE
				slopeY = (1 - t) * b[0] + t * b[1]
				if (forwardY <= i.get_global_pos().y - TILE_SIZE/2 + int(slopeY)):
					var d = i.get_global_pos().y - TILE_SIZE/2 - forwardY
					distance.append(d)
			else:
				abSlope = i

		closest_level = min_array(distance)

		# find relevant slope tile
		# ignore all other blocks next to it
		if (closest_level != null):
			for j in relevantSlopeTiles:
				b = parseSlopeType(j.get_name())
				if (b != null):
					if (j.get_global_pos().y - TILE_SIZE/2 - forwardY <= closest_level && get_global_pos().x >= j.get_global_pos().x - TILE_SIZE/2 && get_global_pos().x <= j.get_global_pos().x + TILE_SIZE/2):
						closestSlopeTile = j

		# not standing on a slope. This is just a block whose collision
		# is ignorable when standing on a slope tile next to it.
		if (abSlope != null && closestSlopeTile == null):
			if (abSlope.get_global_pos().y - TILE_SIZE/2 <= forwardY):
				move(Vector2(0, abSlope.get_global_pos().y - TILE_SIZE/2 - forwardY - 1))
				forwardY = get_pos().y + sprite_offset.y
			closestTileY = min(abSlope.get_global_pos().y - TILE_SIZE/2 - forwardY - 1, desiredY)
			closestTileY = int(closestTileY)
			falling = false

		# standing on a valid slope tile
		if (closestSlopeTile != null):
			b = parseSlopeType(closestSlopeTile.get_name())
			t = (get_global_pos().x - closestSlopeTile.get_global_pos().x + TILE_SIZE/2)/TILE_SIZE
			slopeY = (1 - t) * b[0] + t * b[1]

			# check that we are really standing on a slope tile
			if (closestSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY - forwardY < JUMP_SPEED - 1):
				onSlope = true
				falling = false
			
			# don't need to check slope on ceilings
			if (forwardY >= closestSlopeTile.get_global_pos().y + TILE_SIZE/2):
				closestTileY = forwardY - closestSlopeTile.get_global_pos().y - TILE_SIZE/2 - TILE_SIZE
			elif (forwardY <= closestSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY):
				closestTileY = closestSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY - forwardY
				if (jumpPressed):
					closestTileY = desiredY

			closestTileY = int(closestTileY)
			
	# final falling status check for all kinds of collisions
	if (!normalTileCheck && ((relevantSlopeTiles.size() == 0 || !onSlope) && abSlope == null)):
		falling = true
	
	accel = min(min(abs(desiredY), abs(closestTileY)), SPEED_LIMIT) * s

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