
extends Node

# Manage items player currently has

var inventory = {}
var player

func _ready():
	pass

func add_item(item, quantity):
	if (inventory.has(item.title)):
		var old_item = inventory[item.title]
		old_item["quantity"] += quantity
		inventory[item.title] = old_item
	else:
		inventory[item.title] = {"item": item, "quantity": quantity}

func remove_item(item, quantity):
	if (inventory.has(item.title)):
		var old_item = inventory[item.title]
		old_item["quantity"] = max(old_item["quantity"] - quantity, 0)
		inventory[item.title] = old_item
		return old_item["quantity"]
	return 0

func clear_inventory():
	for item in inventory:
		item["quantity"] = 0

func check_usable(item):
	if (item.effect == "hp"):
		return (player.get("current_hp") < player.get("hp"))
	if (item.effect == "unusable"):
		return false
	return true

func use_item(item):
	if (item.effect == "hp"):
		var hp = player.get("current_hp")
		var currenthp = min(hp + item.value, player.get("hp"))
		player.set("current_hp", currenthp)
	return remove_item(item, 1)

# only items with quantity > 0 appear in the list
func generate_list(type):
	var list = []
	for item in inventory:
		if (inventory[item]["quantity"] > 0 && inventory[item]["item"].type == type):
			list.append(inventory[item])
	return list