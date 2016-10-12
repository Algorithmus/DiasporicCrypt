
extends "res://scenes/items/BaseItem.gd"
var value
var isreward = false

func _ready():
	title = "MAGIC_HEX"
	item = itemfactory_obj.items[title]
	item["value"] = value
	var magic_spells = Globals.get("available_spells")
	var spell
	for i in range(0, magic_spells.size()):
		if (magic_spells[i].id == "hex"):
			queue_free()

func add_to_inventory():
	var magic_spells = Globals.get("magic_spells")
	var spell
	for i in range(0, magic_spells.size()):
		if (magic_spells[i].id == "hex"):
			spell = magic_spells[i]
	Globals.get("available_spells").append(spell)
	return true