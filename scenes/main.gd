
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var original_size
var pause
var pausemenu
var sequences
var root
var is_paused = false
var music
var choice
var gameover = false
var dialog

var hide_altmenu = false

var map
var map_position = preload("res://gui/maps/position.tscn")

var hidemap = false
var skipevent = false

var is_minimap = true

var friederich = preload("res://players/friederich/friederich.tscn")
var adela = preload("res://players/adela/adela.tscn")
var selected_character

var inventoryclass = preload("res://scenes/items/Inventory.gd")
var itemfactory = preload("res://scenes/items/ItemFactory.gd")
var levelfactory = preload("res://levels/LevelFactory.gd")

var goldclass = preload("res://scenes/items/gold/gold.tscn")

var magiccircleclass = preload("res://scenes/animations/magiccircle/magiccircle.tscn")
var magicorbsclass = preload("res://scenes/animations/magiccircle/orbs.tscn")
var stardustclass = preload("res://scenes/animations/stardust.tscn")

var keymap = preload("res://gui/InputCharacters.gd").new()

var chainlist = {"chop": false, "slice": false, "skewer": false, "stab": false, "thrust": false, "swift": false, "dualspin": false, "void": false, "rush": false}

var loading
var teleport_params = []
var currentevent

var serialization

func _ready():
	# Initialization here
	serialization = Globals.get("serialization")
	var magic_spells = [{"id": "thunder", "type": "thunder", "mp": 40, "auracolor": Color(1, 1, 1), "weaponcolor1": Color(1, 247/255.0, 138/255.0), "weaponcolor2": Color(0, 116/255.0, 1), "is_single": false, "charge": preload("res://players/magic/thunder/charge.tscn"), "attack": preload("res://players/magic/thunder/thunder.tscn"), "delay": true, "atk": 0.8}, 
					{"id":"hex", "type": "dark", "mp": 40, "auracolor": Color(169/255.0, 0, 1), "weaponcolor1": Color(0, 0, 0), "weaponcolor2": Color(1, 0, 0), "is_single": false, "delay": true, "attack": preload("res://players/magic/hex/hex.tscn"), "atk": 0.8}, 
					{"id":"shield", "mp": 60, "auracolor": Color(0, 0, 1), "weaponcolor1": Color(0, 55/255.0, 1), "weaponcolor2": Color(0, 208/255.0, 1), "is_single": false, "delay": false, "attack": preload("res://players/magic/shield/shield.tscn"), "charge": preload("res://players/magic/shield/charge.tscn")}, 
					{"id":"magicmine", "mp": 20, "auracolor": Color(1, 129/255.0, 0), "weaponcolor1": Color(1, 1, 0), "weaponcolor2": Color(78/255.0, 0 , 1), "is_single": true, "delay": false, "attack": preload("res://players/magic/magicmine/mine.tscn"), "atk": 40}, 
					{"id":"void", "mp": 80, "auracolor": Color(110/255.0, 110/255.0, 122/255.0), "weaponcolor1": Color(0, 0, 0), "weaponcolor2": Color(1, 1, 1), "is_single": false, "delay": true, "attack": preload("res://players/magic/void/void.tscn")},
					{"id":"earth", "type": "earth", "mp": 100, "auracolor":Color(170/255.0, 1, 0), "weaponcolor1":Color(64/255.0, 58/255.0, 56/255.0), "weaponcolor2":Color(181/255.0, 188/255.0, 0), "is_single": false, "charge": preload("res://players/magic/earth/charge.tscn"), "attack": preload("res://players/magic/earth/earth.tscn"), "delay": true, "atk": 1.2},
					{"id":"fire", "type": "fire", "mp": 20, "auracolor":Color(1, 77/255.0, 0), "weaponcolor1":Color(1, 1, 0), "weaponcolor2":Color(1, 0, 0), "is_single": false, "attack": preload("res://players/magic/fire/fire.tscn"), "delay": false, "atk": 0.7},
					{"id":"wind", "type": "wind", "mp": 120, "auracolor": Color(0, 1, 149/255.0), "weaponcolor1": Color(187/255.0, 1, 231/255.0), "weaponcolor2": Color(0, 191/255.0, 92/255.0), "delay": true, "is_single": false, "charge": preload("res://players/magic/wind/charge.tscn"), "attack": preload("res://players/magic/wind/wind.tscn"), "atk": 1.2},
					{"id":"ice", "type": "ice", "mp": 20, "auracolor": Color(0, 130/255.0, 207/255.0), "weaponcolor1": Color(0, 1, 1), "weaponcolor2": Color(0, 130/255.0, 207/255.0), "delay": false, "is_single": false, "attack": preload("res://players/magic/ice/ice.tscn"), "atk": 0.75}]
	Globals.set("magic_spells", magic_spells)
	Globals.set("chain", chainlist)
	Globals.set("itemfactory", itemfactory.new())
	Globals.set("levels", levelfactory.new().levels)
	Globals.set("current_level", "LVL_START")
	Globals.get("levels")[Globals.get("current_level")].new = false
	Globals.set("special_tiles", 0)
	Globals.set("eventmode", false)
	Globals.set("current_quest_complete", false)
	Globals.set("reward_taken", false)
	Globals.set("sun", false)
	Globals.set("show_blood_counter", false)
	Globals.set("blood_count", 0)
	Globals.set("defaultsavepoint", {"location": "LVL_CATACOMB", "position": Vector2(-192, 322), "id": "res://levels/common/catacombs.tscn"})
	Globals.set("lastsavepoint", Globals.get("defaultsavepoint"))
	Globals.set("deaths", 0)
	root = get_tree().get_root()
	original_size = root.get_rect().size
	root.connect("size_changed", self, "_on_resolution_changed")
	pause = get_node("gui/CanvasLayer/pause")
	pausemenu = pause.get_node("menu")
	sequences = get_node("gui/CanvasLayer/sequences")
	sequences.get_node("demonic/sprite/friederich").hide()
	sequences.get_node("demonic/sprite/adela").hide()
	sequences.get_node("demonic").hide()
	sequences.get_node("skip").hide()
	sequences.hide()
	music = get_node("music")
	pausemenu.hide()
	pause.hide()
	get_node("gui/CanvasLayer/chain/chaintext").hide()
	get_node("gui/CanvasLayer/chain/newattack").hide()
	get_node("gui/CanvasLayer/chain").hide()
	dialog = get_node("gui/CanvasLayer/dialogue")
	
	var sfx = AudioServer.get_fx_global_volume_scale()
	if (Globals.has("sfxvolume")):
		sfx = Globals.get("sfxvolume")
	if (Globals.get("sfxmute") && Globals.get("sfxmute")):
		sfx = 0
	var bgm = AudioServer.get_stream_global_volume_scale()
	if (Globals.has("bgmvolume")):
		bgm = Globals.get("bgmvolume")
	if (Globals.has("bgmmute") && Globals.get("bgmmute")):
		bgm = 0
	AudioServer.set_fx_global_volume_scale(sfx)
	AudioServer.set_stream_global_volume_scale(bgm)

	for spell in get_node("gui/CanvasLayer/hud/SpellIcons").get_children():
		spell.hide()
	loading = get_node("gui/CanvasLayer/loading")
	loading.hide()
	loading.connect("complete", self, "load_complete")
	is_paused = true
	get_tree().set_pause(is_paused)
	set_process_input(true)
	map = get_node("gui/CanvasLayer/map/container")
	choice = get_node("gui/CanvasLayer/choice")
	choice.hide()
	var player
	var available_levels = ["LVL_START"]
	if (Globals.get("debugmode")):
		available_levels = ["LVL_SANDBOX", "LVL_START", "LVL_FOREST1", "LVL_FOREST2", "LVL_COLOSSEUM1", "LVL_COLOSSEUM2"]
	if (Globals.get("demomode")):
		get_node("gui/CanvasLayer/demo/RichTextLabel").set_bbcode("[center]" + tr("KEY_HELP") + " [b]" + keymap.map_key("F1") + "[/b][/center]")
	else:
		get_node("gui/CanvasLayer/demo").hide()

	if (Globals.get("player") == "friederich"):
		if (Globals.get("debugmode")):
			available_levels.append("LVL_MANOR")
			available_levels.append("LVL_LAVACAVE")
			available_levels.append("LVL_BERGFORTRESS")
			available_levels.append("LVL_WINTERISLANDCASTLE")
			available_levels.append("LVL_CAVE")
			available_levels.append("LVL_DUNGEON")
			available_levels.append("LVL_AQUADUCT2")
		selected_character = friederich
		player = friederich.instance()
	else:
		if (Globals.get("debugmode")):
			available_levels.append("LVL_AQUADUCT")
			available_levels.append("LVL_HOLYRUINS")
			available_levels.append("LVL_CAPECRYPT")
			available_levels.append("LVL_SPRINGISLANDCASTLE")
			available_levels.append("LVL_SUMMERISLANDCASTLE")
			available_levels.append("LVL_MAUSOLEUM")
			available_levels.append("LVL_ICECAVE")
		selected_character = adela
		player = adela.instance()
	Globals.set("available_levels", available_levels)
	start(player)
	if (Globals.has("gamedata")):
		load_game(Globals.get("gamedata"))
		Globals.set("gamedata", null)

