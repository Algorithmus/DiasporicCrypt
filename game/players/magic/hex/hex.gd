
extends Node2D

var collision
var is_finish = false
var is_release = false
var top_y
var player
var beam
var swirl
var finish_counter = 0
const finish_delay = 50

# The pattern of this attack is to start at the player's current position
# and move upwards until hitting a solid block (eg, regular collisions, one way
# tiles, etc.)
# We have to ignore rays that intersect immediately as it's possible
# to place the attack near a slope, which would make
# the attack useless.

func _ready():
	set_fixed_process(true)
	collision = get_node("beam")
	remove_child(collision)
	beam = get_node("light")
	beam.hide()
	swirl = get_node("swirl")
	
func _fixed_process(delta):
	if (is_release):
		if (!is_finish):
			var top_check = get_global_pos().y - 32 * collision.get_scale().y * get_scale().y
			# detect platforms above current position
			# tiles directly on the same position don't count
			# also check special tiles
			if (top_y == null):
				var space = get_world_2d().get_space()
				var space_state = Physics2DServer.space_get_direct_state(space)
				var top_bound = get_global_pos().y + player.get_node("Camera2D").get_offset().y * 2
				var ray_start = Vector2(get_global_pos().x, top_check)
				var ray_end = Vector2(get_global_pos().x, top_bound)
				var topTile = space_state.intersect_ray(ray_start, ray_end, [self, player])
				var topSpecialTile = space_state.intersect_ray(ray_start, ray_end, [collision.get_node("collision"), player.get_node("damage")], 2147483647, 16)
				var topTileY = top_bound
				var topTileSpecialY = top_bound
				if (!topTile.empty()):
					topTileY = topTile["position"].y
				# non-platform tiles don't count
				var check_topSpecialTile = !topSpecialTile.empty() && topSpecialTile["collider"].get_name() != "ladder" && topSpecialTile["collider"].get_name() != "magic" && topSpecialTile["collider"].get_name() != "damagable" && topSpecialTile["collider"].get_name() != "collision" && topSpecialTile["collider"].get_name() != "potion"
				if (check_topSpecialTile):
					topTileSpecialY = topSpecialTile["position"].y
				var closestTopY = max(topTileY, topTileSpecialY)
				if (!topTile.empty() || check_topSpecialTile && top_check - closestTopY > 0):
					top_y = closestTopY
				if (top_check <= top_bound):
					final_animation()
			elif (top_y >= top_check):
				beam.set_scale(Vector2(beam.get_scale().x, beam.get_scale().y - (beam.get_pos().y - top_check + top_y)/(32*get_scale().y)))
				final_animation()
			if (!is_finish):
				var scale = collision.get_scale().y + 1.0/get_scale().y
				collision.set_scale(Vector2(collision.get_scale().x, scale))
				beam.set_scale(Vector2(beam.get_scale().x, scale))
				swirl.set_param(Particles2D.PARAM_GRAVITY_STRENGTH, swirl.get_param(Particles2D.PARAM_GRAVITY_STRENGTH) + 16)
		else:
			finish_counter += 1
			if (finish_counter >= finish_delay):
				remove_self()

func remove_self():
	#attack is finished and no longer needs to be blacklisted
	#but remove it from the tilemap anyways since queue_free is too
	#slow
	player.remove_from_blacklist(collision.get_node("collision"))
	if (self.get_parent() != null):
		self.get_parent().remove_child(self)
	queue_free()

func final_animation():
	is_finish = true

func change_scale(scale):
	set_scale(Vector2(scale, scale))
	collision.set_scale(Vector2(1, 1/scale))

func release():
	is_release = true
	beam.show()
	add_child(collision)