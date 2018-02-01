
extends Area2D

const LENGTH = 11

var collision_rect
var sprite
var groundplane
var splash

func _ready():
	collision_rect = get_node("CollisionShape2D")
	sprite = get_node("Sprite")
	splash = get_node("splash")
	splash.hide()
	set_physics_process(true)

func _physics_process(delta):
	var scale = collision_rect.get_scale().y
	if (scale < LENGTH):
		scale += 1
		collision_rect.set_scale(Vector2(1, scale))
		collision_rect.set_position(Vector2(collision_rect.get_position().x, scale * 16))
	var rect = sprite.get_region_rect()
	var ground_distance = groundplane - get_global_position().y
	rect.size.y = min(ground_distance, scale * 32)
	if (ground_distance < scale * 32):
		splash.show()
		splash.set_position(Vector2(splash.get_position().x, ground_distance - 11))
	sprite.set_region_rect(rect)
