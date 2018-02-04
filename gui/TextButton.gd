
extends Node2D

export var default_focus = false

func _ready():
	if (default_focus):
		get_node("button").grab_focus()

func _on_button_focus_enter():
	#TOOD - play sounds properly
	#get_node("SamplePlayer").play("cursor")
	set_scale(Vector2(1.5, 1.5))

func _on_button_focus_exit():
	set_scale(Vector2(1, 1))
