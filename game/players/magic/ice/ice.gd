
extends Node2D

var iceball
var dust
var is_released = false
var direction = 1
var speed = 10
var hp = 2
var camera
var sampleplayer
var soundid

# Similar to fire. See comments in fire.gd. Will probably rewrite this as a base charge projectile
# class and extend it.

func _ready():
	set_fixed_process(true)
	iceball = get_node("Iceball")
	dust = get_node("dust")
	sampleplayer = get_node("SamplePlayer")
	soundid = sampleplayer.play("charge")

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
	iceball.set_param(Particles2D.PARAM_INITIAL_SIZE, scale)
	iceball.set_param(Particles2D.PARAM_FINAL_SIZE, scale*3/7.0)
	set_scale(Vector2(scale, scale))
	sampleplayer.set_volume_db(soundid, 5 * (scale - 1))

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	iceball.set_param(Particles2D.PARAM_GRAVITY_DIRECTION, angle)
	iceball.set_param(Particles2D.PARAM_INITIAL_ANGLE, angle)
	dust.set_emissor_offset(Vector2(direction*-16, 0))
	
func release():
	var scale = iceball.get_param(Particles2D.PARAM_INITIAL_SIZE)
	is_released = true
	hp = hp * ceil(scale)
	var volume = sampleplayer.get_volume_db(soundid)
	soundid = sampleplayer.play("ice")
	sampleplayer.set_volume_db(soundid, volume)