func _on_resolution_changed():
	var new_size = root.get_rect().size
	var scaleX = new_size.x/original_size.x
	var scaleY = new_size.y/original_size.y
	pause.get_node("shield").set_scale(Vector2(scaleX, scaleY))

func _input(event):
	var canvas = get_node("gui/CanvasLayer")
	if (!gameover && dialog.get("dialogs") == null && !pause.has_node("shopping") && !pause.has_node("save") && !canvas.has_node("WorldMap") && !Globals.get("eventmode")):
		var helpPressed = event.is_action("ui_help") && Globals.get("demomode")
		if ((event.is_action("ui_pause") || helpPressed) && event.is_pressed() && !event.is_echo() && get_node("playercontainer").has_node("player") && !get_node("playercontainer/player").get("is_transforming") && !Globals.get("show_switch")):
			if (is_paused && pausemenu.can_unpause() && !helpPressed):
				# return back to focused tabs properly for when menu gets opened again
				pausemenu.focus_tab()
				pausemenu.reset()
				pausemenu.hide()
				pause.hide()
				is_paused = false
				if (pausemenu.get_node("panels/map/mapcontainer/viewport").has_node("objects")):
					pausemenu.get_node("panels/map/mapcontainer/viewport/objects").queue_free()
				music.set_volume_db(0)
			elif(!is_paused):
				pause.show()
				pausemenu.show()
				var big_map = map.get_node("objects").duplicate()
				big_map.set_draw_behind_parent(false)
				var map_pos_obj = map_position.instance()
				map_pos_obj.set_position(Vector2(map.get("offset").x-map.get("objects").get_position().x, map.get("offset").y-map.get("objects").get_position().y))
				big_map.add_child(map_pos_obj)
				# center in viewport in menu map
				big_map.set_position(Vector2(270 - map_pos_obj.get_position().x, 107 - map_pos_obj.get_position().y))
				pausemenu.get_node("panels/map/mapcontainer/viewport").add_child(big_map)
				is_paused = true
				# Have a help key for showing the settings menu in demo mode
				if (helpPressed):
					pausemenu.change_tab("settings")
				else:
					# switch to specific tab if certain items are picked up recently
					var lastitemtype = canvas.get_node("items").get("lastitemtype")
					if (lastitemtype != null):
						var tab = "items"
						if (lastitemtype == "gold" || lastitemtype == "exp"):
							tab = "stats"
						elif (lastitemtype == "magic"):
							tab = "magic"
						elif (lastitemtype == "scroll"):
							tab = "scrolls"
						pausemenu.change_tab(tab)
				pausemenu.focus_tab()
				music.set_volume_db(-20)
			get_tree().set_pause(is_paused)
		elif (event.is_action_pressed("ui_select") && event.is_pressed() && !event.is_echo() && !is_paused):
			if (map.is_visible()):
				map.hide()
			else:
				map.show()
	var altmenu = null
	if (pause.has_node("shopping")):
		altmenu = pause.get_node("shopping")
	if (pause.has_node("save")):
		altmenu = pause.get_node("save")
	if (altmenu != null):
		if (event.is_action_pressed("ui_cancel") && event.is_pressed() && !event.is_echo()):
			if (!altmenu.block_cancel()):
				pause.hide()
				pause.remove_child(altmenu)
				altmenu.queue_free()
				hide_altmenu = true
	elif(hide_altmenu):
		hide_altmenu = false
		get_tree().set_pause(false)
	if (canvas.has_node("WorldMap") && !Globals.get("eventmode")):
		if (event.is_action_pressed("ui_cancel") && event.is_pressed() && !event.is_echo()):
			var worldmap = canvas.get_node("WorldMap")
			if (!worldmap.block_cancel()):
				canvas.remove_child(worldmap)
				worldmap.queue_free()
				hidemap = true
	elif(hidemap):
		hidemap = false
		get_tree().set_pause(false)
	if (dialog.get("dialogs") != null):
		if (event.is_action_pressed("ui_accept") && event.is_pressed() && !event.is_echo()):
			dialog.check_dialog()
	if (Globals.get("eventmode") && event.is_action_pressed("ui_cancel") && event.is_pressed() && !event.is_echo()):
		skipevent = true
	elif(skipevent):
		skipevent = false
		if (currentevent == "warp"):
			end_warp_animation()
		elif (currentevent == "restore"):
			end_restore_animation()

