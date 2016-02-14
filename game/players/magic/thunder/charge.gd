
extends Node2D

var boltball
var bolts

func _ready():
	set_fixed_process(true)
	boltball = get_node("Bolt")
	bolts = get_node("bolts")
	get_node("AnimationPlayer").play("runningbolts")

func _fixed_process(delta):
	pass

func change_scale(scale):
	set_scale(Vector2(scale, scale))