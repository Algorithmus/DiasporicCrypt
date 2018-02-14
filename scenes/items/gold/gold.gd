
extends "res://scenes/items/BaseItem.gd"
export var value = 0
var isreward = false

func _ready():
	title = "gold"
	item = itemfactory_obj.items[title]
	item["value"] = value

func add_to_inventory():
	if (isreward):
		ProjectSettings.set("reward_taken", true)
	ProjectSettings.set("gold", ProjectSettings.get("gold") + value)
	return true
