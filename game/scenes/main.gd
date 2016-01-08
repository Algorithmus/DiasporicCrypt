
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var original_size
var pause
var root
var is_paused = false
var music

func _ready():
	# Initialization here
	root = get_tree().get_root()
	original_size = root.get_rect().size
	root.connect("size_changed", self, "_on_resolution_changed")
	pause = get_node("gui/CanvasLayer/pause")
	music = get_node("music")
	pause.hide()
	set_process_input(true)

func _on_resolution_changed():
	var new_size = root.get_rect().size
	pause.get_node("shield").set_scale(Vector2(new_size.x/original_size.x, new_size.y/original_size.y))
	pass
	
func _input(event):
	if (event.is_action("ui_pause") && event.is_pressed() && !event.is_echo()):
		if (is_paused):
			pause.hide()
			is_paused = false
			music.set_volume_db(0)
		else:
			pause.show()
			is_paused = true
			music.set_volume_db(-20)
		get_tree().set_pause(is_paused)