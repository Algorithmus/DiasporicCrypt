
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