func toggle_eventmode(value):
	Globals.set("eventmode", value)
	var skip = sequences.get_node("skip")
	var canvas = get_node("gui/CanvasLayer")
	if (Globals.get("eventmode")):
		keymap.update_keys()
		is_minimap = map.is_visible()
		map.hide()
		skip.show()
		skip.set_bbcode("[right]" + tr("KEY_SKIP") + ":  [code]" + keymap.map_action("ui_cancel") + "[/code][/right]")
		#canvas.get_node("chain").hide()
		canvas.get_node("hud").hide()
		canvas.get_node("items").hide()
		canvas.get_node("level").hide()
	else:
		if (is_minimap):
			map.show()
		skip.hide()
		canvas.get_node("chain").show()
		canvas.get_node("hud").show()
		canvas.get_node("items").show()
		canvas.get_node("level").show()

func restore_animation():
	currentevent = "restore"
	var canvas = get_node("gui/CanvasLayer")
	get_tree().set_pause(false)
	if (!Globals.get("eventmode")):
		toggle_eventmode(true)
	get_node("AnimationPlayer").connect("finished", self, "show_restore")
	get_node("AnimationPlayer").play("hide")
	sequences.show()

func show_restore():
	get_node("AnimationPlayer").disconnect("finished", self, "show_restore")
	get_node("AnimationPlayer").connect("finished", self, "end_restore_animation")
	get_node("AnimationPlayer").play("show")
	var player = get_node("playercontainer/player")
	player.current_hp = player.hp
	player.current_mp = player.mp

