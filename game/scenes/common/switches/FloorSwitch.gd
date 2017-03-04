
extends "res://scenes/common/switches/BaseSwitch.gd"

export var is_toggle = false #if true, switch needs to be held down in order to remain active
var is_echo = false

func check_activation():
	var tiles = get_node("switch").get_overlapping_areas()
	var active = false
	if (is_toggle):
		is_on = false
		active = true
	for i in tiles:
		if (i.get_name() == "damage" || i.get_name() == "damagable" || i.get_name() == "block" || i.get_name() == "oneway" || i.has_node("magic")):
			if (!i.has_node("inversehex")):
				active = true
				get_node("Sprite").set_frame(0)
				if (is_toggle):
					is_on = true
				elif (!is_echo):
					is_on = !is_on
					is_echo = true
	for j in switches:
		j.set("is_on", is_on)
		if (!is_on && j.get("once")):
			j.set("activated", true)
			j.get_node("Sprite").set_frame(0)
	if (!active || (is_toggle && !is_on)):
		get_node("Sprite").set_frame(1)
		is_echo = false
	return active