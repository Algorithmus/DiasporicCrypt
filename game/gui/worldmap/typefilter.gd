
extends ToolButton

var selected = false
var icon
var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	icon = get_node("icon")
	sfx = sfxclass.instance()
	add_child(sfx)

func _on_mapfilter_focus_enter():
	set("custom_colors/font_color", Color(1, 215/255.0, 0))
	set("custom_colors/font_color_hover", Color(1, 215/255.0, 0))
	sfx.play("cursor")

func _on_mapfilter_focus_exit():
	set("custom_colors/font_color", null)

func select(value):
	selected = value
	if (selected):
		icon.set_opacity(1)
	else:
		icon.set_opacity(0.5)

func _on_mapfilter_pressed():
	select(!selected)