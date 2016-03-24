
extends ToolButton

var action
var data

func _ready():
	_on_choice_focus_exit()

func _on_choice_focus_enter():
	get_node("icon").show()

func _on_choice_focus_exit():
	get_node("icon").hide()
