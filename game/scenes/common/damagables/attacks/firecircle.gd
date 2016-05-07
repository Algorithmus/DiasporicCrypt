
extends Node2D

var speed = 6
var collision
var atk = 1
var currentx = 0
var pivot
var radius = 1
var initangle = 0

func _ready():
	set_fixed_process(true)
	collision = get_node("damagable")

func _fixed_process(delta):
	currentx += PI/180
	var circle = calculate_circle()
	set_global_pos(Vector2(pivot.x + circle.x, pivot.y + circle.y))
	radius += 16
	var collisions = collision.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() == "player" || i.has_node("magic") || i.has_node("weapon")):
			queue_free()
	if (currentx >= 2*PI + initangle):
		queue_free()

func calculate_circle():
	var x = cos(currentx)*radius
	var r = pow(radius, 2) - pow(x, 2)
	var s = 1
	if (fmod(currentx, 2*PI) > PI):
		s = -1
	var y = sqrt(abs(r))/2.0*s
	return Vector2(x, y)