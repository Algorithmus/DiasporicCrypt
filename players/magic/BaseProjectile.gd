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

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if (is_released):
		set_global_position(Vector2(direction*speed + get_global_position().x, get_global_position().y))
		if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_position().x && direction > 0)
			|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_position().x && direction < 0)
			|| hp <= 0):
			if (has_node(collision.get_name())):
				remove_child(collision)
			#TODO - play sounds properly
			#if (!sampleplayer.is_active()):
				queue_free()
	#TODO - play sounds properly
	#elif (!sampleplayer.is_active()):
	#	soundid = sampleplayer.play(charge_sfx)

func change_scale(scale):
	sprite.process_material.scale = scale
	set_scale(Vector2(scale, scale))
	#TODO - play sounds properly
	#sampleplayer.set_volume_db(soundid, 5 * (scale - 1) - 10)

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	sprite.process_material.gravity = Vector3(sprite.process_material.gravity.x * direction, sprite.process_material.gravity.y, sprite.process_material.gravity.z)
	sprite.process_material.angle = angle
	
func release():
	var scale = sprite.process_material.scale
	is_released = true
	#TODO - play sounds properly
	"""
	var volume = sampleplayer.get_volume_db(soundid)
	soundid = sampleplayer.play(release_sfx)
	sampleplayer.set_volume_db(soundid, volume)
	"""
	hp = hp * ceil(scale)
