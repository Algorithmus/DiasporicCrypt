
extends Node2D

var iceball
var is_released = false
var direction = 1
var speed = 10
var hp = 2
var camera

# Similar to fire. See comments in fire.gd. Will probably rewrite this as a base charge projectile
# class and extend it.

func _ready():
	set_fixed_process(true)
	iceball = get_node("Iceball")

func _fixed_process(delta):
	if (is_released):
		set_global_pos(Vector2(direction*speed + get_global_pos().x, get_global_pos().y))
		if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_pos().x && direction > 0)
			|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_pos().x && direction < 0)
			|| hp <= 0):
			queue_free()

func change_scale(scale):
	iceball.set_param(Particles2D.PARAM_INITIAL_SIZE, scale)
	iceball.set_param(Particles2D.PARAM_FINAL_SIZE, scale*3/7.0)
	set_scale(Vector2(scale, scale))

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	iceball.set_param(Particles2D.PARAM_GRAVITY_DIRECTION, angle)
	iceball.set_param(Particles2D.PARAM_INITIAL_ANGLE, angle)
	
func release():
	iceball.set_use_local_space(false)
	var scale = iceball.get_param(Particles2D.PARAM_INITIAL_SIZE)
	is_released = true
	hp = hp * ceil(scale)