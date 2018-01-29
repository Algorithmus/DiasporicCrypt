
extends Node

var shops = {}
var shopclass = preload("res://scenes/Shop.gd")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _init():
	var kaleva = shopclass.new()
	kaleva.name = "SHOP_KALEVA"
	kaleva.inventory = [{"type": "item", "id": "ITEM_POTION", "quantity": -1},
						{"type": "item", "id": "ITEM_POTION+", "quantity": -1},
						{"type": "item", "id": "ITEM_MANAPOTION", "quantity": -1},
						{"type": "item", "id": "ITEM_STRENGTHPOTION", "quantity": 3}]
						#{"type": "scroll", "id": "SCROLL_FIGHT", "quantity": 1},
						#{"type": "magic", "id": "MAGIC_THUNDER", "quantity": 1}]
	kaleva.sellrate = 0.5
	shops[kaleva.name] = kaleva

	var lucifer = shopclass.new()
	lucifer.name = "SHOP_LUCIFER"
	lucifer.inventory = [{"type": "magic", "id": "MAGIC_WIND", "quantity": 1},
						{"type": "item", "id": "ITEM_MYSTICPOTION", "quantity": 3}]
	lucifer.sellrate = 1
	shops[lucifer.name] = lucifer

	var gabriel = shopclass.new()
	gabriel.name = "SHOP_GABRIEL"
	gabriel.inventory = [{"type": "magic", "id": "MAGIC_HEX", "quantity": 1}]

	gabriel.sellrate = 0.25
	shops[gabriel.name] = gabriel

	var jalo = shopclass.new()
	jalo.name = "SHOP_JALO"
	jalo.inventory = [{"type": "magic", "id": "MAGIC_VOID", "quantity": 1}]

	jalo.sellrate = 0.1
	shops[jalo.name] = jalo

	var vance = shopclass.new()
	vance.name = "SHOP_VANCE"
	vance.inventory = [{"type": "item", "id": "ITEM_POTION", "quantity": -1},
						{"type": "item", "id": "ITEM_MANAPOTION", "quantity": -1},
						{"type": "item", "id": "ITEM_SHIELDPOTION", "quantity": 5}]
	vance.sellrate = 0.5
	shops[vance.name] = vance

	var pepper = shopclass.new()
	pepper.name = "SHOP_PEPPER"
	pepper.inventory = [{"type": "magic", "id": "MAGIC_VOID", "quantity": 1}]

	pepper.sellrate = 0.5
	shops[pepper.name] = pepper

	var goddess = shopclass.new()
	goddess.name = "SHOP_GODDESS"
	goddess.inventory = [{"type": "magic", "id": "MAGIC_SHIELD", "quantity": 1}]

	goddess.sellrate = 1.5
	shops[goddess.name] = goddess