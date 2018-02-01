
extends Node2D

var direction
var camera
var speed = 6
var collision
var rateX = 0
var rateY = 0
export var atk = 1

func _ready():
	set_physics_process(true)
	collision = get_node("damagable")

func _physics_process(delta):
	if (rateY != 0):
		set_global_position(Vector2(rateX + get_global_position().x, rateY + get_global_position().y))
	else:
		set_global_position(Vector2(direction*speed + get_global_position().x, get_global_position().y))
	if (direction != 0 && (camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_position().x && direction > 0)
		|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_position().x && direction < 0)):
			queue_free()
	elif (direction == 0 && rateY != 0 && ((rateY < 0 && camera.get_camera_screen_center().y - sign(rateY) * camera.get_offset().y > get_global_position().y) || (rateY > 0 && camera.get_camera_screen_center().y - sign(rateY) * camera.get_offset().y < get_global_position().y))):
		queue_free()
	var collisions = collision.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() == "player" || i.has_node("magic") || i.has_node("weapon")):
			queue_free()
