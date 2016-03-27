
extends TextureButton

signal tab_changed
signal unfocus_tab

var is_unfocused = false

func _ready():
	set_process_input(true)

func _on_tab_focus_enter():
	set_use_parent_material(false)
	is_unfocused = false
	emit_signal("tab_changed", get_name())

func _on_tab_focus_exit():
	if (!is_unfocused):
		set_use_parent_material(true)
	
func _input(event):
	if (has_focus() && event.is_action_pressed("ui_down") && !event.is_echo()):
		is_unfocused = true
		emit_signal("unfocus_tab")