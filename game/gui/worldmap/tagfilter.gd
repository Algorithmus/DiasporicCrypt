
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
	sfx.play("cursor")

func _on_tagfilter_focus_exit():
	selected.hide()

func _on_tagfilter_pressed():
	print("tag filter pressed")
	tag.set_invert(!tag.get_invert())
	print(tag.get_invert())