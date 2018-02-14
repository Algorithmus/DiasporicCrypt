extends Node

var display
var clock

func _ready():
	display = get_node("display")
	clock = get_tree().get_root().get_node("world/gameclock")
	set_process(true)

func _process(delta):
	display.set_text(clock.get("str_elapsed"))
