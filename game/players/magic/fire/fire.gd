
extends Node2D

var fireball
var is_released = false
var direction = 1
var speed = 10
var hp = 2 # projectile is only allowed a certain number of hits before disappearing
var camera

func _ready():
	set_fixed_process(true)
	fireball = get_node("Fireball")

func _fixed_process(delta):
	if (is_released):
		set_global_pos(Vector2(direction*speed + get_global_pos().x, get_global_pos().y))
		if ((camera.get_camera_screen_center().x - direction * camera.get_offset().x < get_global_pos().x && direction > 0)
			|| (camera.get_camera_screen_center().x - direction * camera.get_offset().x > get_global_pos().x && direction < 0)
			|| hp <= 0):
			queue_free()
	
func change_scale(scale):
	fireball.set_param(Particles2D.PARAM_INITIAL_SIZE, scale)
	fireball.set_param(Particles2D.PARAM_FINAL_SIZE, scale*3/7.0)
	set_scale(Vector2(scale, scale))

func change_direction(new_direction):
	direction = new_direction
	set_scale(Vector2(direction, 1))
	var angle = fposmod(-direction*90, 360)
	fireball.set_param(Particles2D.PARAM_GRAVITY_DIRECTION, angle)
	fireball.set_param(Particles2D.PARAM_INITIAL_ANGLE, angle)
	
func release():
	fireball.set_use_local_space(false)
	var scale = fireball.get_param(Particles2D.PARAM_INITIAL_SIZE)
	#fireball.set_param(Particles2D.PARAM_LINEAR_VELOCITY, 2*scale/0.7)
	is_released = true
	hp = hp * ceil(scale)