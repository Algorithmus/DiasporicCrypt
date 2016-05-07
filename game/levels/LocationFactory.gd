
extends Node

var locations = {}
var locationclass = preload("res://levels/Location.gd")

func _init():
	var sandbox = locationclass.new()
	sandbox.node = "res://levels/sandbox/sandbox.tscn"
	sandbox.teleportto = Vector2(-112, 480)
	sandbox.id = "LVL_SANDBOX"
	sandbox.bgm = preload("res://levels/common/BGM1.ogg")
	locations[sandbox.id] = sandbox
	
	var forest1 = locationclass.new()
	forest1.node = "res://levels/forest/nocturn.tscn"
	forest1.teleportto = Vector2(16, 128)
	forest1.id = "LVL_NOCTURNFOREST"
	forest1.bgm = preload("res://levels/forest/BGM1.ogg")
	locations[forest1.id] = forest1
	
	var start = locationclass.new()
	start.node = "res://levels/roomoftrials/0-0.tscn"
	start.teleportto = Vector2(336, 128)
	start.id = "LVL_START"
	start.bgm = preload("res://levels/common/BGM1.ogg")
	locations[start.id] = start
	
	var colosseum1 = locationclass.new()
	colosseum1.node = "res://levels/sandbox/colosseum-prototype0-0.tscn"
	colosseum1.teleportto = Vector2(48, 128)
	colosseum1.id = "LVL_COLOSSEUM"
	colosseum1.bgm = preload("res://levels/common/BGM1.ogg")
	locations[colosseum1.id] = colosseum1
	
	var lavacave = locationclass.new()
	lavacave.node = "res://levels/lavacave/0-0.tscn"
	lavacave.teleportto = Vector2(-16, 128)
	lavacave.id = "LVL_LAVACAVE"
	lavacave.bgm = preload("res://levels/common/BGM1.ogg")
	locations[lavacave.id] = lavacave
	
	var marblecastle = locationclass.new()
	marblecastle.node = "res://levels/marblecastle/0-0.tscn"
	marblecastle.teleportto = Vector2(-16, 128)
	marblecastle.id = "LVL_MARBLECASTLE"
	marblecastle.bgm = preload("res://levels/common/BGM1.ogg")
	locations[marblecastle.id] = marblecastle