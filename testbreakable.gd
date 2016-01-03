
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"

func _fixed_process(delta):
	var tiles = get_node("KinematicBody2D/breakable").get_overlapping_areas()
	for i in tiles:
		if (i.has_node("weapon")):
			queue_free()

func _ready():
	# Initialization here
	set_fixed_process(true)


