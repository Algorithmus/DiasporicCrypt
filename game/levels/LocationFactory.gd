
extends Node

var locations = {}
var locationclass = preload("res://levels/Location.gd")

func _init():
	var sandbox = locationclass.new()
	sandbox.node = "res://levels/sandbox/sandbox.tscn"
	sandbox.teleportto = Vector2(-112, 480)
	sandbox.id = "LVL_SANDBOX"
	sandbox.bgm = preload("res://levels/common/BGM3.ogg")
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
	start.bgm = preload("res://levels/common/BGM2.ogg")
	start.tiles = 22247
	locations[start.id] = start
	
	var colosseum1 = locationclass.new()
	colosseum1.node = "res://levels/sandbox/colosseum-prototype0-0.tscn"
	colosseum1.teleportto = Vector2(48, 128)
	colosseum1.id = "LVL_COLOSSEUM"
	colosseum1.bgm = preload("res://levels/common/BGM3.ogg")
	colosseum1.tiles = 4080
	locations[colosseum1.id] = colosseum1
	
	var lavacave = locationclass.new()
	lavacave.node = "res://levels/lavacave/0-0.tscn"
	lavacave.teleportto = Vector2(-16, 128)
	lavacave.id = "LVL_LAVACAVE"
	lavacave.bgm = preload("res://levels/common/BGM3.ogg")
	lavacave.tiles = 91812
	locations[lavacave.id] = lavacave
	
	var marblecastle = locationclass.new()
	marblecastle.node = "res://levels/marblecastle/0-0.tscn"
	marblecastle.teleportto = Vector2(-16, 128)
	marblecastle.id = "LVL_MARBLECASTLE"
	marblecastle.bgm = preload("res://levels/common/BGM1.ogg")
	marblecastle.tiles = 46918
	locations[marblecastle.id] = marblecastle
	
	var bergfortress = locationclass.new()
	bergfortress.node = "res://levels/bergfortress/0-0.tscn"
	bergfortress.teleportto = Vector2(-16, 128)
	bergfortress.id = "LVL_BERGFORTRESS"
	bergfortress.bgm = preload("res://levels/common/BGM1.ogg")
	bergfortress.tiles = 45421
	locations[bergfortress.id] = bergfortress
	
	var aquaduct = locationclass.new()
	aquaduct.node = "res://levels/aquaduct/0-0.tscn"
	aquaduct.teleportto = Vector2(-16, 128)
	aquaduct.id = "LVL_AQUADUCT"
	aquaduct.bgm = preload("res://levels/common/BGM2.ogg")
	aquaduct.tiles = 50442
	locations[aquaduct.id] = aquaduct
	
	var aquaduct2 = locationclass.new()
	aquaduct2.node = "res://levels/waterway/0-0.tscn"
	aquaduct2.teleportto = Vector2(-432, 256)
	aquaduct2.id = "LVL_AQUADUCT2"
	aquaduct2.bgm = preload("res://levels/common/BGM2.ogg")
	aquaduct2.tiles = 42234
	locations[aquaduct2.id] = aquaduct2
	
	var holyruins = locationclass.new()
	holyruins.node = "res://levels/holyruins/0-0.tscn"
	holyruins.teleportto = Vector2(-16, 128)
	holyruins.id = "LVL_HOLYRUINS"
	holyruins.bgm = preload("res://levels/common/BGM2.ogg")
	holyruins.tiles = 121446 - 117
	locations[holyruins.id] = holyruins
	
	var crypt = locationclass.new()
	crypt.node = "res://levels/crypt/0-0.tscn"
	crypt.teleportto = Vector2(-16, 128)
	crypt.id = "LVL_CAPECRYPT"
	crypt.bgm = preload("res://levels/common/BGM2.ogg")
	crypt.tiles = 100248
	locations[crypt.id] = crypt
	
	var springislandcastle = locationclass.new()
	springislandcastle.node = "res://levels/springislandcastle/0-0.tscn"
	springislandcastle.teleportto = Vector2(272, 192)
	springislandcastle.id = "LVL_SPRINGISLANDCASTLE"
	springislandcastle.bgm = preload("res://levels/common/BGM1.ogg")
	springislandcastle.tiles = 86623
	locations[springislandcastle.id] = springislandcastle
	
	var summerislandcastle = locationclass.new()
	summerislandcastle.node = "res://levels/summerislandcastle/0-0.tscn"
	summerislandcastle.teleportto = Vector2(-16, 320)
	summerislandcastle.id = "LVL_SUMMERISLANDCASTLE"
	summerislandcastle.bgm = preload("res://levels/common/BGM1.ogg")
	summerislandcastle.tiles = 84899
	locations[summerislandcastle.id] = summerislandcastle

	var winterislandcastle = locationclass.new()
	winterislandcastle.node = "res://levels/winterislandcastle/0-0.tscn"
	winterislandcastle.teleportto = Vector2(-208, 256)
	winterislandcastle.id = "LVL_WINTERISLANDCASTLE"
	winterislandcastle.bgm = preload("res://levels/common/BGM1.ogg")
	winterislandcastle.tiles = 91904
	locations[winterislandcastle.id] = winterislandcastle
	
	var cave = locationclass.new()
	cave.node = "res://levels/cave/0-0.tscn"
	cave.teleportto = Vector2(16, 32)
	cave.id = "LVL_CAVE"
	cave.bgm = preload("res://levels/common/BGM3.ogg")
	cave.tiles = 105364
	locations[cave.id] = cave
	
	var mausoleum = locationclass.new()
	mausoleum.node = "res://levels/mausoleum/0-0.tscn"
	mausoleum.teleportto = Vector2(336, 160)
	mausoleum.id = "LVL_MAUSOLEUM"
	mausoleum.bgm = preload("res://levels/common/BGM2.ogg")
	mausoleum.tiles = 90721
	locations[mausoleum.id] = mausoleum
	
	var dungeon = locationclass.new()
	dungeon.node = "res://levels/dungeon/0-0.tscn"
	dungeon.teleportto = Vector2(48, 128)
	dungeon.id = "LVL_DUNGEON"
	dungeon.bgm = preload("res://levels/common/BGM2.ogg")
	dungeon.tiles = 27592
	locations[dungeon.id] = dungeon

	var icecave = locationclass.new()
	icecave.node = "res://levels/icecave/0-0.tscn"
	icecave.teleportto = Vector2(16, 64)
	icecave.id = "LVL_ICECAVE"
	icecave.bgm = preload("res://levels/common/BGM3.ogg")
	icecave.tiles = 44320 - 300
	locations[icecave.id] = icecave
