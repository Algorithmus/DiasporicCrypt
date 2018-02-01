
extends Node2D

export var dialogues = [[-1, "CHARACTER_NPC", "DIAG_DEFAULT", null, null]]
export var static_direction = false
var direction
var interacting = false

func _ready():
	direction = get_node("Sprite").get_scale().x

func _physics_process(delta):
	if (interacting):
		interacting = false
		get_node("Sprite").set_scale(Vector2(direction, 1))

func start(pos):
	get_tree().get_root().get_node("world/gui/CanvasLayer/dialogue").start(dialogues)
	if (!static_direction && get_global_position().x * direction > pos.x * direction):
		get_node("Sprite").set_scale(Vector2(-direction, 1))
	interacting = true

func enter_screen():
	set_physics_process(true)

func exit_screen():
	set_physics_process(false)
