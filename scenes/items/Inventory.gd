
extends Node

# Manage items player currently has

var inventory = {}
var player

func _ready():
	pass

func add_item(item, quantity):
	if (inventory.has(item.title)):
		if (inventory[item.title].quantity < 99):
			var old_item = inventory[item.title]
			old_item["quantity"] += quantity
			inventory[item.title] = old_item
			return true
		else:
			return false
	else:
		inventory[item.title] = {"item": item, "quantity": quantity}
		return true

func remove_item(item, quantity):
	if (inventory.has(item.title)):
		var old_item = inventory[item.title]
		old_item["quantity"] = max(old_item["quantity"] - quantity, 0)
		inventory[item.title] = old_item
		return old_item["quantity"]
	return 0

func clear_inventory():
	for item in inventory:
		inventory[item]["quantity"] = 0

func check_usable(item):
	if (item.effect == "hp"):
		return (player.get("current_hp") < player.get("hp"))
	elif (item.effect == "mp"):
		return (player.get("current_mp") < player.get("mp"))
	elif (item.effect == "unusable"):
		return false
	return true

func use_item(item):
	if (item.effect == "hp"):
		var hp = player.get("current_hp")
		var currenthp = min(hp + item.value, player.get("hp"))
		player.set("current_hp", currenthp)
	elif (item.effect == "mp"):
		var mp = player.get("current_mp")
		var currentmp = min(mp + item.value, player.get("mp"))
		player.set("current_mp", currentmp)
	elif (item.effect == "atk"):
		player.set("base_atk", player.get("base_atk") + item.value)
		player.set("bonus_atk", player.get("bonus_atk") + item.value)
	elif (item.effect == "def"):
		player.set("base_def", player.get("base_def") + item.value)
		player.set("bonus_def", player.get("bonus_def") + item.value)
	elif (item.effect == "mag"):
		player.set("base_mag", player.get("base_mag") + item.value)
		player.set("bonus_mag", player.get("bonus_mag") + item.value)
	elif (item.effect == "luck"):
		player.set("base_luck", player.get("base_luck") + item.value)
		player.set("bonus_luck", player.get("bonus_luck") + item.value)
	elif (item.effect == "maxhp"):
		player.set("base_hp", player.get("base_hp") + item.value)
		player.set("bonus_hp", player.get("bonus_hp") + item.value)
	elif (item.effect == "maxmp"):
		player.set("base_mp", player.get("base_mp") + item.value)
		player.set("bonus_mp", player.get("bonus_mp") + item.value)
	return remove_item(item, 1)

# only items with quantity > 0 appear in the list
func generate_list(type):
	var list = []
	for item in inventory:
		if (inventory[item]["quantity"] > 0 && inventory[item]["item"].type == type):
			list.append(inventory[item])
	return list
