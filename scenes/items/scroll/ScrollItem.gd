
extends Node

# Scroll data

var title
var display
var content
var description
var image = "res://scenes/items/scroll/scroll.png"
var new = true
var order
var type = "scroll"
var inputs = ["ui_up", "ui_down", "ui_left", "ui_right", "ui_jump", "ui_attack", "ui_magic", "ui_blood", "ui_spell_prev", "ui_spell_next", "ui_pause", "ui_select"]
var keymapclass = preload("res://gui/InputCharacters.gd")
var keymap
var cost = 0

func _init():
	keymap = keymapclass.new()

func _ready():
	keymap.update_keys()

static func sort_scrolls(a, b):
	return a.order <= b.order

func parse_content():
	var translation = do_parse(content)
	if (title == "SCROLL_WARRIOR"):
		var chains = Globals.get("chain")
		for chain in chains:
			var used = chains[chain]
			var combostring = ""
			var idstring = "CHAIN_" + chain.to_upper()
			if (used):
				combostring = do_parse(idstring)
			translation = translation.replace("[" + idstring + "]", combostring)
	return translation

func do_parse(text):
	keymap.update_keys()
	var translation = tr(text)
	translation = translation.replace("[break]", "\n")
	for i in inputs:
		translation = translation.replace("[" + i + "]", keymap.map_action(i))
	return translation
