
extends "res://scenes/items/BaseItem.gd"
var value
var isreward = false
export var spell_id = "hex"
var spell

func _ready():
	var all_spells = Globals.get("magic_spells")
	for i in range(0, all_spells.size()):
		if (all_spells[i].id == spell_id):
			spell = all_spells[i]
	title = "MAGIC_" + spell_id.to_upper()
	item = itemfactory_obj.items[title]
	item["value"] = value
	var magic_spells = Globals.get("available_spells")
	for i in range(0, magic_spells.size()):
		if (magic_spells[i].id == spell_id):
			queue_free()

func add_to_inventory():
	Globals.get("available_spells").append(spell)
	return true
