
extends KinematicBody2D
# the great majority of player behavior and interaction implementation is modelled after this article: http://higherorderfun.com/blog/2012/05/20/the-guide-to-implementing-2d-platformers/comment-page-1/#comments
# please note that this blog link sometimes doesn't work, but you might still be able to see it through archive.org

const DEFAULT_GRAVITY = 1
# in order not to jump off 0-31 slopes, keep run speed below 10
const RUN_SPEED = 7
const JUMP_SPEED = 20
const TILE_SIZE = 32
const LADDER_SPEED = 5
const DAMAGE_THROWBACK = 10
const WATER = 0.5
const VERTICAL_DAMAGE_THROWBACK = 6
const HURT_GRACE_PERIOD = 60
const DEFAULT_FALL_HEIGHT = JUMP_SPEED * (JUMP_SPEED - 1)/2
# restrict vertical speed to prevent skipping and other weirdness
const SPEED_LIMIT = 30

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
var hanging = false
var climbing_platform = false
var climb_platform = null
var climbspeed = 6
var on_ladder = false
var ladder_top = null
var is_crouching = false
var crouch_requested = false
var movingPlatform = null
var movingPlatformPos = null
var is_attacking = false
var attack_requested = false
var weapon = preload("res://sword.xml")
var weapon_collider
var weapon_offset = Vector2()
var weapon_collided = false
var damage_rect
var damageDelta = Vector2()
var is_hurt = false
var invulnerable = false
var hurt_grace_cycle = 0
var is_suspended = false
var current_gravity = DEFAULT_GRAVITY
var underwater = false
var fall_height = 0

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
	var relevantSlopeTile = space_state.intersect_ray(Vector2(get_global_pos().x, get_global_pos().y+sprite_offset.y), Vector2(get_global_pos().x, get_global_pos().y+sprite_offset.y+8), [self, damage_rect, weapon_collider], 2147483647, 16)
	if (relevantSlopeTile.has("collider")):
		var collider = relevantSlopeTile["collider"]
		if (isSlope(collider.get_name())):
			return collider
	return null
	
func getClimbPlatform(space_state, direction):
	# true = check left side
	# false = check right side
	var platformY = get_global_pos().y - sprite_offset.y + 16
	var relevantTile = null
	if (direction):
		relevantTile = space_state.intersect_ray(Vector2(get_global_pos().x - sprite_offset.x, platformY), Vector2(get_global_pos().x - sprite_offset.x - 16, platformY), [self])
	else:
		relevantTile = space_state.intersect_ray(Vector2(get_global_pos().x + sprite_offset.x, platformY), Vector2(get_global_pos().x + sprite_offset.x + 16, platformY), [self])

	if (relevantTile.has("collider")):
		if(relevantTile["collider"].has_node("climbable")):
			return relevantTile["collider"]
	return null

func getLadderTile(space_state):
	var leftX = get_global_pos().x - sprite_offset.x
	var ladderTile = space_state.intersect_ray(Vector2(leftX, get_global_pos().y - sprite_offset.y), Vector2(leftX, get_global_pos().y + sprite_offset.y), [self, damage_rect, weapon_collider], 2147483647, 16)
	if (ladderTile.has("collider")):
		var tileName = ladderTile["collider"].get_name()
		if (tileName == "ladder" || tileName == "ladder_top"):
			return ladderTile["collider"]

	var rightX = get_global_pos().x + sprite_offset.x
	ladderTile = space_state.intersect_ray(Vector2(rightX, get_global_pos().y - sprite_offset.y), Vector2(rightX, get_global_pos().y + sprite_offset.y), [self, damage_rect, weapon_collider], 2147483647, 16)
	if (ladderTile.has("collider")):
		var tileName = ladderTile["collider"].get_name()
		if (tileName == "ladder" || tileName == "ladder_top"):
			return ladderTile["collider"]
	return null

func snapToLadder(ladder):
	var ladderX = ladder.get_global_pos().x - get_global_pos().x
	move(Vector2(ladderX, 0))

func getOneWayTile(space_state, desiredY):
	var leftX = get_global_pos().x - sprite_offset.x
	var oneWayTile = space_state.intersect_ray(Vector2(leftX, get_global_pos().y + sprite_offset.y), Vector2(leftX, get_global_pos().y + sprite_offset.y + desiredY), [self, damage_rect, weapon_collider], 2147483647, 16)
	if (oneWayTile.has("collider")):
		if (oneWayTile["collider"].get_name() == "oneway"):
			return oneWayTile["collider"]
	return null

