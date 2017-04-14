extends Node

var animationplayer

func _ready():
	animationplayer = get_node("sprite/AnimationPlayer")
	animationplayer.play("idle")
	get_node("sprite/talk").hide()

func _on_focus_enter():
	animationplayer.play("run")

func _on_focus_exit():
	animationplayer.play("idle")