func end_restore_animation():
	if (get_node("AnimationPlayer").is_connected("finished", self, "show_restore")):
		get_node("AnimationPlayer").disconnect("finished", self, "show_restore")
	if (get_node("AnimationPlayer").is_connected("finished", self, "end_restore_animation")):
		get_node("AnimationPlayer").disconnect("finished", self, "end_restore_animation")
.modulate.a = 1
.modulate.a = 1
	get_node("AnimationPlayer").stop()
	var player = get_node("playercontainer/player")
	player.current_hp = player.hp
	player.current_mp = player.mp
	if (Globals.get("eventmode")):
		toggle_eventmode(false)
	sequences.hide()

func warp_animation():
	currentevent = "warp"
	var canvas = get_node("gui/CanvasLayer")
	var worldmap = canvas.get_node("WorldMap")
	canvas.remove_child(worldmap)
	worldmap.queue_free()
	get_tree().set_pause(false)
	if (!Globals.get("eventmode")):
		toggle_eventmode(true)
	var circle = magiccircleclass.instance()
	circle.set_position(Vector2(400, 274))
	circle.get_node("AnimationPlayer").connect("finished", self, "circle_rotate")
	sequences.add_child(circle)
	sequences.show()
	circle.get_node("AnimationPlayer").play("grow")
	get_node("level/LVL_CATACOMB/tilemap/NPCGroup/Kaleva").warp_animation()

func circle_rotate():
	var circle = sequences.get_node("circle/AnimationPlayer")
	circle.disconnect("finished", self, "circle_rotate")
	circle.connect("finished", self, "circle_fade")
	circle.play("rotate")

func circle_fade():
	var circle = sequences.get_node("circle/AnimationPlayer")
	circle.disconnect("finished", self, "circle_fade")
	circle.play("fade")
	var orbs = magicorbsclass.instance()
	orbs.set_position(Vector2(400, 274))
	orbs.get_node("AnimationPlayer").connect("finished", self, "orbs_fade")
	sequences.add_child(orbs)
	orbs.get_node("AnimationPlayer").play("show")

