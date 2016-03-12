
extends "res://scenes/common/switches/BaseSwitch.gd"

export var is_toggle = false #if true, switch needs to be held down in order to remain active
var is_echo = false

func check_activation():
	if (is_toggle):
		is_on = false
	var tiles = get_node("switch").get_overlapping_areas()
	for i in tiles:
		if (i.get_name() == "damage" || i.get_name() == "damagable" || i.get_name() == "block" || i.get_name() == "oneway" || i.has_node("magic")):
			get_node("Sprite").set_frame(0)
			if (is_toggle):
				is_on = true
			elif (!is_echo):
				is_on = !is_on
				is_echo = true
	if (tiles.empty()):
		get_node("Sprite").set_frame(1)
		is_echo = false