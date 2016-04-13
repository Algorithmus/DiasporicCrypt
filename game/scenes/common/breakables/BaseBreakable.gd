
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var is_crumbling
var sound
var crumble_cycle = 0

func _fixed_process(delta):
	if (!is_crumbling):
		var tiles = get_node("KinematicBody2D/breakable").get_overlapping_areas()
		for i in tiles:
			if (check_crumble(i)):
				sound.set_volume_db(sound.play("crumble"), -10)
				is_crumbling = true
	else:
		sprite_opacity(0.5 + fmod(crumble_cycle, 4) * 0.3)
		crumble_cycle += 1
		if (!sound.is_active()):
			queue_free()

func _ready():
	# Initialization here
	sound = get_node("sound")

func sprite_opacity(alpha):
	get_node("KinematicBody2D/Sprite").set_opacity(alpha)

func check_crumble(i):
	return i.has_node("weapon")

func enter_screen():
	set_fixed_process(true)

func exit_screen():
	set_fixed_process(false)
