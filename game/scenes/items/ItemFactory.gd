
extends Node

# Factory for all items in the game

var items = {}
var itemclass = preload("res://scenes/items/BasicItem.gd")
var scrollclass = preload("res://scenes/items/scroll/ScrollItem.gd")

func _init():
	items["exp"] = {"type": "exp"}
	items["gold"] = {"type": "gold"}
	
	var potion = itemclass.new()
	potion.title = "ITEM_POTION"
	potion.description = "ITEM_POTION_DESCRIPTION"
	potion.type = "item"
	potion.value = 100
	potion.image = "res://scenes/items/potion/potion.png"
	potion.effect = "hp"
	items[potion.title] = potion
	
	var potionplus = itemclass.new()
	potionplus.title = "ITEM_POTION+"
	potionplus.description = "ITEM_POTION+_DESCRIPTION"
	potionplus.type = "item"
	potionplus.value = 500
	potionplus.image = "res://scenes/items/potion/potionplus.png"
	potionplus.effect = "hp"
	items[potionplus.title] = potionplus
	
	var scroll = scrollclass.new()
	scroll.title = "SCROLL_START"
	scroll.display = "SCROLL_START_TITLE"
	scroll.content = "SCROLL_START_DESCRIPTION"
	scroll.order = 0
	items[scroll.title] = scroll
	
	var scrollfight = scrollclass.new()
	scrollfight.title = "SCROLL_FIGHT"
	scrollfight.display = "SCROLL_FIGHT_TITLE"
	scrollfight.content = "SCROLL_FIGHT_DESCRIPTION"
	scrollfight.order = 1
	items[scrollfight.title] = scrollfight
	
	var scrollmagic = scrollclass.new()
	scrollmagic.title = "SCROLL_MAGIC"
	scrollmagic.display = "SCROLL_MAGIC_TITLE"
	scrollmagic.content = "SCROLL_MAGIC_DESCRIPTION"
	scrollmagic.order = 2
	items[scrollmagic.title] = scrollmagic