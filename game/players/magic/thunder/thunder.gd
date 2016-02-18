
extends Node2D

var bottom_y
var collision
var player
var sprite
var is_finish = false
var animation_player
var splash
var sampleplayer
var volume

# The pattern of this attack is to start at the top of the screen
# and move downwards until hitting a solid block (eg, regular collisions, one way
# tiles, slopes, etc.)
# We have to ignore rays that intersect immediately as it's possible
# to place the attack on top of a collision tile, which would make
# the attack useless.

func _ready():
	set_fixed_process(true)
	collision = get_node("collision")
	sprite = get_node("attack")
	splash = get_node("splash")
	splash.hide()
	animation_player = get_node("AnimationPlayer")
	sampleplayer = get_node("SamplePlayer")
	var soundid = sampleplayer.play("thunder")
	sampleplayer.set_volume_db(soundid, volume)

func _fixed_process(delta):
	if (!is_finish):
		var bottom_check = get_global_pos().y + 32 * collision.get_scale().y
		# detect platforms below current position
		# tiles directly on the same position don't count
		# also check special tiles
		if (bottom_y == null):
			var space = get_world_2d().get_space()
			var space_state = Physics2DServer.space_get_direct_state(space)
			var bottom_bound = get_global_pos().y - player.get_node("Camera2D").get_offset().y * 2
			var ray_start = Vector2(get_global_pos().x, bottom_check)
			var ray_end = Vector2(get_global_pos().x, bottom_bound)
			var bottomTile = space_state.intersect_ray(ray_start, ray_end, [self, player])
			var bottomSpecialTile = space_state.intersect_ray(ray_start, ray_end, [get_node("collision/Area2D"), player.get_node("damage")], 2147483647, 16)
			var bottomTileY = bottom_bound
			var bottomTileSpecialY = bottom_bound
			if (!bottomTile.empty()):
				bottomTileY = bottomTile["position"].y
			# non-platform tiles don't count
			var check_bottomSpecialTile = !bottomSpecialTile.empty() && bottomSpecialTile["collider"].get_name() != "ladder" && bottomSpecialTile["collider"].get_name() != "magic" && bottomSpecialTile["collider"].get_name() != "damagable" && bottomSpecialTile["collider"].get_name() != "collision" && bottomSpecialTile["collider"].get_name() != "potion"
			if (check_bottomSpecialTile):
				bottomTileSpecialY = bottomSpecialTile["position"].y
			var closestBottomY = min(bottomTileY, bottomTileSpecialY)
			if ((!bottomTile.empty() || check_bottomSpecialTile) && closestBottomY - bottom_check > 0):
				bottom_y = closestBottomY
			if (bottom_check >= bottom_bound):
				final_animation()
		elif (bottom_y <= bottom_check):
			sprite.set_pos(Vector2(0, sprite.get_pos().y - bottom_check + bottom_y))
			final_animation()
		if (!is_finish):
			collision.set_scale(Vector2(collision.get_scale().x, collision.get_scale().y + 1))
			sprite.set_pos(Vector2(0, sprite.get_pos().y + 32))
	else:
		if (animation_player.get_current_animation_pos() == animation_player.get_current_animation_length()):
			remove_self()
	
func final_animation():
	#do final animation here
	is_finish = true
	var bottomY = sprite.get_pos().y + 32
	var sparks = get_node("sparks")
	splash.set_scale(Vector2(splash.get_scale().x, get_scale().x / 3.0))
	splash.set_pos(Vector2(0, bottomY - splash.get_texture().get_height() * splash.get_scale().y/2))
	sparks.set_scale(Vector2(sparks.get_scale().x, get_scale().x))
	sparks.set_pos(Vector2(0, bottomY - sparks.get_scale().y * 32))
	animation_player.play("finish")

func remove_self():
	#attack is finished and no longer needs to be blacklisted
	#but remove it from the tilemap anyways since queue_free is too
	#slow
	player.remove_from_blacklist(get_node("collision/Area2D"))
	if (self.get_parent() != null):
		self.get_parent().remove_child(self)
	queue_free()

func set_width(scale):
	set_scale(Vector2(scale, 1))
	volume = (scale - 1) * 5