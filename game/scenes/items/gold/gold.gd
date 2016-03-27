
extends "res://scenes/items/BaseItem.gd"
var value

func _ready():
	title = "gold"
	item = itemfactory_obj.items[title]
	item["value"] = value

func add_to_inventory():
	Globals.set("gold", Globals.get("gold") + value)