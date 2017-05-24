
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var is_crumbling
var sound
var crumble_cycle = 0
var check_related_blocks = false
var related_blocks = []

func _fixed_process(delta):
	if (!is_crumbling):
		var tiles = get_node("KinematicBody2D/breakable").get_overlapping_areas()
		if (!check_related_blocks):
			# unfortunately, get_overlapping_areas() doesn't always return back anything the first time, so we have to keep
			# checking until we get something
			for i in tiles:
				if (i.get_name() == "breakable" && i.get_parent().get_parent().get_script() == get_script()):
					related_blocks.append(weakref(i.get_parent().get_parent()))
				check_related_blocks = true
		for i in tiles:
			if (check_crumble(i)):
				start_crumble()
	else:
		sprite_opacity(0.5 + fmod(crumble_cycle, 4) * 0.3)
		crumble_cycle += 1
		if (!sound.is_active()):
			crumble_related()
			queue_free()

# make game more playable by destroying neighboring breakable objects of the same type
func crumble_related():
	for j in related_blocks:
		var related = j.get_ref()
		if (related != null && !related.is_crumbling):
			related.start_crumble()

func start_crumble():
	sound.set_volume_db(sound.play("crumble"), -10)
	is_crumbling = true
	crumble()

func crumble():
	pass

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
	check_related_blocks = false
	related_blocks = []
