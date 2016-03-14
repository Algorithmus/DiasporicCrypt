
extends Node2D

var direction
var camera
var origin
const MAX_SPEED = 20
var speed = MAX_SPEED
var collision
var atk = 2

func _ready():
	set_fixed_process(true)
	collision = get_node("damagable")

func _fixed_process(delta):
	var yPos = get_global_pos().y
	if (speed < 0 && origin != null && origin.get_ref() != null):
		# align with source on return
		var deltaY = origin.get_ref().get_global_pos().y - get_global_pos().y
		var s = sign(deltaY)
		yPos = s * min(abs(deltaY), abs(speed)) + get_global_pos().y
	set_global_pos(Vector2(direction*speed + get_global_pos().x, yPos))
	speed = max(speed - 0.5, -MAX_SPEED)
	if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_pos().x && direction > 0)
		|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_pos().x && direction < 0)
		|| (origin != null && origin.get_ref() != null && origin.get_ref().get_global_pos().x * direction >= get_global_pos().x * direction)):
			remove()
	var collisions = collision.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() == "player" || i.has_node("magic") || i.has_node("weapon")):
			remove()
			
func remove():
	if (get_parent() != null):
		get_parent().remove_child(self)