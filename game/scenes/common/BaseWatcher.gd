
# Watch current room for certain conditions (usually the existence of certain objects in a group)
# If there are no more of those objects left, a reward item is revealed.

# Eg, kill all enemies in a room to make a platform appear.

extends Node

export var reward = ""
export var target_container = ""
export var watch_class = ""
export var invert = false

var target
var reward_obj
var reward_container
var tilemap
var class_obj

func _ready():
	class_obj = load(watch_class)
	tilemap = get_parent()
	target = tilemap.get_node(target_container)
	reward_obj = tilemap.get_node(reward)
	reward_container = reward_obj.get_parent()
	if (!invert):
		reward_container.remove_child(reward_obj)
	set_fixed_process(true)
	
func _fixed_process(delta):
	var cleared = true
	for watch_obj in target.get_children():
		if (watch_obj extends class_obj):
			cleared = false
	if (cleared):
		if (invert):
			reward_container.remove_child(reward_obj)
		else:
			reward_container.add_child(reward_obj)
		set_fixed_process(false)