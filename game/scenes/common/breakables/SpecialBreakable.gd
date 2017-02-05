# Breaks after a certain special is used

extends "res://scenes/common/breakables/BaseChainBreakable.gd"

export var special = "thrust"

const CRUMBLE_COLOR = Color(110/255.0, 75/255.0, 15/255.0)

func check_chain():
	var chain_counter = chaingui.get_node("chaintext/counterGroup/counter").get_text()
	if (chaingui.is_visible() && chain_counter != counter):
		counter = chain_counter
		dust()
	var chain_special = player.get_node("player").current_chain_special
	if (chain_special != null && chain_special["id"] == special):
		is_crumbling = true
		crumble_related()

