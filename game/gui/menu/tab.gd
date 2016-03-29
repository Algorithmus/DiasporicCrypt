
extends TextureButton

signal tab_changed
signal unfocus_tab

var is_unfocused = false

var unselected_color
const ACTIVE_COLOR = Color(1, 0, 0)

func _ready():
	unselected_color = get_node("bg").get_modulate()
	set_process_input(true)

func _on_tab_focus_enter():
	get_node("bg").set_modulate(ACTIVE_COLOR)
	is_unfocused = false
	emit_signal("tab_changed", get_name())

func _on_tab_focus_exit():
	if (!is_unfocused):
		get_node("bg").set_modulate(unselected_color)
	
func _input(event):
	if (has_focus() && event.is_action_pressed("ui_down") && !event.is_echo()):
		is_unfocused = true
		emit_signal("unfocus_tab")