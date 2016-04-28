
extends Node

var levels = {}
var levelclass = preload("res://levels/Level.gd")
var locationfactory = preload("res://levels/LocationFactory.gd").new()

func _init():
	var sandbox = levelclass.new()
	sandbox.title = "LVL_SANDBOX"
	sandbox.type = "quest"
	sandbox.position = Vector2(160, 368)
	sandbox.description = "LVL_SANDBOX_DESCRIPTION"
	sandbox.location = locationfactory.locations["LVL_SANDBOX"]
	levels[sandbox.title] = sandbox
	
	var forest1 = levelclass.new()
	forest1.title = "LVL_FOREST1"
	forest1.type = "bonus"
	forest1.position = Vector2(192, 160)
	forest1.description = "LVL_FOREST1_DESCRIPTION"
	forest1.location = locationfactory.locations["LVL_NOCTURNFOREST"]
	forest1.time = 6000
	forest1.mincounter = 5
	levels[forest1.title] = forest1
	
	var forest2 = levelclass.new()
	forest2.title = "LVL_FOREST2"
	forest2.type = "bonus"
	forest2.position = Vector2(192, 160)
	forest2.description = "LVL_FOREST2_DESCRIPTION"
	forest2.location = locationfactory.locations["LVL_SANDBOX"]
	levels[forest2.title] = forest2
	
	var lavacave = levelclass.new()
	lavacave.title = "LVL_LAVACAVE"
	lavacave.type = "boss"
	lavacave.position = Vector2(432, 352)
	lavacave.description = "LVL_LAVACAVE_DESCRIPTION"
	lavacave.reward = 10000
	lavacave.location = locationfactory.locations["LVL_LAVACAVE"]
	levels[lavacave.title] = lavacave
	
	var manor = levelclass.new()
	manor.title = "LVL_MANOR"
	manor.type = "quest"
	manor.position = Vector2(436, 95)
	manor.description = "LVL_MANOR_DESCRIPTION"
	manor.location = locationfactory.locations["LVL_SANDBOX"]
	manor.reward = 20000
	levels[manor.title] = manor
	
	var start = levelclass.new()
	start.title = "LVL_START"
	start.type = "quest"
	start.position = Vector2(314, 133)
	start.description = "LVL_START_DESCRIPTION"
	start.reward = 100
	start.item = "ITEM_AMULET"
	start.location = locationfactory.locations["LVL_START"]
	levels[start.title] = start
	
	var colosseum1 = levelclass.new()
	colosseum1.title = "LVL_COLOSSEUM1"
	colosseum1.type = "colosseum"
	colosseum1.position = Vector2(256, 240)
	colosseum1.description = "LVL_COLOSSEUM1_DESCRIPTION"
	colosseum1.reward = 50000
	colosseum1.location = locationfactory.locations["LVL_COLOSSEUM"]
	colosseum1.waves = [preload("res://scenes/colosseum/waves/wave0-0.tscn"), preload("res://scenes/colosseum/waves/wave0-1.tscn"), preload("res://scenes/colosseum/waves/wave0-2.tscn")]
	levels[colosseum1.title] = colosseum1
	
	var colosseum2 = levelclass.new()
	colosseum2.title = "LVL_COLOSSEUM2"
	colosseum2.type = "colosseum"
	colosseum2.position = Vector2(256, 240)
	colosseum2.description = "LVL_COLOSSEUM2_DESCRIPTION"
	colosseum2.location = "LVL_COLOSSEUM"
	colosseum2.reward = 100000
	levels[colosseum2.title] = colosseum2