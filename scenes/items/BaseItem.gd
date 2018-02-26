
extends Node2D

var taken = false
var sound
export var title = "ITEM_POTION"
export var isgoal = false
var sfx = "potion"
var itemfactory = preload("res://scenes/items/ItemFactory.gd")
var itemfactory_obj
var item
var player

func _physics_process(delta):
	if (!taken && get_node("item") != null):
		var collisions = get_node("item").get_overlapping_bodies()
		for i in collisions:
			if (i.get_name() == "player"):
				take_item(i)
	elif (!sound.get_node(sfx).playing):
		queue_free()

func take_item(i):
	if (add_to_inventory()):
		sound.get_node(sfx).play()
		taken = true
		get_tree().get_root().get_node("world/gui/CanvasLayer/items").display_item(title, item)
		if (isgoal):
			ProjectSettings.set("current_quest_complete", true)
			var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
			level.complete = true
			get_tree().get_root().get_node("world").check_available_levels()
			ProjectSettings.get("levels")[ProjectSettings.get("current_level")] = level
			var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
			level_display.get_node("title").set_text("KEY_COMPLETE")
			level_display.get_node("AnimationPlayer").play("quest")
		remove_child(get_node("Sprite"))
		remove_child(get_node("item"))
		player.remove_from_blacklist(get_node("item"))

func add_to_inventory():
	return ProjectSettings.get("inventory").add_item(item, 1)

func _ready():
	itemfactory_obj = itemfactory.new()
	item = itemfactory_obj.items[title]
	
	sound = get_node("sound")
	player = get_tree().get_root().get_node("world/playercontainer/player")
	player.add_to_blacklist(get_node("item"))
	set_physics_process(false)

func enter_screen():
	set_physics_process(true)

func exit_screen():
	set_physics_process(false)
