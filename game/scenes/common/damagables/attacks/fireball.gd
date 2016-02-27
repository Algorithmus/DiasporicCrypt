
extends Node2D

var direction
var camera
var speed = 6
var collision
var rateX = 0
var rateY = 0

func _ready():
	set_fixed_process(true)
	collision = get_node("damagable")

func _fixed_process(delta):
	if (rateX != 0 && rateY != 0):
		set_global_pos(Vector2(rateX + get_global_pos().x, rateY + get_global_pos().y))
	else:
		set_global_pos(Vector2(direction*speed + get_global_pos().x, get_global_pos().y))
	if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_pos().x && direction > 0)
		|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_pos().x && direction < 0)):
			queue_free()
	var collisions = collision.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() == "player" || i.has_node("magic") || i.has_node("weapon")):
			queue_free()