
extends Node2D

var fireball
var is_released = false
var direction = 1
var speed = 10
var hp = 2 # projectile is only allowed a certain number of hits before disappearing
var camera
var sampleplayer
var soundid

func _ready():
	set_fixed_process(true)
	fireball = get_node("Fireball")
	sampleplayer = get_node("SamplePlayer")
	soundid = sampleplayer.play("charge")
	sampleplayer.set_volume_db(soundid, -10)

func _fixed_process(delta):
	if (is_released):
		set_global_pos(Vector2(direction*speed + get_global_pos().x, get_global_pos().y))
		if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_pos().x && direction > 0)
			|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_pos().x && direction < 0)
			|| hp <= 0):
			if (has_node("Area2D")):
				remove_child(get_node("Area2D"))
			if (!sampleplayer.is_active()):
				queue_free()
	elif (!sampleplayer.is_active()):
		soundid = sampleplayer.play("charge")

func change_scale(scale):
	fireball.set_param(Particles2D.PARAM_INITIAL_SIZE, scale)
	fireball.set_param(Particles2D.PARAM_FINAL_SIZE, scale*3/7.0)
	set_scale(Vector2(scale, scale))
	sampleplayer.set_volume_db(soundid, 5 * (scale - 1) - 10)

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	fireball.set_param(Particles2D.PARAM_GRAVITY_DIRECTION, angle)
	fireball.set_param(Particles2D.PARAM_INITIAL_ANGLE, angle)
	
func release():
	var scale = fireball.get_param(Particles2D.PARAM_INITIAL_SIZE)
	#fireball.set_param(Particles2D.PARAM_LINEAR_VELOCITY, 2*scale/0.7)
	is_released = true
	var volume = sampleplayer.get_volume_db(soundid)
	soundid = sampleplayer.play("fire")
	sampleplayer.set_volume_db(soundid, volume)
	hp = hp * ceil(scale)