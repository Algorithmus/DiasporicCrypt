
extends Control

var action
var data
var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	_on_choice_focus_exit()
	sfx = sfxclass.instance()
	add_child(sfx)

func _on_choice_focus_enter():
	get_node("icon").show()
	sfx.get_node("cursor").play()

func _on_choice_focus_exit():
	get_node("icon").hide()

