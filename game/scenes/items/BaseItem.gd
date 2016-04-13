
extends Node2D

var taken = false
var sound
export var title = "ITEM_POTION"
var sfx = "potion"
var itemfactory = preload("res://scenes/items/ItemFactory.gd")
var itemfactory_obj
var item

func _fixed_process(delta):
	if (!taken):
		var collisions = get_node("item").get_overlapping_bodies()
		for i in collisions:
			if (i.get_name() == "player"):
				take_item(i)
	elif (!sound.is_active()):
		queue_free()

func take_item(i):
	if (add_to_inventory()):
		sound.play(sfx)
		taken = true
		get_tree().get_root().get_node("world/gui/CanvasLayer/items").display_item(title, item)
		remove_child(get_node("Sprite"))

func add_to_inventory():
	return Globals.get("inventory").add_item(item, 1)

func _ready():
	itemfactory_obj = itemfactory.new()
	item = itemfactory_obj.items[title]
	
	sound = get_node("sound")

func enter_screen():
	set_fixed_process(true)

func exit_screen():
	set_fixed_process(false)