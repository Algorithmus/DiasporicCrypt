
extends Node2D

var direction
var camera
var origin
const MAX_SPEED = 20
var speed = MAX_SPEED
var collision
var atk = 2

func _ready():
	set_physics_process(true)
	collision = get_node("damagable")

func _physics_process(delta):
	var yPos = get_global_position().y
	if (speed < 0 && origin != null && origin.get_ref() != null):
		# align with source on return
		var deltaY = origin.get_ref().get_global_position().y - get_global_position().y
		var s = sign(deltaY)
		yPos = s * min(abs(deltaY), abs(speed)) + get_global_position().y
	set_global_position(Vector2(direction*speed + get_global_position().x, yPos))
	speed = max(speed - 0.5, -MAX_SPEED)
	if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_position().x && direction > 0)
		|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_position().x && direction < 0)
		|| (origin != null && origin.get_ref() != null && origin.get_ref().get_global_position().x * direction >= get_global_position().x * direction)):
			remove()
	var collisions = collision.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() == "player" || i.has_node("magic") || i.has_node("weapon")):
			remove()
			
func remove():
	if (get_parent() != null):
		get_parent().remove_child(self)
