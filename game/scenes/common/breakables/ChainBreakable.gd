# Breaks after a certain number of chain hits

extends "res://scenes/common/breakables/BaseChainBreakable.gd"

export var hp = 5
var max_hp

const CRUMBLE_COLOR = Color(12/255.0, 118/255.0, 112/255.0)

func _ready():
	max_hp = float(hp)

func check_chain():
	var chain_counter = chaingui.get_node("chaintext/counterGroup/counter").get_text()
	if (chaingui.is_visible() && chain_counter != counter):
		counter = chain_counter
		hp -= 1
		sprite.set_modulate(sprite.get_modulate().linear_interpolate(CRUMBLE_COLOR, 1 - hp/max_hp))
		dust()
	if (hp <= 0):
		is_crumbling = true
		crumble_related()

func crumble_related():
	for j in related_blocks:
		var related = j.get_ref()
		if (related != null && related.hp > 0):
			related.is_crumbling = true
			related.hp = 0
			related.start_crumble()

