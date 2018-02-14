
extends "res://scenes/items/BaseItem.gd"

func _ready():
	pass

func add_to_inventory():
	ProjectSettings.get("scrolls")[item.title] = item
	return true
