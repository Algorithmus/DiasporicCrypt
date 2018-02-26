
extends ToolButton

var selected
var tag
var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	selected = get_node("selected")
	tag = get_node("tag")
	sfx = sfxclass.instance()
	add_child(sfx)

func _on_tagfilter_focus_enter():
	selected.show()
	sfx.get_node("cursor").play()

func _on_tagfilter_focus_exit():
	selected.hide()

func _on_tagfilter_pressed():
	tag.set_invert(!tag.get_invert())
	sfx.get_node("confirm").play()
