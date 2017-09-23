
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
	sandbox.item = "ITEM_AMULET"
	levels[sandbox.title] = sandbox
	
	var springislandcastle = levelclass.new()
	springislandcastle.title = "LVL_SPRINGISLANDCASTLE"
	springislandcastle.type = "quest"
	springislandcastle.position = Vector2(463, 26)
	springislandcastle.description = "LVL_SPRINGISLANDCASTLE_DESCRIPTION"
	springislandcastle.reward = 10000
	springislandcastle.item = "ITEM_STYXMIRROR"
	springislandcastle.require = ["LVL_CAPECRYPT"]
	springislandcastle.location = locationfactory.locations["LVL_SPRINGISLANDCASTLE"]
	levels[springislandcastle.title] = springislandcastle
	
	var summerislandcastle = levelclass.new()
	summerislandcastle.title = "LVL_SUMMERISLANDCASTLE"
	summerislandcastle.type = "quest"
	summerislandcastle.position = Vector2(679, 328)
	summerislandcastle.description = "LVL_SUMMERISLANDCASTLE_DESCRIPTION"
	summerislandcastle.reward = 10000
	summerislandcastle.item = "ITEM_STYXBROOCH"
	summerislandcastle.require = ["LVL_HOLYRUINS", "LVL_MAUSOLEUM"]
	summerislandcastle.location = locationfactory.locations["LVL_SUMMERISLANDCASTLE"]
	levels[summerislandcastle.title] = summerislandcastle

	var winterislandcastle = levelclass.new()
	winterislandcastle.title = "LVL_WINTERISLANDCASTLE"
	winterislandcastle.type = "quest"
	winterislandcastle.position = Vector2(195, 194)
	winterislandcastle.description = "LVL_WINTERISLANDCASTLE_DESCRIPTION"
	winterislandcastle.reward = 10000
	winterislandcastle.item = "ITEM_STYXTOME"
	winterislandcastle.require = ["LVL_LAVACAVE"]
	winterislandcastle.location = locationfactory.locations["LVL_WINTERISLANDCASTLE"]
	levels[winterislandcastle.title] = winterislandcastle
	
	var mausoleum = levelclass.new()
	mausoleum.title = "LVL_MAUSOLEUM"
	mausoleum.type = "quest"
	mausoleum.position = Vector2(288, 288)
	mausoleum.description = "LVL_MAUSOLEUM_DESCRIPTION"
	mausoleum.reward = 4000
	mausoleum.item = "ITEM_STYXINSCRIPTION"
	mausoleum.require = ["LVL_ICECAVE", "LVL_AQUADUCT"]
	mausoleum.location = locationfactory.locations["LVL_MAUSOLEUM"]
	levels[mausoleum.title] = mausoleum
	
	var cave = levelclass.new()
	cave.title = "LVL_CAVE"
	cave.type = "quest"
	cave.position = Vector2(424, 73)
	cave.description = "LVL_CAVE_DESCRIPTION"
	cave.reward = 4000
	cave.item = "ITEM_STYXCHALICE"
	cave.require = ["LVL_DUNGEON", "LVL_BERGFORTRESS"]
	cave.location = locationfactory.locations["LVL_CAVE"]
	levels[cave.title] = cave
	
	var forest1 = levelclass.new()
	forest1.title = "LVL_FOREST1"
	forest1.type = "bonus"
	forest1.position = Vector2(241, 297)
	forest1.description = "LVL_FOREST1_DESCRIPTION"
	forest1.location = locationfactory.locations["LVL_NOCTURNFOREST"]
	forest1.time = 6000
	forest1.mincounter = 5
	forest1.require = [["LVL_DUNGEON", "LVL_ICECAVE"]]
	levels[forest1.title] = forest1
	
	var forest2 = levelclass.new()
	forest2.title = "LVL_FOREST2"
	forest2.type = "bonus"
	forest2.position = Vector2(669, 238)
	forest2.description = "LVL_FOREST2_DESCRIPTION"
	forest2.location = locationfactory.locations["LVL_SANDBOX"]
	forest2.mincounter = 10
	levels[forest2.title] = forest2
	
	var lavacave = levelclass.new()
	lavacave.title = "LVL_LAVACAVE"
	lavacave.type = "boss"
	lavacave.position = Vector2(347, 555)
	lavacave.description = "LVL_LAVACAVE_DESCRIPTION"
	lavacave.reward = 10000
	lavacave.require = ["LVL_MANOR", "LVL_CAVE"]
	lavacave.location = locationfactory.locations["LVL_LAVACAVE"]
	levels[lavacave.title] = lavacave
	
	var bergfortress = levelclass.new()
	bergfortress.title = "LVL_BERGFORTRESS"
	bergfortress.type = "boss"
	bergfortress.position = Vector2(259, 495)
	bergfortress.description = "LVL_BERGFORTRESS_DESCRIPTION"
	bergfortress.reward = 5000
	bergfortress.require = ["LVL_START"]
	bergfortress.character = "friederich"
	bergfortress.location = locationfactory.locations["LVL_BERGFORTRESS"]
	levels[bergfortress.title] = bergfortress
	
	var aquaduct = levelclass.new()
	aquaduct.title = "LVL_AQUADUCT"
	aquaduct.type = "boss"
	aquaduct.position = Vector2(131, 207)
	aquaduct.description = "LVL_AQUADUCT_DESCRIPTION"
	aquaduct.reward = 8000
	aquaduct.require = ["LVL_START"]
	aquaduct.character = "adela"
	aquaduct.location = locationfactory.locations["LVL_AQUADUCT"]
	levels[aquaduct.title] = aquaduct
	
	var aquaduct2 = levelclass.new()
	aquaduct2.title = "LVL_AQUADUCT2"
	aquaduct2.type = "quest"
	aquaduct2.position = Vector2(614, 380)
	aquaduct2.description = "LVL_AQUADUCT2_DESCRIPTION"
	aquaduct2.reward = 10000
	aquaduct2.require = ["LVL_MANOR", "LVL_CAVE"]
	aquaduct2.item = "ITEM_STYXCOIN"
	aquaduct2.location = locationfactory.locations["LVL_AQUADUCT2"]
	levels[aquaduct2.title] = aquaduct2

	var dungeon = levelclass.new()
	dungeon.title = "LVL_DUNGEON"
	dungeon.type = "quest"
	dungeon.position = Vector2(362, 389)
	dungeon.description = "LVL_DUNGEON_DESCRIPTION"
	dungeon.reward = 4000
	dungeon.item = "ITEM_STYXCREST"
	dungeon.location = locationfactory.locations["LVL_DUNGEON"]
	dungeon.require = ["LVL_START"]
	dungeon.character = "friederich"
	levels[dungeon.title] = dungeon
	
	var icecave = levelclass.new()
	icecave.title = "LVL_ICECAVE"
	icecave.type = "quest"
	icecave.position = Vector2(77, 198)
	icecave.description = "LVL_ICECAVE_DESCRIPTION"
	icecave.reward = 4000
	icecave.item = "ITEM_STYXFIGURINE"
	icecave.location = locationfactory.locations["LVL_ICECAVE"]
	icecave.require = ["LVL_START"]
	icecave.character = "adela"
	levels[icecave.title] = icecave
	
	var manor = levelclass.new()
	manor.title = "LVL_MANOR"
	manor.type = "boss"
	manor.position = Vector2(503, 186)
	manor.description = "LVL_MANOR_DESCRIPTION"
	manor.location = locationfactory.locations["LVL_MARBLECASTLE"]
	manor.reward = 20000
	manor.require = ["LVL_DUNGEON", "LVL_BERGFORTRESS"]
	levels[manor.title] = manor
	
	var holyruins = levelclass.new()
	holyruins.title = "LVL_HOLYRUINS"
	holyruins.type = "boss"
	holyruins.position = Vector2(307, 327)
	holyruins.description = "LVL_HOLYRUINS_DESCRIPTION"
	holyruins.location = locationfactory.locations["LVL_HOLYRUINS"]
	holyruins.reward = 20000
	holyruins.require = ["LVL_ICECAVE", "LVL_AQUADUCT"]
	levels[holyruins.title] = holyruins
	
	var capecrypt = levelclass.new()
	capecrypt.title = "LVL_CAPECRYPT"
	capecrypt.type = "boss"
	capecrypt.position = Vector2(560, 424)
	capecrypt.description = "LVL_CAPECRYPT_DESCRIPTION"
	capecrypt.location = locationfactory.locations["LVL_CAPECRYPT"]
	capecrypt.reward = 50000
	capecrypt.require = ["LVL_HOLYRUINS", "LVL_MAUSOLEUM"]
	levels[capecrypt.title] = capecrypt
	
	var start = levelclass.new()
	start.title = "LVL_START"
	start.type = "quest"
	start.position = Vector2(295, 356)
	start.description = "LVL_START_DESCRIPTION"
	start.reward = 100
	start.item = "ITEM_AMULET"
	start.location = locationfactory.locations["LVL_START"]
	levels[start.title] = start
	
	var colosseum1 = levelclass.new()
	colosseum1.title = "LVL_COLOSSEUM1"
	colosseum1.type = "colosseum"
	colosseum1.position = Vector2(193, 360)
	colosseum1.description = "LVL_COLOSSEUM1_DESCRIPTION"
	colosseum1.reward = 50000
	colosseum1.require = [["LVL_BERGFORTRESS", "LVL_AQUADUCT"]]
	colosseum1.location = locationfactory.locations["LVL_COLOSSEUM"]
	colosseum1.waves = [preload("res://scenes/colosseum/waves/wave0-0.tscn"), preload("res://scenes/colosseum/waves/wave0-1.tscn"), preload("res://scenes/colosseum/waves/wave0-2.tscn")]
	levels[colosseum1.title] = colosseum1
	
	var colosseum2 = levelclass.new()
	colosseum2.title = "LVL_COLOSSEUM2"
	colosseum2.type = "colosseum"
	colosseum2.position = Vector2(193, 360)
	colosseum2.description = "LVL_COLOSSEUM2_DESCRIPTION"
	colosseum2.location = locationfactory.locations["LVL_COLOSSEUM"]
	colosseum2.reward = 100000
	levels[colosseum2.title] = colosseum2