
extends "res://scenes/common/switches/BaseSwitch.gd"

export var is_toggle = false #if true, switch needs to be held down in order to remain active
var is_echo = false
var player

func check_activation():
	if (player == null):
		player = get_tree().get_root().get_node("world/playercontainer/player")
	if (is_toggle):
		is_on = false
	if (player.get("swing_block") != null && player.get("swing_block") == get_node("hangable") && player.get("whip_hanging")):
		if (is_toggle):
			is_on = true
		elif (!is_echo):
			is_on = !is_on
			is_echo = true
	else:
		is_echo = false