func orbs_fade():
	var orbs_animation = sequences.get_node("orbs/AnimationPlayer")
	orbs_animation.disconnect("finished", self, "orbs_fade")
	orbs_animation.connect("finished", self, "fade_level")
	orbs_animation.play("hide")

func fade_level():
	get_node("level/LVL_CATACOMB/tilemap/NPCGroup/Kaleva").end_warp_animation()
	var orbs = sequences.get_node("orbs")
	orbs.get_node("AnimationPlayer").stop()
	sequences.remove_child(orbs)
	orbs.queue_free()
	get_node("AnimationPlayer").connect("finished", self, "show_level")
	get_node("AnimationPlayer").play("hide")
	var stardust = stardustclass.instance()
	stardust.set_position(Vector2(400, 296))
	sequences.add_child(stardust)
	stardust.set_emitting(true)

func show_level():
	if (sequences.has_node("circle")):
		var circle = sequences.get_node("circle")
		circle.get_node("AnimationPlayer").stop()
		sequences.remove_child(circle)
		circle.queue_free()
	get_node("AnimationPlayer").disconnect("finished", self, "show_level")
	get_node("AnimationPlayer").connect("finished", self, "end_warp_animation")
	get_node("AnimationPlayer").play("show")

func end_warp_animation():
	if (sequences.has_node("circle")):
		var circle = sequences.get_node("circle")
		circle.get_node("AnimationPlayer").stop()
		sequences.remove_child(circle)
		circle.queue_free()
	if (sequences.has_node("orbs")):
		var orbs = sequences.get_node("orbs")
		orbs.get_node("AnimationPlayer").stop()
		sequences.remove_child(orbs)
		orbs.queue_free()
	if (sequences.has_node("stardust")):
		var stardust = sequences.get_node("stardust")
		sequences.remove_child(stardust)
		stardust.queue_free()
.modulate.a = 1
.modulate.a = 1
	get_node("AnimationPlayer").disconnect("finished", self, "end_warp_animation")
	get_node("AnimationPlayer").stop()
	get_node("level/LVL_CATACOMB/tilemap/NPCGroup/Kaleva").end_warp_animation()
	sequences.hide()
	if (Globals.get("eventmode")):
		toggle_eventmode(false)

func start(player):
	var inventory = inventoryclass.new()
	inventory.set("player", player)
	Globals.set("inventory", inventory)
	Globals.set("scrolls", {})
	Globals.set("gold", 0)
	Globals.set("shops", {})
	display_level_title("LVL_CATACOMB")
	var level = get_node("level/LVL_CATACOMB")
	map.set("camera", player.get_node("Camera2D"))
	map.load_cached_map(level)
	connect_catacombs(level)
	level.get_node("tilemap/SaveGroup/savepoint").check_sprite()
	get_node("gui/sound").play("confirm")
	player.set_global_position(Vector2(-16, 322))
	get_node("playercontainer").add_child(player)
	player.load_tilemap(level)
	is_paused = false
	get_tree().set_pause(is_paused)

func show_gameover():
	pause.show()
	var yes = choice.get_node("yes/button")
	yes.connect("pressed", self, "reset_level")
	yes.grab_focus()
	var no = choice.get_node("no/button")
	no.connect("pressed", self, "global_menu")
	choice.show()

func hide_choice():
	choice.hide()
	var yes = choice.get_node("yes/button")
	choice.get_node("yes")._on_button_focus_exit()
	yes.disconnect("pressed", self, "reset_level")
	var no = choice.get_node("no/button")
	choice.get_node("no")._on_button_focus_exit()
	no.disconnect("pressed", self, "global_menu")

