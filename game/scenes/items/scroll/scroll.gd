
extends "res://scenes/items/BaseItem.gd"

func _ready():
	pass

func add_to_inventory():
	Globals.get("scrolls")[item.title] = item