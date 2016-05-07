
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
	set_fixed_process(true)

func _fixed_process(delta):
	var scale = collision_rect.get_scale().y
	if (scale < LENGTH):
		scale += 1
		collision_rect.set_scale(Vector2(1, scale))
		collision_rect.set_pos(Vector2(collision_rect.get_pos().x, scale * 16))
	var rect = sprite.get_region_rect()
	var ground_distance = groundplane - get_global_pos().y
	rect.size.y = min(ground_distance, scale * 32)
	if (ground_distance < scale * 32):
		splash.show()
		splash.set_pos(Vector2(splash.get_pos().x, ground_distance - 11))
	sprite.set_region_rect(rect)