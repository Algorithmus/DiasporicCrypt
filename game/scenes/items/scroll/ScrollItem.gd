
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
var keymapclass = preload("res://gui/KeyboardCharacters.gd")
var keymap
var cost = 0

func _init():
	keymap = keymapclass.new()

func _ready():
	keymap.update_keys()

static func sort_scrolls(a, b):
	return a.order <= b.order

func parse_content():
	keymap.update_keys()
	var translation = tr(content)
	translation = translation.replace("[break]", "\n")
	for i in inputs:
		translation = translation.replace("[" + i + "]", keymap.map_action(i))
	return translation