# we reused the damage rect to also check AB slopes from the side since they're not
# normal collisions and can be ignored.
func checkABSlope():
	var collisionTiles = damage_rect.get_overlapping_areas()
	for i in collisionTiles:
		if (i.get_name() == "slopea-b" && i.get_global_pos().y + TILE_SIZE/2 > int(get_pos().y - sprite_offset.y) && i.get_global_pos().y - TILE_SIZE/2 < int(get_pos().y + sprite_offset.y)):
			return true
	return false

func parseSlopeType(name):
	var values = name.split("slope")
	# slope#-#
	# extract #; first is left corner and last is right corner
	var slopes = values[1].split("-")
	if (slopes[0] == "a" && slopes[1] == "b"):
		return null
	return values[1].split_floats("-")

func clearMovingPlatform():
	movingPlatform = null
	movingPlatformPos = null

func closestXTile(direction, desiredX):
	# true = check left side
	# false = check right side
	if (is_colliding()):
		if (get_collision_pos().y > int(get_pos().y - sprite_offset.y) && get_collision_pos().y < int(get_pos().y + sprite_offset.y)):
			return 0
	return desiredX

func closestYTile(tileA, tileB):
	if (!tileA.has("position")):
		return tileB["position"].y
	elif (!tileB.has("position")):
		return tileA["position"].y
	else:
		return min(tileA["position"].y, tileB["position"].y)

func remove_weapon_collider():
	if (has_node(weapon_collider.get_name())):
		remove_child(weapon_collider)