func reset_level():
	get_node("gui/sound").play("confirm")
	hide_choice()
	var old_player = get_node("playercontainer/player")
	get_node("gui/CanvasLayer/hud/SpellIcons/" + old_player.get_selected_spell_id()).hide()
	get_node("playercontainer").remove_child(old_player)
	var player = friederich.instance()
	if (Globals.get("player") == "adela"):
		player = adela.instance()
	get_node("playercontainer").add_child(player)
	var exp_obj = player.get("exp_growth_obj")
	var old_exp_obj = old_player.get("exp_growth_obj")
	exp_obj.set("total_exp", old_exp_obj.get("total_exp"))
	exp_obj.set("exp_required", old_exp_obj.get("exp_required"))
	exp_obj.set("current_exp", old_exp_obj.get("current_exp"))
	player.set("level", old_player.get("level"))
	player.set("base_hp", old_player.get("base_hp"))
	player.set("hp", old_player.get("base_hp"))
	player.set("current_hp", player.get("base_hp"))
	player.set("base_mp", old_player.get("base_mp"))
	player.set("mp", old_player.get("base_mp"))
	player.set("current_mp", old_player.get("base_mp"))
	player.set("base_atk", old_player.get("base_atk"))
	player.set("base_def", old_player.get("base_def"))
	player.set("base_mag", old_player.get("base_mag"))
	player.set("base_luck", old_player.get("base_luck"))
	old_player.queue_free()
	Globals.get("inventory").set("player", player)
	map.set("camera", player.get_node("Camera2D"))
	get_node("gui/CanvasLayer/hud").reset()
	var level = Globals.get("lastsavepoint")
	if (Globals.get("mapid") != level.location):
		 level = Globals.get("defaultsavepoint")
	teleport(level.id, level.position, null)
	Globals.set("deaths", Globals.get("deaths") + 1)
	is_paused = false
	pause.hide()
	gameover = false
	Globals.set("gold", Globals.get("gold") * 0.5)
	Globals.set("current_quest_complete", false)
	Globals.set("reward_taken", false)
	get_tree().set_pause(false)

func global_menu():
	get_node("gui/sound").play("confirm")
	get_tree().change_scene("res://scenes/global.tscn")

func clear_game():
	map.reset()
	Globals.set("chain", chainlist)
	Globals.set("mapid", "LVL_START")
	Globals.set("available_spells", null)
	sequences.get_node("demonic/sprite/friederich").hide()
	sequences.get_node("demonic/sprite/adela").hide()
	get_node("gui/CanvasLayer/chain/chaintext").hide()
	get_node("gui/CanvasLayer/chain/newattack").hide()
	get_node("gui/CanvasLayer/chain").hide()
	get_node("gui/CanvasLayer/hud").reset()
	var player = get_node("playercontainer/player")
	get_node("gui/CanvasLayer/hud/SpellIcons/" + player.get_selected_spell_id()).hide()
	get_node("playercontainer").remove_child(player)
	player.queue_free()
	get_node("gui/CanvasLayer/hud").set("player", null)
	var old_level = get_node("level").get_child(0)
	get_node("level").remove_child(old_level)
	old_level.queue_free()

func clearInputs(actionid):
	var mappedlist = InputMap.get_action_list(actionid)
	for e in mappedlist:
		if (e is InputEventKey):
			InputMap.action_erase_event(actionid, e)

