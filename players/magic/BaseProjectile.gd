# Base class for projectile like spells

extends Node2D

var sprite
var is_released = false
var direction = 1
var speed = 10
var hp = 2 # projectile is only allowed a certain number of hits before disappearing
var camera
var sampleplayer
var soundid
var collision
var release_sfx
var charge_sfx
var atk = 10
var boundaries

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if (is_released):
		set_global_position(Vector2(direction*speed + get_global_position().x, get_global_position().y))
		var clear_object = false
		if (boundaries != null):
			var nw = boundaries.get_node("NW")
			var se = boundaries.get_node("SE")
			if (global_position.x <= nw.global_position.x || global_position.x >= se.global_position.x || global_position.y <= nw.global_position.y || global_position.y >= se.global_position.y):
				clear_object = true
		elif ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_position().x && direction > 0)
			|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_position().x && direction < 0)
			|| hp <= 0):
				clear_object = true

		if (clear_object):
			if (has_node(collision.get_name())):
				remove_child(collision)
			if (!sampleplayer.get_node(soundid).playing):
				queue_free()
	elif (!sampleplayer.get_node(soundid).playing):
		soundid = charge_sfx
		sampleplayer.get_node(soundid).play()

func change_scale(scale):
	sprite.process_material.scale = scale
	set_scale(Vector2(scale, scale))
	sampleplayer.get_node(soundid).set_volume_db(5 * (scale - 1) - 10)

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	sprite.process_material.gravity = Vector3(sprite.process_material.gravity.x * direction, sprite.process_material.gravity.y, sprite.process_material.gravity.z)
	sprite.process_material.angle = angle
	
func release():
	var scale = sprite.process_material.scale
	is_released = true
	var volume = sampleplayer.get_node(soundid).get_volume_db()
	sampleplayer.get_node(soundid).stop()
	soundid = release_sfx
	sampleplayer.get_node(soundid).play()
	sampleplayer.get_node(soundid).set_volume_db(volume)
	hp = hp * ceil(scale)