func _fixed_process(delta):
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
	
	var movingDeltaY = 0
	
	movingPlatform = null
	
	# check moving platforms before everything else
	if (normalTileCheck):
		var movingPlatform_check = null
		if (relevantTileA.has("collider")):
			movingPlatform_check = relevantTileA["collider"]
		else:
			movingPlatform_check = relevantTileB["collider"]
		if(movingPlatform_check.get_name() == "blockR" || movingPlatform_check.get_name() == "blockL"):
			if (movingPlatform_check.get_global_pos().y - TILE_SIZE/2 >= int(forwardY)):
				movingPlatform = movingPlatform_check
			else:
				clearMovingPlatform()
		else:
			clearMovingPlatform()

	# clear moving platforms if landing on one way platform tiles
	var oneWayTile = getOneWayTile(space_state, max(accel, TILE_SIZE))
	var onOneWayTile = false
	if (oneWayTile != null):
		onOneWayTile = oneWayTile.get_global_pos().y - TILE_SIZE/2 >= get_pos().y + sprite_offset.y
		clearMovingPlatform()

	if (climb_platform != null):
		if (climb_platform.get_name() == "blockR" || climb_platform.get_name() == "blockL"):
			movingPlatform = climb_platform
		else:
			clearMovingPlatform()

	if (movingPlatform != null):
		var newPos = Vector2(movingPlatform.get_global_pos().x, movingPlatform.get_global_pos().y)
		if (movingPlatformPos == null):
			movingPlatformPos = movingPlatform.get_parent()["previousPos_" + movingPlatform.get_name()]
		var movingDeltaX = newPos.x - movingPlatformPos.x
		# only move with the platform if landed on it
		# merely detecting it is there doesn't count
		if (int(forwardY) >= newPos.y - TILE_SIZE/2 - 2 && !climbing_platform && !hanging):
			var platformDeltaX = 0
			if (get_global_pos().x + movingDeltaX > newPos.x + TILE_SIZE/2 || get_global_pos().x + movingDeltaX < newPos.x - TILE_SIZE/2):
				movingDeltaX = 0
		move(Vector2(movingDeltaX, newPos.y - movingPlatformPos.y))
		movingPlatformPos = newPos
	
	# check taking damage
	var is_hurt_check = false
	
	var dx = 0
	var dy = 0
	var damageTiles = damage_rect.get_overlapping_areas()

	for i in damageTiles:
		if (i.get_name() == "water"):
			if (i.get_global_pos().y - TILE_SIZE/2 <= get_pos().y - sprite_offset.y):
				if (!underwater):
					get_node("sound").set_volume_db(get_node("sound").play("splash_down"), (fall_height/DEFAULT_FALL_HEIGHT*current_gravity - 1)*10)
				underwater = true
				current_gravity = WATER
			elif (i.get_global_pos().y + TILE_SIZE/2 >= get_pos().y + sprite_offset.y):
				if (underwater):
					get_node("sound").set_volume_db(get_node("sound").play("splash_up"), 0)
				underwater = false
				current_gravity = DEFAULT_GRAVITY

	if (!invulnerable):
		for i in damageTiles:
			if (i.get_name() == "damagable"):
				is_hurt_check = true
				dx += get_global_pos().x - i.get_global_pos().x
				dy += get_global_pos().y - i.get_global_pos().y
		
		# calculate throwback based on sum total positions of damagables
		if (dx != 0):
			dx = dx/abs(dx) * DAMAGE_THROWBACK
			damageDelta.x = int(dx)
		if (dy != 0):
			dy = dy/abs(dy) * VERTICAL_DAMAGE_THROWBACK
			damageDelta.y = int(dy)

	# check if there are still damagable tiles
	if (is_hurt_check):
		is_hurt = true
		invulnerable = true
		climbing_platform = false
	# proceed with hurt cycle
	else:
		if (is_hurt && damageDelta.x == 0 && damageDelta.y == 0):
			is_hurt = false
		if (damageDelta.x != 0):
			damageDelta.x = (abs(damageDelta.x) - 1) * damageDelta.x/abs(damageDelta.x)
		if (damageDelta.y != 0):
			damageDelta.y = (abs(damageDelta.y) - 1) * damageDelta.y/abs(damageDelta.y)
	
	# step horizontal motion first
	position.y = 0
	var new_animation = current_animation
	var horizontal_motion = false
	forwardY = get_pos().y + sprite_offset.y
	var relevantSlopeTile = null
	var onSlope = false
	var slopeX = 0
	if (!climbing_platform && !is_crouching && !is_attacking && !is_hurt):
		if (Input.is_action_pressed("ui_left")):
			position.x = -min(RUN_SPEED, closestXTile(true, RUN_SPEED))
			# can't tell right now if we are on a slope tile and can ignore
			# the a-b slope tile
			# so delay horizontal motion until slope check
			if (checkABSlope()):
				slopeX = position.x
				position.x = 0
			new_animation = "run"
			direction = -1
			horizontal_motion = true
		elif (Input.is_action_pressed("ui_right")):
			position.x = min(RUN_SPEED, closestXTile(false, RUN_SPEED))
			if (checkABSlope()):
				slopeX = position.x
				position.x = 0
			new_animation = "run"
			direction = 1
			horizontal_motion = true
		else:
			position.x = 0
			new_animation = "idle"
		
		# disengage hanging on ledge if opposite button is pressed
		if (hanging && climb_platform != null):
				if ((direction < 0 && climb_platform.get_global_pos().x > get_global_pos().x) || (direction > 0 && climb_platform.get_global_pos().x < get_global_pos().x)):
					hanging = false
					move(Vector2(0, climb_platform.get_global_pos().y + TILE_SIZE/2 - get_pos().y + sprite_offset.y))
					climb_platform = null

		position.x = position.x * current_gravity

		move(position)
		
		position.x = 0
		
		# check ladder after horizontal movement
		var ladderTile = getLadderTile(space_state)
		
		if (ladderTile != null && ladderTile.get_name() == "ladder_top"):
			ladder_top = ladderTile
		else:
			ladder_top = null
		
		if (on_ladder):
			ladderTile = getLadderTile(space_state)
			if (ladderTile == null):
				on_ladder = false
		
	if (!on_ladder):
		# check slope tiles
		relevantSlopeTile = getSlopes(space_state)
		
		var onZeroSlope = false
		var currentSlopeTile = null
		var b = null
		forwardY = get_pos().y + sprite_offset.y
		if (relevantSlopeTile != null):
			b = parseSlopeType(relevantSlopeTile.get_name())
			if (b != null):
				if (b[0] == 0 || b[1] == 0):
					move(Vector2(slopeX, 0))
				onSlope = true
				b = parseSlopeType(relevantSlopeTile.get_name())
				# ignore bottom slopes if we're not close enough to them
				if ((b[0] == TILE_SIZE - 1 || b[1] == TILE_SIZE - 1) && (get_global_pos().x < relevantSlopeTile.get_global_pos().x - TILE_SIZE / 2 || get_global_pos().x > relevantSlopeTile.get_global_pos().x + TILE_SIZE / 2)):
					pass
				else:
					var t = (get_global_pos().x - relevantSlopeTile.get_global_pos().x + TILE_SIZE / 2)/TILE_SIZE
					var slopeY = (1 - t) * b[0] + t * b[1]
					
					var slopeAdjustedTileY = relevantSlopeTile.get_global_pos().y - TILE_SIZE / 2 + int(slopeY)
					
					# clamp to slope only if not jumping
					# unfortunately, the extra height from the default jump speed isn't enough to clear 
					# neighboring slopes. Playing with the values yields 5 as sufficient to do so
					if ((forwardY > slopeAdjustedTileY - (JUMP_SPEED - 5)*current_gravity) || !jumpPressed):
						position.y = slopeAdjustedTileY - forwardY
						move(position)
							
	var climb_vertically = false
	
	# disengage hanging if hurt
	if (hanging && climb_platform != null && is_hurt):
		hanging = false
		move(Vector2(0, climb_platform.get_global_pos().y + TILE_SIZE/2 - get_pos().y + sprite_offset.y))
		climb_platform = null
	
	# check platform climbing after horizontal movement requested
	if (!on_ladder && !is_hurt):
		var platform_check = null
		
		#if (!climbing_platform):
		platform_check = getClimbPlatform(space_state, direction == -1)
		
		# clamp to platform if should be hanging
		if (platform_check != null && !climbing_platform && climb_platform == null):
			hanging = true
			var d = platform_check.get_global_pos().x - direction * TILE_SIZE/2 - get_global_pos().x - direction * sprite_offset.x
			climb_platform = platform_check
			move(Vector2(d, 0))
			
		# stick with moving platform
		# more noticeable on faster horizontal platforms
		if (movingPlatform == climb_platform && climb_platform != null && hanging):
			var d = climb_platform.get_global_pos().x - direction * TILE_SIZE/2 - get_global_pos().x - direction * sprite_offset.x
			move(Vector2(d, 0))
		
		if (platform_check == null && climb_platform != null && !climbing_platform):
			climb_platform = null
			hanging = false
		
		# animate climbing platform
		# move a specific distance in an L shape to climb the platform every fixed function call
		# move up 4 tiles (the height of the character) and then left or right one tile
		# depending on how you choose to animate climbing, this may or may not
		# look very nice. If you have too few frames or don't adjust the vertical position, the
		# character can sometimes look like they're oscillating up and down on the platform
		# vertical motion is delayed until vertical motion checking
		if (climbing_platform && climb_platform != null):
			if (get_pos().y + sprite_offset.y <= climb_platform.get_global_pos().y - TILE_SIZE/2):
				move(Vector2(climbspeed * direction, 0))
				if ((direction == 1 && get_global_pos().x >= climb_platform.get_global_pos().x) || (direction == -1 && get_global_pos().x <= climb_platform.get_global_pos().x)):
					climb_platform = null
					climbing_platform = false
			# don't keep climbing if the platform isn't there anymore
			# but clamp to it horizontally if it is and we are moving up
			elif (get_pos().y - sprite_offset.y <= climb_platform.get_global_pos().y + TILE_SIZE/2) :
				var platformDeltaX = climb_platform.get_global_pos().x - direction * TILE_SIZE/2 - get_global_pos().x - sprite_offset.x * direction
				move(Vector2(platformDeltaX, 0))
				
				climb_vertically = true
			else:
				climbing_platform = false
		else: 
			climbing_platform = false
	
	if (is_hurt):
		move(Vector2(damageDelta.x, 0))
	
	# check vertical motion
	jumpPressed = false
	
	var ladderY = 0
	
	forwardY = get_global_pos().y + sprite_offset.y
	
	crouch_requested = false
	
	if (!is_hurt):
		if (Input.is_action_pressed("ui_up")):
			var ladderTile = getLadderTile(space_state)
			if (ladderTile != null):
				# only allow entering ladder from bottom
				if (!on_ladder && ladderTile.get_name() != "ladder_top"):
					on_ladder = true
					climbing_platform = false
					is_crouching = false
					snapToLadder(ladderTile)
					is_attacking = false
					remove_weapon_collider()
				elif (on_ladder):
					if (ladderTile.get_name() == "ladder_top"):
						ladder_top = ladderTile
					if (ladder_top != null):
						if (ladder_top.get_global_pos().y + TILE_SIZE/2 >= get_pos().y + sprite_offset.y):
							on_ladder = false
						else:
							var d = get_pos().y + sprite_offset.y - ladder_top.get_global_pos().y - TILE_SIZE/2
							ladderY = -min(LADDER_SPEED, d)
							snapToLadder(ladder_top)
					else:
						ladderY = -LADDER_SPEED
						snapToLadder(ladderTile)
			
			if (!on_ladder):
				if ((!falling || underwater) && !climbing_platform):
					accel = -JUMP_SPEED * current_gravity
					falling = true
					jumpPressed = true
				if (hanging):
					hanging = false
					climbing_platform = true
	
		if (Input.is_action_pressed("ui_down")):
			crouch_requested = true
			var ladderTile = getLadderTile(space_state)
			if (ladderTile != null):
				# only allow entering ladder if not at the bottom
				if (!on_ladder && ((!normalTileCheck && !onOneWayTile) || ladder_top != null || ladderTile.get_name() == "ladder_top")):
					on_ladder = true
					climbing_platform = false
					is_crouching = false
					snapToLadder(ladderTile)
					is_attacking = false
					remove_weapon_collider()
				elif (on_ladder):
					if (normalTileCheck):
						var closestNormalTileY = closestYTile(relevantTileA, relevantTileB)
						var deltaY = closestNormalTileY - get_pos().y - sprite_offset.y
						if (int(deltaY) > 0):
							snapToLadder(ladderTile)
							ladderY = min(int(deltaY), LADDER_SPEED)
							animation_speed = -1
						else:
							accel = 0
							on_ladder = false
					else:
						snapToLadder(ladderTile)
						ladderY = LADDER_SPEED
						animation_speed = -1
			else:
				falling = true
				on_ladder = false
				# make sure we are really falling
				accel = max(1, accel)
					
			if (hanging && !on_ladder):
				hanging = false
	
	if (is_hurt):
		accel += damageDelta.y
	
	# don't bother checking regular tiles below character if on ladder
	if (!on_ladder):
		var desiredY = accel
		
		if (falling):
			desiredY += 1 * current_gravity * current_gravity
		else:
			desiredY = 1
		
		var s = 1
		
		if (desiredY < 0):
			s = -1
		
		relevantSlopeTile = getSlopes(space_state)
		
		var closestTileY = desiredY
	
		var abSlope = null
	
		# check regular static blocks
		if (normalTileCheck):
			closestTileY = closestYTile(relevantTileA, relevantTileB)
	
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
		
		# check slopea-b tiles from above
		var collisionTiles = damage_rect.get_overlapping_areas()
		for i in collisionTiles:
			if (i.get_name() == "slopea-b" && i.get_global_pos().y + TILE_SIZE/2 >= int(get_pos().y - sprite_offset.y) && i.get_global_pos().y - TILE_SIZE/2 < int(get_pos().y - sprite_offset.y)):
				print(str(i.get_global_pos().y + TILE_SIZE/2 - get_pos().y + sprite_offset.y) + ", " + str(desiredY))
				#closestTileY = max(i.get_global_pos().y + TILE_SIZE/2 - get_pos().y + sprite_offset.y, desiredY)
				move(Vector2(0, i.get_global_pos().y + TILE_SIZE/2 - get_pos().y + sprite_offset.y))

		# check slope tiles
		if (relevantSlopeTile != null):
			var closestSlopeTile = null
			var t
			var b
			var slopeY = 0
			var closest_level = null
			# find relevant distances to slope tiles
			b = parseSlopeType(relevantSlopeTile.get_name())
			if (b != null):
				t = (get_global_pos().x - relevantSlopeTile.get_global_pos().x + TILE_SIZE/2) / TILE_SIZE
				slopeY = (1 - t) * b[0] + t * b[1]
				if (forwardY <= relevantSlopeTile.get_global_pos().y - TILE_SIZE/2 + int(slopeY)):
					closest_level = relevantSlopeTile.get_global_pos().y - TILE_SIZE/2 - forwardY
					b = parseSlopeType(relevantSlopeTile.get_name())
					t = (get_global_pos().x - relevantSlopeTile.get_global_pos().x + TILE_SIZE/2)/TILE_SIZE
					slopeY = (1 - t) * b[0] + t * b[1]
					
					# check that we are really standing on a slope tile
					if (relevantSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY - forwardY < JUMP_SPEED - 1):
						onSlope = true
						falling = false
					
					# don't need to check slope on ceilings
					if (forwardY >= relevantSlopeTile.get_global_pos().y + TILE_SIZE/2):
						closestTileY = forwardY - relevantSlopeTile.get_global_pos().y - TILE_SIZE/2 - TILE_SIZE
					elif (forwardY <= relevantSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY):
						closestTileY = relevantSlopeTile.get_global_pos().y - TILE_SIZE/2 + slopeY - forwardY
						if (jumpPressed):
							closestTileY = desiredY

					closestTileY = int(closestTileY)
			else:
				# not standing on a slope. This is just a block whose collision
				# is ignorable when standing on a slope tile next to it.
				abSlope = relevantSlopeTile
				if (abSlope.get_global_pos().y - TILE_SIZE/2 <= forwardY):
					move(Vector2(0, abSlope.get_global_pos().y - TILE_SIZE/2 - forwardY - 1))
					forwardY = get_pos().y + sprite_offset.y
				closestTileY = min(abSlope.get_global_pos().y - TILE_SIZE/2 - forwardY - 1, desiredY)
				closestTileY = int(closestTileY)
				falling = false
		
		# handle one way tiles
		if (onOneWayTile):
			if (oneWayTile.get_global_pos().y - TILE_SIZE/2 <= int(forwardY) + 1):
				move(Vector2(0, oneWayTile.get_global_pos().y - TILE_SIZE/2 - int(forwardY) - 1))
				forwardY = get_pos().y + sprite_offset.y
				falling = false
			closestTileY = min(oneWayTile.get_global_pos().y - TILE_SIZE/2 - int(forwardY) - 1, desiredY)
			closestTileY = int(closestTileY)
		
		# handle standing on a ladder_top tile
		if (ladder_top != null && !normalTileCheck):
			if (ladder_top.get_global_pos().y + TILE_SIZE/2 <= int(forwardY)):
				# in theory, we'd like this to work as is, but without the extra - 2,
				# we run into collisions with neighboring ladder blocks
				# same reason we can't pass between static body tileset tiles with gaps
				# one tile wide
				move(Vector2(0, int(ladder_top.get_global_pos().y + TILE_SIZE/2 - forwardY - 2)))
				forwardY = get_pos().y + sprite_offset.y
				falling = false
			closestTileY = min(ladder_top.get_global_pos().y + TILE_SIZE/2 - forwardY, desiredY)
			closestTileY = int(closestTileY)
		
		# final falling status check for all kinds of collisions
		if (!normalTileCheck && ((relevantSlopeTile == null || !onSlope) && abSlope == null) && ladder_top == null && oneWayTile == null):
			falling = true
		
		accel = min(min(abs(desiredY), abs(closestTileY)), SPEED_LIMIT * current_gravity) * s

		# handle crouching now that we know if we are standing on ground blocks
		if (crouch_requested && !falling && (normalTileCheck || onSlope || abSlope != null || onOneWayTile)):
			is_crouching = true
		elif (!crouch_requested):
			is_crouching = false
		
		# clamp to platform vertically to prevent falling while hanging with no input
		if (hanging && climb_platform != null):
			accel = climb_platform.get_global_pos().y - TILE_SIZE/2 - get_pos().y + sprite_offset.y
	
		# move character up from climbing ledge
		# see notes in horizontal motion about animation
		if (climb_vertically && climbing_platform):
			#var d = climb_platform.get_global_pos().y - TILE_SIZE/2 - get_pos().y + sprite_offset.y
			accel = -climbspeed
			falling = false

		# don't fall while standing on moving platforms moving up
		if (desiredY > - JUMP_SPEED + 1 && movingPlatform != null && !hanging && !climbing_platform && movingPlatform.get_global_pos().y - TILE_SIZE/2 >= get_pos().y + sprite_offset.y):
			falling = false

		# only allow attacks to hit objects once during a hit
		if (weapon_collided):
			remove_weapon_collider()
			weapon_collided = false

		# handle attacking
		if ((animation_player.get_current_animation().match("*attack") && animation_player.get_current_animation_length() == animation_player.get_current_animation_pos()) || climbing_platform || hanging || on_ladder):
			is_attacking = false
			remove_weapon_collider()
		elif (!is_attacking && attack_requested && !is_hurt):
			attack_requested = false
			if (!hanging && !climbing_platform):
				is_attacking = true
				var weapon_height = 0
				if (is_crouching):
					weapon_height = sprite_offset.y
				get_node("sound").set_volume_db(get_node("sound").play("attack"), -10)
				weapon_collider.set_pos(Vector2((weapon_offset.x + sprite_offset.x + 1) * direction, -sprite_offset.y + weapon_offset.y + weapon_height))
				add_child(weapon_collider)
				weapon_collided = false
	
		position.y = accel
		
		# check animations
		if (falling):
			if (accel < 0):
				new_animation = "jump"
			else:
				new_animation = "fall"

		if (!falling && ((animation_player.get_current_animation() == "land" && animation_player.is_playing()) || current_animation == "fall")):
			if (!horizontal_motion):
				new_animation = "land"
			if (current_animation != "land"):
				get_node("sound").set_volume_db(get_node("sound").play("land"), (fall_height/DEFAULT_FALL_HEIGHT*current_gravity - 1)*10)
		
		if (is_crouching):
			new_animation = "crouch"
		
		if (is_attacking):
			var modifier = ""
			if (is_crouching):
				modifier = "d"
			if (falling):
				modifier = "a"
			new_animation = modifier + "attack"
		
		if (climbing_platform || hanging):
			new_animation = "climb"
			if (hanging):
				animation_speed = 0
		
		if (is_hurt):
			new_animation = "hurt"
			if (damageDelta.x != 0):
				direction = -damageDelta.x/abs(damageDelta.x)
		
		if (invulnerable):
			hurt_grace_cycle += 1
			var alpha = 0.5 + fmod(hurt_grace_cycle, 4)*0.1
			get_node("NormalSpriteGroup").set_opacity(alpha)
			if (hurt_grace_cycle > HURT_GRACE_PERIOD):
				hurt_grace_cycle = 0
				invulnerable = false
				get_node("NormalSpriteGroup").set_opacity(1)
		
	var motion = position
		
	if (on_ladder):
		direction = 1
		motion.y = ladderY
		new_animation = "ladder"
		if (ladderY == 0):
			animation_speed = 0

	if (falling):
		fall_height += max(0, position.y)
	else:
		fall_height = 0

	get_node("NormalSpriteGroup/"+new_animation).set_scale(Vector2(direction, 1))
	
	move(motion)
	play_animation(new_animation, animation_speed)

