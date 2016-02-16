
extends Node2D

var accel = 0
var camera
var collision
var sprite
var sprite_offset
var player

func _ready():
	set_fixed_process(true)
	collision = get_node("collision")
	sprite = get_node("small")

func set_size(size):
	collision.set_scale(Vector2(size, size))
	if (size < 2):
		sprite = get_node("small")
		get_node("big").hide()
		sprite.set_scale(Vector2(size, size))
	else:
		sprite = get_node("big")
		get_node("small").hide()
		sprite.set_scale(Vector2(size/3.0, size/3.0))
	sprite_offset = collision.get_node("magic").get_shape().get_extents()

func _fixed_process(delta):
	if (get_global_pos().y - sprite_offset.x > camera.get_camera_pos().y - camera.get_offset().y):
		# remove from player object detection
		# and remove from tilemap because queue free is too slow
		player.remove_from_blacklist(collision)
		if (get_parent().has_node(get_name())):
			get_parent().remove_child(self)
		queue_free()
	accel += 1
	sprite.set_rot(sprite.get_rot() + 1)
	set_global_pos(Vector2(get_global_pos().x, accel + get_global_pos().y))