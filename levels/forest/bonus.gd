
extends Node2D

export var night = Color(47.8/255.0, 79.71/255.0, 147.42/255.0)
export var sunrise = Color(1, 1, 1)
var color
var parallax_color
var timer
var limit


func _ready():
	ProjectSettings.set("blood_count", 0)
	ProjectSettings.set("show_blood_counter", true)
	parallax_color = get_node("ParallaxBackground/CanvasModulate")
	color = get_node("CanvasModulate")
	parallax_color.set_color(night)
	color.set_color(night)
	var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
	timer = level.time
	limit = timer * 1.0
	set_physics_process(true)

func _physics_process(delta):
	timer -= 1
	var color_value = sunrise.linear_interpolate(night, ease(timer/limit, 0.4))
	color.set_color(color_value)
	parallax_color.set_color(color_value)
	if (timer <= 0):
		ProjectSettings.set("sun", true)
		set_physics_process(false)
