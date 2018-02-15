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

const CRUMBLE_COLOR = Color(215/255.0, 206/255.0, 230/255.0)

func _ready():
	get_node("KinematicBody2D/Sprite").set_texture(load(tiles[special]))

func dust():
	var dust_obj = dust.instance()
	add_child(dust_obj)
	dust_obj.set_position(Vector2(randf()*32 - 16, randf()*32 - 16))
	dust_obj.get_node("particles").process_material.color = CRUMBLE_COLOR
	dust_obj.get_node("particles").set_emitting(true)
	dust_particles.append(dust_obj)

func check_chain():
	var chain_counter = chaingui.get_node("chaintext/counterGroup/counter").get_text()
	if (chaingui.is_visible() && chain_counter != counter):
		counter = chain_counter
		dust()
	var chain_special = player.get_node("player").current_chain_special
	if (chain_special != null && chain_special["id"] == special):
		is_crumbling = true


