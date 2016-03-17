
extends Node2D

var taken = false
var sound
export var title = "ITEM_POTION"
var type = "item"
var sfx = "potion"

func _fixed_process(delta):
	if (!taken):
		var collisions = get_node("item").get_overlapping_bodies()
		for i in collisions:
			if (i.get_name() == "player"):
				take_item(i)
	elif (!sound.is_active()):
		queue_free()

func take_item(i):
	sound.play(sfx)
	taken = true
	get_tree().get_root().get_node("world/gui/CanvasLayer/items").display_item(title, type)
	remove_child(get_node("Sprite"))

func _ready():
	# Initialization here
	sound = get_node("sound")
	
	set_fixed_process(true)