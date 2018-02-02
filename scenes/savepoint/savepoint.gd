extends Node

var saveclass = preload("res://gui/menu/loadsave.tscn")
var savepos
export var savelocation = "LVL_CATACOMB"

func _ready():
	var player = ProjectSettings.get("player")
	savepos = Vector2(get_global_position().x, get_global_position().y - 30)
	if (player == null):
		set_physics_process(true)
	check_sprite()

func _physics_process(delta):
	check_sprite()

func check_sprite():
	var player = ProjectSettings.get("player")
	if (player == "adela"):
		get_node("statue").set_texture(preload("res://scenes/savepoint/cat.png"))
	else:
		get_node("statue").set_texture(preload("res://scenes/savepoint/bat.png"))
	if (player != null):
		set_physics_process(false)

func start(pos):
	var save = saveclass.instance()
	save.set_position(Vector2(32, 20))
	save.set("savepos", savepos)
	save.set("savelocation", savelocation)
	#hide_dialog()
	get_tree().set_pause(true)
	var pause = get_tree().get_root().get_node("world/gui/CanvasLayer/pause")
	pause.get_node("menu").hide()
	pause.add_child(save)
	pause.show()

func enter_screen():
	#set_physics_process(true)
	pass

func exit_screen():
	#set_physics_process(false)
	pass