func _input(event):
	if (event.is_action_pressed("ui_attack") && event.is_pressed() && !event.is_echo()):
		attack_requested = true

func _ready():
	collision = get_node("CollisionShape2D")
	sprite_offset = collision.get_shape().get_extents()
	animation_player = get_node("AnimationPlayer")
	climbspeed = animation_player.get_animation("climb").get_length() * 6
	damage_rect = get_node("damage")
	
	weapon_collider = weapon.instance()
	weapon_offset = weapon_collider.get_node("weapon").get_shape().get_extents()
	
	weapon_collider.connect("area_enter", self, "_on_weapon_collision")
	
	get_node("sound").set_polyphony(10)
	
	set_process_input(true)
	set_fixed_process(true)

# notify when weapon collides with stuff
func _on_weapon_collision(area):
	var collisions = area.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() != "damage" && i != weapon_collider && i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder"):
			weapon_collided = true

func load_tilemap(var tilemap_node):
	tilemap = tilemap_node.get_node("tilemap")

func play_animation(animation, speed):
	animation_player.set_speed(speed)
	if (current_animation != animation):
		animation_player.play(animation)
		if (animation == "crouch" && current_animation == "dattack"):
			animation_player.seek(animation_player.get_current_animation_length())
		current_animation = animation

func loop_jump_animation():
	animation_player.seek(0.1, true)
	
func loop_fall_animation():
	animation_player.seek(0.2, true)