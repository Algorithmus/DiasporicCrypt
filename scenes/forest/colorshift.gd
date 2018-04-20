extends Node2D

var timer
var limit

export var start_color = Color(1, 0, 0)
export var end_color = Color(1, 0, 160/255.0)
export var curve = 1.0
var shader

func _ready():
	shader =  get_material()
	shader.set_shader_param("mask", start_color)
	var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
	timer = level.time
	limit = timer * 1.0
	set_physics_process(true)

func _physics_process(delta):
	timer -= 1
	var new_color = end_color.linear_interpolate(start_color, ease(timer/limit, curve))
	shader.set_shader_param("mask", new_color)
	if (timer <= 0):
		set_physics_process(false)
