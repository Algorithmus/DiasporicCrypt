
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
	potion.cost = 100
	items[potion.title] = potion
	
	var potionplus = itemclass.new()
	potionplus.title = "ITEM_POTION+"
	potionplus.description = "ITEM_POTION+_DESCRIPTION"
	potionplus.type = "item"
	potionplus.value = 500
	potionplus.image = "res://scenes/items/potion/potionplus.png"
	potionplus.effect = "hp"
	potionplus.cost = 1000
	items[potionplus.title] = potionplus

	var potionplusplus = itemclass.new()
	potionplusplus.title = "ITEM_POTION++"
	potionplusplus.description = "ITEM_POTION++_DESCRIPTION"
	potionplusplus.type = "item"
	potionplusplus.value = 2000
	potionplusplus.image = "res://scenes/items/potion/potionplusplus.png"
	potionplusplus.effect = "hp"
	potionplusplus.cost = 3000
	items[potionplusplus.title] = potionplusplus

	var manapotion = itemclass.new()
	manapotion.title = "ITEM_MANAPOTION"
	manapotion.description = "ITEM_MANAPOTION_DESCRIPTION"
	manapotion.type = "item"
	manapotion.value = 20
	manapotion.image = "res://scenes/items/potion/manapotion.png"
	manapotion.effect = "mp"
	manapotion.cost = 500
	items[manapotion.title] = manapotion

	var manapotionplus = itemclass.new()
	manapotionplus.title = "ITEM_MANAPOTION+"
	manapotionplus.description = "ITEM_MANAPOTION+_DESCRIPTION"
	manapotionplus.type = "item"
	manapotionplus.value = 50
	manapotionplus.image = "res://scenes/items/potion/manapotionplus.png"
	manapotionplus.effect = "mp"
	manapotionplus.cost = 2000
	items[manapotionplus.title] = manapotionplus

	var manapotionplusplus = itemclass.new()
	manapotionplusplus.title = "ITEM_MANAPOTION++"
	manapotionplusplus.description = "ITEM_MANAPOTION++_DESCRIPTION"
	manapotionplusplus.type = "item"
	manapotionplusplus.value = 250
	manapotionplusplus.image = "res://scenes/items/potion/manapotionplusplus.png"
	manapotionplusplus.effect = "mp"
	manapotionplusplus.cost = 5000
	items[manapotionplusplus.title] = manapotionplusplus

	var strengthpotion = itemclass.new()
	strengthpotion.title = "ITEM_STRENGTHPOTION"
	strengthpotion.description = "ITEM_STRENGTHPOTION_DESCRIPTION"
	strengthpotion.type = "item"
	strengthpotion.value = 1
	strengthpotion.image = "res://scenes/items/potion/strengthpotion.png"
	strengthpotion.effect = "atk"
	strengthpotion.cost = 10000
	items[strengthpotion.title] = strengthpotion

	var shieldpotion = itemclass.new()
	shieldpotion.title = "ITEM_SHIELDPOTION"
	shieldpotion.description = "ITEM_SHIELDPOTION_DESCRIPTION"
	shieldpotion.type = "item"
	shieldpotion.value = 1
	shieldpotion.image = "res://scenes/items/potion/shieldpotion.png"
	shieldpotion.effect = "def"
	shieldpotion.cost = 10000
	items[shieldpotion.title] = shieldpotion

	var charmpotion = itemclass.new()
	charmpotion.title = "ITEM_CHARMPOTION"
	charmpotion.description = "ITEM_CHARMPOTION_DESCRIPTION"
	charmpotion.type = "item"
	charmpotion.value = 1
	charmpotion.image = "res://scenes/items/potion/charmpotion.png"
	charmpotion.effect = "luck"
	charmpotion.cost = 25000
	items[charmpotion.title] = charmpotion

	var mysticpotion = itemclass.new()
	mysticpotion.title = "ITEM_MYSTICPOTION"
	mysticpotion.description = "ITEM_MYSTICPOTION_DESCRIPTION"
	mysticpotion.type = "item"
	mysticpotion.value = 1
	mysticpotion.image = "res://scenes/items/potion/mysticpotion.png"
	mysticpotion.effect = "mag"
	mysticpotion.cost = 10000
	items[mysticpotion.title] = mysticpotion

	var scroll = scrollclass.new()
	scroll.title = "SCROLL_START"
	scroll.display = "SCROLL_START_TITLE"
	scroll.content = "SCROLL_START_DESCRIPTION"
	scroll.description = "SCROLL_START_SHORT"
	scroll.order = 0
	items[scroll.title] = scroll
	
	var scrollfight = scrollclass.new()
	scrollfight.title = "SCROLL_FIGHT"
	scrollfight.display = "SCROLL_FIGHT_TITLE"
	scrollfight.content = "SCROLL_FIGHT_DESCRIPTION"
	scrollfight.description = "SCROLL_FIGHT_SHORT"
	scrollfight.order = 1
	scrollfight.cost = 100
	items[scrollfight.title] = scrollfight
	
	var scrollmagic = scrollclass.new()
	scrollmagic.title = "SCROLL_MAGIC"
	scrollmagic.display = "SCROLL_MAGIC_TITLE"
	scrollmagic.content = "SCROLL_MAGIC_DESCRIPTION"
	scrollmagic.description = "SCROLL_MAGIC_SHORT"
	scrollmagic.order = 2
	items[scrollmagic.title] = scrollmagic
	
	var thunder = itemclass.new()
	thunder.title = "MAGIC_THUNDER"
	thunder.description = "MAGIC_THUNDER_SHORT"
	thunder.type = "magic"
	thunder.image = "res://players/magic/thunder/icon.png"
	thunder.value = "thunder"
	thunder.cost = 100
	items[thunder.title] = thunder
	
	var hex = itemclass.new()
	hex.title = "MAGIC_HEX"
	hex.description = "MAGIC_HEX_SHORT"
	hex.type = "magic"
	hex.image = "res://players/magic/hex/icon.png"
	hex.value = "hex"
	hex.cost = 50000
	items[hex.title] = hex