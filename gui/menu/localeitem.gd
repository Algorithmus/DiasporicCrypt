
extends "res://gui/dialogue/choice.gd"

func _on_choice_focus_enter():
	._on_choice_focus_enter()
	get_node("icon1").show()

func _on_choice_focus_exit():
	._on_choice_focus_exit()
	get_node("icon1").hide()