func load_game(data):
	clear_game()
	Globals.set("mapid", data.maps.id)
	var grids = serialization.unserialize_grids(data.maps.index)
	Globals.set("grids", grids)
	var mapobjects = serialization.unserialize_mapobjects(map, data.maps.objects)
	Globals.set("mapobjects", mapobjects)
	var mapindex = serialization.unserialize_mapindex(map, Globals.get("mapobjects"))
	Globals.set("mapindex", mapindex)
	var levels = serialization.unserialize_levels(data.levels.data, levelfactory.new().levels)
	if (data.maps.has("special_tiles")):
		Globals.set("special_tiles", data.maps.special_tiles)
	Globals.set("levels", levels)
	var level = load(data.maps.currentMap).instance()
	get_node("level").add_child(level)
	Globals.set("player", data.player.character)
	if (data.player.character == "adela"):
		selected_character = adela
	else:
		selected_character = friederich
	var player = selected_character.instance()
	Globals.get("inventory").set("player", player)
	map.set("current_map", data.maps.currentMap)
	map.set("camera", player.get_node("Camera2D"))
	map.load_cached_map(level)
	get_node("gui/CanvasLayer/hud").reset()
	Globals.set("gold", data.inventory.gold)
	var scrolls = serialization.unserialize_scrolls(data.inventory.scrolls)
	Globals.set("scrolls", scrolls)
	var inventory = serialization.unserialize_items(data.inventory.items)
	Globals.get("inventory").set("inventory", inventory)
	var spells = serialization.unserialize_spells(data.inventory.magic)
	Globals.set("available_spells", spells)
	Globals.set("current_quest_complete", data.levels.currentQuestComplete)
	Globals.set("reward_taken", data.levels.rewardTaken)
	Globals.set("current_level", data.levels.currentLevel)
	Globals.set("available_levels", data.levels.availableLevels)
	Globals.set("shops", data.shops)
	Globals.set("bgmvolume", data.settings.bgmvolume)
	Globals.set("sfxvolume", data.settings.sfxvolume)
	Globals.set("bgmmute", data.settings.bgmmute)
	Globals.set("sfxmute", data.settings.sfxmute)
	Globals.set("keyboard_controls", data.settings.keyboard)
	Globals.set("gamepad_controls", data.settings.gamepad)
	var controls = data.settings.keyboard
	var layout = data.settings.layout
	# Only show the requested gamepad layout if gamepad is connected
	if (Input.get_connected_joysticks().size() > 0 && layout != "keyboard"):
		controls = data.settings.gamepad
	else:
		layout = "keyboard"
	Globals.set("current_input", layout)
	Globals.set("controls", controls)
	Globals.set("newcontrols", controls)
	var gameclock = get_node("gameclock")
	gameclock.set("elapsed", int(data.playtime))
	gameclock.resume()
	serialization.unserialize_controls(data.settings.keyboard, true)
	serialization.unserialize_controls(data.settings.gamepad, false)
	pausemenu.get_node("panels/settings").set_layout_index(layout)
	pausemenu.reset_content()
	var currentlevel = Globals.get("levels")[Globals.get("current_level")]
	var currentbgm = currentlevel.location.bgm
	level.get_node("tilemap/SaveGroup/savepoint").check_sprite()
	Globals.set("lastsavepoint", {"location": data.location, "id": data.maps.currentMap, "position": Vector2(data.position[0], data.position[1])})
	Globals.set("deaths", data.deaths)
	if (data.maps.currentMap == "res://levels/common/catacombs.tscn"):
		currentbgm = preload("res://levels/common/catacombs.ogg")
		connect_catacombs(level)
	if (currentbgm != music.get_stream()):
		music.set_stream(currentbgm)
		music.play()
	display_level_title(data.location)
	player.set_global_position(Vector2(data.position[0], data.position[1]))
	get_node("playercontainer").add_child(player)
	player.load_tilemap(level)
	serialization.unserialize_stats(player, data.player.stats)
	Globals.set("chain", data.player.chainlist)
	if (pause.has_node("save")):
		var loadsave = pause.get_node("save")
		pause.remove_child(loadsave)
		loadsave.queue_free()
	pause.hide()
	get_tree().set_pause(false)

func display_level_title(title):
	var level = get_node("gui/CanvasLayer/level")
	level.get_node("title/newlevel").hide()
	level.get_node("title").set_text(title)
	level.get_node("AnimationPlayer").play("show")

func connect_catacombs(level):
	var new_teleport = level.get_node("tilemap/TeleportGroup").get_child(0)
	var map = Globals.get("levels")[Globals.get("current_level")]
	new_teleport.target_level = map.location.node
	new_teleport.teleport_to = map.location.teleportto

func check_available_levels():
	var available_levels = Globals.get("available_levels")
	var levels = Globals.get("levels")
	var new_levels_available = false
	# look for levels with completed requirements we can add
	for key in levels:
		var level = levels[key]
		if (available_levels.find(level.title) < 0):
			var valid_character = true
			# if the requirement is not for the current character, we don't care about it
			if (level.character != null && level.character != Globals.get("player")):
				valid_character = false
			if (level.require != null && valid_character):
				var size = level.require.size()
				var found = false
				# look through require list for required levels
				for i in range(0, size):
					var required = level.require[i]
					# if the requirement is an array, only one of the levels is required
					if (typeof(required) == TYPE_ARRAY):
						found = check_related_requirements(required)
					else:
						found = levels[required].complete
					if (!found):
						break
				if (found):
					available_levels.append(level.title)
					new_levels_available = true
					get_node("gui/CanvasLayer/level/title/newlevel").show()
	return new_levels_available

# at least one requirement is required
func check_related_requirements(required):
	var available_levels = Globals.get("available_levels")
	var levels = Globals.get("levels")
	var required_size = required.size()
	for i in range(0, required_size):
		var required_level = required[i]
		if (levels[required_level].complete):
			return true

# load new level
func teleport(new_level, pos, teleport):
	Globals.set("show_blood_counter", false)
	var teleport_copy = null
	if (teleport != null):
		teleport_copy = teleport.duplicate()
	teleport_params = [new_level, pos, teleport_copy]
	var level = get_node("level").get_child(0)
	map.set("previous_id", level.get_filename())
	#var new_level_obj = load(new_level).instance()
	loading.load_resource(new_level)
	loading.show()
	
	level.queue_free()

