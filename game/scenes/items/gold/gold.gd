
extends "res://scenes/items/BaseItem.gd"
var value
var isreward = false

func _ready():
	title = "gold"
	item = itemfactory_obj.items[title]
	item["value"] = value

func add_to_inventory():
	if (isreward):
		Globals.set("reward_taken", true)
	Globals.set("gold", Globals.get("gold") + value)
	return true