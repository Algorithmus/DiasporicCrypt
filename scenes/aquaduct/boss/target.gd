
extends "res://scenes/common/target.gd"

var current_hp
var hp

signal no_hp
const RED = Color(1, 77 / 255.0, 77 / 255.0)

func _ready():
	set_physics_process(true)
	set_color()

func set_color():
	var color = RED.linear_interpolate(Color(1, 1, 1), float(current_hp) / hp)
	get_node("eye").set_modulate(color)

func check_hp(damage):
	current_hp -= damage
	
	set_color()
	
	if (current_hp <= 0):
		emit_signal("no_hp")