func load_complete(resource):
	loading.hide()
	do_teleport(resource, teleport_params[0], teleport_params[1], teleport_params[2])

# handle loaded level
func do_teleport(resource, new_level, pos, teleport):
	var new_level_obj = resource.instance()
	new_level_obj.set_filename(new_level)
	var level_title_string = new_level_obj.get_name()
	map.set("current_teleport", teleport)
	map.load_map(new_level_obj)
	var level = get_node("level")
	#var old_level = level.get_child(0)
	#level.remove_child(old_level)
	#old_level.queue_free()
	level.add_child(new_level_obj)
	var player = get_node("playercontainer/player")
	player.load_tilemap(new_level_obj)
	# blacklist sensors and other types of area2D objects that should
	# not interfere with one way platform detection
	player.reset_blacklist()
	if (new_level_obj.has_node("tilemap/SensorGroup")):
		for sensor in new_level_obj.get_node("tilemap/SensorGroup").get_children():
			player.area2d_blacklist.append(sensor)
	if (new_level_obj.has_node("tilemap/SwingBoulderGroup")):
		for boulder in new_level_obj.get_node("tilemap/SwingBoulderGroup").get_children():
			player.area2d_blacklist.append(boulder.get_node("boulder/swingboulder"))
	#physics server lags behind, causing calls to move() to mess up
	#so we delay moving the player until physics server catches up
	player.call_deferred("teleport", pos, player.on_ladder)
	var level_title = get_node("gui/CanvasLayer/level/AnimationPlayer")
	level_title.stop()
	level_title.seek(0, true)
	if (level_title_string != "LVL_NOTITLE"):
		display_level_title(level_title_string)
	var currentlevel = Globals.get("levels")[Globals.get("current_level")]
	var currentbgm = currentlevel.location.bgm
	# make sure catacombs level connects to the correct level
	if (new_level == "res://levels/common/catacombs.tscn"):
		connect_catacombs(new_level_obj)
		currentbgm = preload("res://levels/common/catacombs.ogg")
		if (Globals.get("current_quest_complete") && !Globals.get("reward_taken") && currentlevel.reward > 0):
			var gold = goldclass.instance()
			gold.isreward = true
			gold.value = currentlevel.reward
			new_level_obj.get_node("tilemap").add_child(gold)
			gold.set_global_position(Vector2(-16, 368))
	if (currentbgm != music.get_stream()):
		music.set_stream(currentbgm)
		music.play()
	# apply switch effects after all switches have loaded targets
	if (new_level_obj.has_node("tilemap/SwitchGroup")):
		for i in new_level_obj.get_node("tilemap/SwitchGroup").get_children():
			i.activate()
			i.set("activated", false)
	# check that any scrolls already collected do not appear in the level again
	if (new_level_obj.has_node("tilemap/ScrollGroup")):
		for i in new_level_obj.get_node("tilemap/ScrollGroup").get_children():
			if (Globals.get("scrolls").has(i.get("title"))):
				i.queue_free()
	# check that goal item in quest levels is the correct one (or remove if already obtained)
	if (new_level_obj.has_node("tilemap/SpecialItemGroup")):
		var specialgroup = new_level_obj.get_node("tilemap/SpecialItemGroup")
		if (Globals.get("current_quest_complete")):
			specialgroup.queue_free()
		else:
			if (Globals.get("inventory").inventory.has(currentlevel.item)):
				specialgroup.get_child(1).queue_free()
			else:
				specialgroup.get_child(0).queue_free()
	Globals.set("sun", false)

func sequence_finished():
	sequences.get_node("demonic").hide()
	sequences.hide()
	pause.hide()
	get_tree().set_pause(false)

# Globals with preloaded assets are not cleared properly. Until this is
# fixed, we are clearing them manually ourselves.
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST || what == MainLoop.NOTIFICATION_PREDELETE):
		Globals.set("magic_spells", null)
		Globals.set("itemfactory", null)
		Globals.set("levels", null)
		Globals.set("inventory", null)
		Globals.set("scrolls", null)
		Globals.set("shops", null)
		Globals.set("mapobjects", null)
		Globals.set("mapindex", null)
		Globals.set("available_spells", null)
		if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
			get_tree().quit()
