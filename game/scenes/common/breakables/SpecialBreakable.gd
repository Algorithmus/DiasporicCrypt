# Breaks after a certain special is used

extends "res://scenes/common/breakables/BaseChainBreakable.gd"

export var special = "thrust"

var tiles = {"slice": "res://scenes/common/breakables/slice.png",
			"chop": "res://scenes/common/breakables/chop.png",
			"dualspin": "res://scenes/common/breakables/dualspin.png",
			"rush": "res://scenes/common/breakables/rush.png",
			"skewer": "res://scenes/common/breakables/skewer.png",
			"stab": "res://scenes/common/breakables/stab.png",
			"swift": "res://scenes/common/breakables/swift.png",
			"thrust": "res://scenes/common/breakables/thrust.png"}

const CRUMBLE_COLOR = Color(110/255.0, 75/255.0, 15/255.0)

func _ready():
	get_node("KinematicBody2D/Sprite").set_texture(load(tiles[special]))

func check_chain():
	var chain_counter = chaingui.get_node("chaintext/counterGroup/counter").get_text()
	if (chaingui.is_visible() && chain_counter != counter):
		counter = chain_counter
		dust()
	var chain_special = player.get_node("player").current_chain_special
	if (chain_special != null && chain_special["id"] == special):
		is_crumbling = true
		crumble_related()

