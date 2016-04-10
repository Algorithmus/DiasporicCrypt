
extends ToolButton

var animation

func _ready():
	animation = get_node("AnimationPlayer")

func _on_pin_focus_enter():
	animation.play("active")

func _on_pin_focus_exit():
	animation.play("inactive")
