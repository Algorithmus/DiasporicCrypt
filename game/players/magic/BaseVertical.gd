
extends Node2D

var direction_y
var collision
var is_finish = false
var player
var sampleplayer
var direction
var collision_blacklist

# The pattern of this attack is to start at the player's current position
# or at the top of the screen and move upwards or downwards until hitting a solid block (eg, regular collisions, one way
# tiles, etc.) or until the end of the screen has been reached
# We have to ignore rays that intersect immediately as it's possible
# to place the attack near a slope or on top of a collision tile, which would make
# the attack useless.

func _ready():
	set_fixed_process(true)

func get_direction_check():
	pass

func set_process_scale():
	pass
	
func fix_scale(direction_check, direction_y):
	pass

func step_spell():
	if (!is_finish):
		var direction_check = get_direction_check()
		# detect platforms above current position
		# tiles directly on the same position don't count
		# also check special tiles
		if (direction_y == null):
			var space = get_world_2d().get_space()
			var space_state = Physics2DServer.space_get_direct_state(space)
			var direction_bound = get_global_pos().y + direction * player.get_node("Camera2D").get_offset().y * 2
			var ray_start = Vector2(get_global_pos().x, direction_check)
			var ray_end = Vector2(get_global_pos().x, direction_bound)
			var directionTile = space_state.intersect_ray(ray_start, ray_end, [self, player])
			var directionSpecialTile = space_state.intersect_ray(ray_start, ray_end, [collision_blacklist, player.get_node("damage")], 2147483647, 16)
			var directionTileY = direction_bound
			var directionTileSpecialY = direction_bound
			if (!directionTile.empty()):
				directionTileY = directionTile["position"].y
			# non-platform tiles don't count
			var check_directionSpecialTile = !directionSpecialTile.empty() && directionSpecialTile["collider"].get_name() != "ladder" && directionSpecialTile["collider"].get_name() != "magic" && directionSpecialTile["collider"].get_name() != "damagable" && directionSpecialTile["collider"].get_name() != "collision" && directionSpecialTile["collider"].get_name() != "potion"
			if (check_directionSpecialTile):
				directionTileSpecialY = directionSpecialTile["position"].y
			var closestDirectionY = min(directionTileY, directionTileSpecialY)
			if (direction > 0):
				closestDirectionY = max(directionTileY, directionTileSpecialY)
			if (!directionTile.empty() || check_directionSpecialTile && direction * (direction_check - closestDirectionY) > 0):
				direction_y = closestDirectionY
			if (direction * direction_check <= direction * direction_bound):
				final_animation()
		elif (direction * direction_y >= direction * direction_check):
			fix_scale(direction_check, direction_y)
			final_animation()
		if (!is_finish):
			set_process_scale()
	else:
		step_finish_animation()
	
func _fixed_process(delta):
	step_spell()

func remove_self():
	#attack is finished and no longer needs to be blacklisted
	#but remove it from the tilemap anyways since queue_free is too
	#slow
	player.remove_from_blacklist(collision_blacklist)
	if (self.get_parent() != null):
		self.get_parent().remove_child(self)
	queue_free()

func step_finish_animation():
	pass

func final_animation():
	is_finish = true