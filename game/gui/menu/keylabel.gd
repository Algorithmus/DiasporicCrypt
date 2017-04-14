extends Control

# Display correct symbol mapped to controls

var keyboardmap = preload("res://gui/KeyboardCharacters.gd").new()
var key
var actionid

func _ready():
	key = get_node("key")

func set_key(value):
	keyboardmap.update_keys()
	actionid = value
	key.set_text(keyboardmap.map_action(actionid))

func reload_key():
	keyboardmap.update_keys()
	key.set_text(keyboardmap.map_action(actionid))