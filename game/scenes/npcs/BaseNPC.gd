
extends Node2D

export var dialogues = []
var direction
var interacting = false

func _ready():
	set_fixed_process(true)
	direction = get_node("Sprite").get_scale().x

func _fixed_process(delta):
	if (interacting):
		interacting = false
		get_node("Sprite").set_scale(Vector2(direction, 1))

func start(pos):
	print("start talking")
	get_tree().get_root().get_node("world/gui/CanvasLayer/dialogue").start(dialogues)
	if (get_global_pos().x * direction > pos.x * direction):
		get_node("Sprite").set_scale(Vector2(-direction, 1))
	interacting = true