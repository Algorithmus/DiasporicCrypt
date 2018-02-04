
extends ToolButton

var selected
var filter_icon
var active = true

const RED = Color(146/255.0, 0, 0)
const BLACK = Color(35/255.0, 18/255.0, 18/255.0)

var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	selected = get_node("selected")
	filter_icon = get_node("icon")
	sfx = sfxclass.instance()
	add_child(sfx)

func _on_tagfilter_focus_enter():
	selected.show()
	sfx.play("cursor")

func _on_tagfilter_focus_exit():
	selected.hide()

func select(value):
	active = value
	if (active):
		filter_icon.set_modulate(RED)
	else:
		filter_icon.set_modulate(BLACK)

func _on_tagfilter_pressed():
	select(!active)

