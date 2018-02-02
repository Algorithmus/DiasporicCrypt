extends "res://gui/dialogue/choice.gd"

# prefer to obtain list dynamically, but Godot doesn't have this feature yet...
var list = ["en", "de"]
var index = 0

signal language_selected
signal translation_changed

func _ready():
	translate()
	# obtain language from OS if no global config language is set
	var defaultLocale = TranslationServer.get_locale()
	var size = list.size()
	for i in range(0, size):
		if (list[i] == defaultLocale):
			index = i
			break
	set_process_input(false)
			
func translate():
	set_text(tr("KEY_LANGUAGE") + ":")
	get_node("locale").set_text(tr("KEY_LOCALE"))

func select_language():
	get_node("locale").grab_focus()
	set_process_input(true)

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		var old_index = index
		if (event.is_action_pressed("ui_left")):
			index -= 1
			if (index < 0):
				index = list.size() - 1
		elif (event.is_action_pressed("ui_right")):
			index += 1
			if (index >= list.size()):
				index = 0

		if (old_index != index):
			TranslationServer.set_locale(list[index])
			emit_signal("translation_changed")
			translate()

func confirm_selection():
	set_process_input(false)
	grab_focus()
	emit_signal("language_selected")

