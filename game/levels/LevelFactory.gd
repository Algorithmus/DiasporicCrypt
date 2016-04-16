
extends Node

var levels = {}
var levelclass = preload("res://levels/Level.gd")

func _init():
	var sandbox = levelclass.new()
	sandbox.title = "LVL_SANDBOX"
	sandbox.type = "quest"
	sandbox.position = Vector2(160, 368)
	sandbox.node = "res://levels/sandbox/sandbox.tscn"
	sandbox.teleportto = Vector2(-122, 480)
	sandbox.description = "LVL_SANDBOX_DESCRIPTION"
	sandbox.mapid = "LVL_SANDBOX"
	levels[sandbox.title] = sandbox
	
	var forest1 = levelclass.new()
	forest1.title = "LVL_FOREST1"
	forest1.type = "bonus"
	forest1.position = Vector2(192, 160)
	forest1.node = "res://levels/sandbox/sandbox.tscn"
	forest1.teleportto = Vector2(-122, 480)
	forest1.description = "LVL_FOREST1_DESCRIPTION"
	forest1.mapid = "LVL_SANDBOX"
	levels[forest1.title] = forest1
	
	var forest2 = levelclass.new()
	forest2.title = "LVL_FOREST2"
	forest2.type = "bonus"
	forest2.position = Vector2(192, 160)
	forest2.node = "res://levels/sandbox/sandbox.tscn"
	forest2.teleportto = Vector2(-122, 480)
	forest2.description = "LVL_FOREST2_DESCRIPTION"
	forest2.mapid = "LVL_SANDBOX"
	levels[forest2.title] = forest2
	
	var lavacave = levelclass.new()
	lavacave.title = "LVL_LAVACAVE"
	lavacave.type = "boss"
	lavacave.position = Vector2(432, 352)
	lavacave.node = "res://levels/sandbox/sandbox.tscn"
	lavacave.teleportto = Vector2(-122, 480)
	lavacave.description = "LVL_LAVACAVE_DESCRIPTION"
	lavacave.reward = 10000
	lavacave.mapid = "LVL_SANDBOX"
	levels[lavacave.title] = lavacave
	
	var manor = levelclass.new()
	manor.title = "LVL_MANOR"
	manor.type = "quest"
	manor.position = Vector2(436, 95)
	manor.node = "res://levels/sandbox/sandbox.tscn"
	manor.teleportto = Vector2(-122, 480)
	manor.description = "LVL_MANOR_DESCRIPTION"
	manor.mapid = "LVL_SANDBOX"
	manor.reward = 20000
	levels[manor.title] = manor
	
	var start = levelclass.new()
	start.title = "LVL_START"
	start.type = "quest"
	start.position = Vector2(314, 133)
	start.node = "res://levels/sandbox/sandbox.tscn"
	start.teleportto = Vector2(-122, 480)
	start.description = "LVL_START_DESCRIPTION"
	start.reward = 100
	start.mapid = "LVL_SANDBOX"
	levels[start.title] = start
	
	var colosseum1 = levelclass.new()
	colosseum1.title = "LVL_COLOSSEUM1"
	colosseum1.type = "colosseum"
	colosseum1.position = Vector2(256, 240)
	colosseum1.node = "res://levels/sandbox/colosseum-prototype0-0.tscn"
	colosseum1.teleportto = Vector2(48, 128)
	colosseum1.description = "LVL_COLOSSEUM1_DESCRIPTION"
	colosseum1.reward = 50000
	colosseum1.mapid = "LVL_COLOSSEUM"
	levels[colosseum1.title] = colosseum1
	
	var colosseum2 = levelclass.new()
	colosseum2.title = "LVL_COLOSSEUM2"
	colosseum2.type = "colosseum"
	colosseum2.position = Vector2(256, 240)
	colosseum2.node = "res://levels/sandbox/colosseum-prototype0-0.tscn"
	colosseum2.teleportto = Vector2(48, 128)
	colosseum2.description = "LVL_COLOSSEUM2_DESCRIPTION"
	colosseum2.mapid = "LVL_COLOSSEUM"
	colosseum2.reward = 100000
	levels[colosseum2.title] = colosseum2