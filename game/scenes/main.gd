
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var original_size
var pause
var pausemenu
var select
var sequences
var root
var is_paused = false
var music
var choice
var gameover = false
var dialog

var hideshop = false

var map
var map_position = preload("res://gui/maps/position.tscn")

var hidemap = false
var skipevent = false

var is_minimap = true

var select_f_size
var select_a_size
var fscale
var ascale
var fOffset
var aOffset

var fspriteOffset
var aspriteOffset

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

var keymap = preload("res://gui/KeyboardCharacters.gd").new()

var chainlist = {"chop": false, "slice": false, "skewer": false, "stab": false, "thrust": false, "swift": false, "dualspin": false, "void": false, "rush": false}

var loading
var loader
var wait_frames
var teleport_params = []
var currentevent

func _ready():
	# Initialization here
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
	Globals.set("available_levels", ["LVL_SANDBOX", "LVL_FOREST1", "LVL_FOREST2", "LVL_MANOR", "LVL_LAVACAVE", "LVL_START", "LVL_COLOSSEUM1", "LVL_COLOSSEUM2", "LVL_AQUADUCT", "LVL_HOLYRUINS", "LVL_CAPECRYPT", "LVL_BERGFORTRESS", "LVL_SPRINGISLANDCASTLE", "LVL_CAVE", "LVL_MAUSOLEUM", "LVL_DUNGEON"])
	Globals.set("levels", levelfactory.new().levels)
	Globals.set("current_level", "LVL_START")
	Globals.set("eventmode", false)
	Globals.set("current_quest_complete", false)
	Globals.set("reward_taken", false)
	Globals.set("sun", false)
	Globals.set("show_blood_counter", false)
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
	
	if (Globals.has("sfxvolume")):
		AudioServer.set_fx_global_volume_scale(Globals.get("sfxvolume"))
	if (Globals.has("bgmvolume")):
		AudioServer.set_stream_global_volume_scale(Globals.get("bgmvolume"))

	for spell in get_node("gui/CanvasLayer/hud/SpellIcons").get_children():
		spell.hide()
	select = get_node("gui/CanvasLayer/select")
	var selectf = select.get_node("friederich")
	var selecta = select.get_node("adela")
	select_f_size = selectf.get_rect().size
	select_a_size = selecta.get_rect().size
	fscale = selectf.get_scale()
	ascale = selecta.get_scale()
	fOffset = Vector2(select_f_size.x/2+selectf.get_pos().x - 0.25*original_size.x, select_f_size.y+selectf.get_pos().y - original_size.y)
	aOffset = Vector2(select_a_size.x/2+selecta.get_pos().x - 0.75*original_size.x, select_a_size.y+selecta.get_pos().y - original_size.y)
	select.get_node("friederich_sprite/AnimationPlayer").play("idle")
	select.get_node("adela_sprite/AnimationPlayer").play("idle")
	fspriteOffset = Vector2(select.get_node("friederich_sprite").get_pos().x, original_size.y - select.get_node("friederich_sprite").get_pos().y)
	aspriteOffset = Vector2(original_size.x - select.get_node("adela_sprite").get_pos().x, original_size.y - select.get_node("adela_sprite").get_pos().y)
	loading = get_node("gui/CanvasLayer/loading")
	loading.hide()
	select.show()
	is_paused = true
	get_tree().set_pause(is_paused)
	set_process_input(true)
	#enable for keyboard input
	#selectf.grab_focus()
	map = get_node("gui/CanvasLayer/map/container")
	choice = get_node("gui/CanvasLayer/choice")

func _on_resolution_changed():
	var new_size = root.get_rect().size
	var scaleX = new_size.x/original_size.x
	var scaleY = new_size.y/original_size.y
	pause.get_node("shield").set_scale(Vector2(scaleX, scaleY))
	var charscale = min(scaleX, scaleY)
	select.get_node("friederich").set_scale(Vector2(charscale*fscale.x, charscale*fscale.y))
	select.get_node("adela").set_scale(Vector2(charscale*ascale.x, charscale*ascale.y))
	select.get_node("friederich").set_pos(Vector2(new_size.x*0.25-select_f_size.x*charscale/2+fOffset.x*charscale, new_size.y-select_f_size.y*charscale+fOffset.y*charscale))
	select.get_node("adela").set_pos(Vector2(new_size.x*0.75-select_a_size.x*charscale/2+aOffset.x*charscale, new_size.y-select_a_size.y*charscale+aOffset.y*charscale))
	select.get_node("friederich_sprite").set_pos(Vector2(fspriteOffset.x*scaleX, new_size.y - fspriteOffset.y))
	select.get_node("adela_sprite").set_pos(Vector2(new_size.x - aspriteOffset.x*scaleX, new_size.y - aspriteOffset.y))

func _input(event):
	var canvas = get_node("gui/CanvasLayer")
	if (!gameover && dialog.get("dialogs") == null && !pause.has_node("shopping") && !canvas.has_node("WorldMap") && !Globals.get("eventmode")):
		if (event.is_action("ui_pause") && event.is_pressed() && !event.is_echo() && get_node("playercontainer").has_node("player") && !get_node("playercontainer/player").get("is_transforming")):
			if (is_paused && pausemenu.can_unpause()):
				pausemenu.reset()
				pausemenu.hide()
				pause.hide()
				is_paused = false
				if (pausemenu.get_node("panels/map/mapcontainer").has_node("objects")):
					pausemenu.get_node("panels/map/mapcontainer/objects").queue_free()
				music.set_volume_db(0)
			elif(!is_paused):
				pause.show()
				pausemenu.show()
				var big_map = map.get_node("objects").duplicate()
				big_map.set_draw_behind_parent(false)
				var map_pos_obj = map_position.instance()
				map_pos_obj.set_pos(Vector2(map.get("offset").x-map.get("objects").get_pos().x, map.get("offset").y-map.get("objects").get_pos().y))
				big_map.add_child(map_pos_obj)
				big_map.set_pos(Vector2(original_size.x/2 - map_pos_obj.get_pos().x, original_size.y/2 - map_pos_obj.get_pos().y))
				pausemenu.get_node("panels/map/mapcontainer").add_child(big_map)
				is_paused = true
				pausemenu.focus_tab()
				music.set_volume_db(-20)
			get_tree().set_pause(is_paused)
		elif (event.is_action_pressed("ui_select") && event.is_pressed() && !event.is_echo() && !is_paused):
			if (map.is_visible()):
				map.hide()
			else:
				map.show()
	if (pause.has_node("shopping")):
		if (event.is_action_pressed("ui_cancel") && event.is_pressed() && !event.is_echo()):
			var shopping = pause.get_node("shopping")
			if (!shopping.block_cancel()):
				pause.hide()
				pause.remove_child(shopping)
				shopping.queue_free()
				hideshop = true
	elif(hideshop):
		hideshop = false
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
	get_node("level").set_opacity(1)
	get_node("playercontainer").set_opacity(1)
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
	circle.set_pos(Vector2(400, 274))
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
	orbs.set_pos(Vector2(400, 274))
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
	stardust.set_pos(Vector2(400, 296))
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
	get_node("level").set_opacity(1)
	get_node("playercontainer").set_opacity(1)
	get_node("AnimationPlayer").disconnect("finished", self, "end_warp_animation")
	get_node("AnimationPlayer").stop()
	get_node("level/LVL_CATACOMB/tilemap/NPCGroup/Kaleva").end_warp_animation()
	sequences.hide()
	if (Globals.get("eventmode")):
		toggle_eventmode(false)

func _select_friederich():
	selected_character = friederich
	var player = friederich.instance()
	Globals.set("player", "friederich")
	start(player)

func _select_adela():
	selected_character = adela
	var player = adela.instance()
	Globals.set("player", "adela")
	start(player)

func start(player):
	_friederich_exit()
	_adela_exit()
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
	get_node("gui/sound").play("confirm")
	player.set_global_pos(Vector2(-16, 320))
	get_node("playercontainer").add_child(player)
	player.load_tilemap(level)
	select.hide()
	is_paused = false
	get_tree().set_pause(is_paused)

func show_gameover():
	pause.show()
	var yes = choice.get_node("yes/button")
	yes.connect("pressed", self, "reset_level")
	yes.grab_focus()
	var no = choice.get_node("no/button")
	no.connect("pressed", self, "reset")
	choice.show()

func hide_choice():
	choice.hide()
	var yes = choice.get_node("yes/button")
	choice.get_node("yes")._on_button_focus_exit()
	yes.disconnect("pressed", self, "reset_level")
	var no = choice.get_node("no/button")
	choice.get_node("no")._on_button_focus_exit()
	no.disconnect("pressed", self, "reset")

func reset_level():
	get_node("gui/sound").play("confirm")
	hide_choice()
	var old_player = get_node("playercontainer/player")
	get_node("gui/CanvasLayer/hud/SpellIcons/" + old_player.get_selected_spell_id()).hide()
	get_node("playercontainer").remove_child(old_player)
	old_player.queue_free()
	var player = selected_character.instance()
	get_node("playercontainer").add_child(player)
	Globals.get("inventory").set("player", player)
	map.set("camera", player.get_node("Camera2D"))
	get_node("gui/CanvasLayer/hud").reset()
	teleport("res://levels/common/catacombs.tscn", Vector2(-16, 320), null)
	is_paused = false
	pause.hide()
	gameover = false
	Globals.get("inventory").clear_inventory()
	Globals.set("gold", 0)
	Globals.set("scrolls", {})
	Globals.set("current_quest_complete", false)
	Globals.set("reward_taken", false)
	get_tree().set_pause(false)

func reset():
	get_node("gui/sound").play("confirm")
	hide_choice()
	map.reset()
	Globals.set("chain", chainlist)
	Globals.set("mapid", "LVL_START")
	sequences.get_node("demonic/sprite/friederich").hide()
	sequences.get_node("demonic/sprite/adela").hide()
	get_node("gui/CanvasLayer/chain/chaintext").hide()
	get_node("gui/CanvasLayer/chain/newattack").hide()
	get_node("gui/CanvasLayer/chain").hide()
	get_node("gui/CanvasLayer/hud").reset()
	var player = get_node("playercontainer/player")
	get_node("gui/CanvasLayer/hud/SpellIcons/" + player.get_selected_spell_id()).hide()
	player.queue_free()
	get_node("gui/CanvasLayer/hud").set("player", null)
	var old_level = get_node("level").get_child(0)
	get_node("level").remove_child(old_level)
	old_level.queue_free()
	var level = load("res://levels/common/catacombs.tscn").instance()
	get_node("level").add_child(level)
	gameover = false
	is_paused = true
	pause.hide()
	select.show()

func display_level_title(title):
	var level = get_node("gui/CanvasLayer/level")
	level.get_node("title").set_text(title)
	level.get_node("AnimationPlayer").play("show")

func connect_catacombs(level):
	var new_teleport = level.get_node("tilemap/TeleportGroup").get_child(0)
	var map = Globals.get("levels")[Globals.get("current_level")]
	new_teleport.target_level = map.location.node
	new_teleport.teleport_to = map.location.teleportto

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
	loader = ResourceLoader.load_interactive(new_level)
	if (loader == null):
		print("error loading resource: " + new_level)
		return
	set_process(true)
	
	level.queue_free()
	
	loading.show()
	if (Globals.get("player") == "friederich"):
		loading.get_node("bat").show()
		loading.get_node("cat").hide()
	else:
		loading.get_node("cat").show()
		loading.get_node("bat").hide()
	get_node("AnimationPlayer").play("loading")
	
	#stop player processing
	get_tree().set_pause(true)
	
	wait_frames = 1

# handle loaded level
func do_teleport(resource, new_level, pos, teleport):
	get_tree().set_pause(false)
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
			gold.set_global_pos(Vector2(-16, 368))
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

# background loading
func _process(delta):
	if (loader == null):
		loading.hide()
		get_node("AnimationPlayer").stop()
		set_process(false)
		return
	
	if (wait_frames > 0):
		wait_frames -= 1
		return
	
	var t = OS.get_ticks_msec()
	while (OS.get_ticks_msec() < t + 100 && loader != null):
		var err = loader.poll()
		
		if (err == ERR_FILE_EOF):
			var resource = loader.get_resource()
			loader = null
			do_teleport(resource, teleport_params[0], teleport_params[1], teleport_params[2])
		elif (err == OK):
			update_progress()
		else:
			print("error loading resource: " + teleport_params[0])
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	loading.get_node("text").set_text(tr("KEY_LOADING") + " " + str(int(progress * 100)) + "%")

func sequence_finished():
	sequences.get_node("demonic").hide()
	sequences.hide()
	pause.hide()
	get_tree().set_pause(false)

func _select_hover():
	get_node("gui/sound").play("cursor")


func _friederich_hover():
	select.get_node("friederich_sprite/AnimationPlayer").play("run")
	_select_hover()


func _adela_hover():
	select.get_node("adela_sprite/AnimationPlayer").play("run")
	_select_hover()


func _friederich_exit():
	select.get_node("friederich_sprite/AnimationPlayer").play("idle")


func _adela_exit():
	select.get_node("adela_sprite/AnimationPlayer").play("idle")

# Globals with preloaded assets are not cleared properly. Until this is
# fixed, we are clearing them manually ourselves.
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		Globals.set("magic_spells", null)
		Globals.set("itemfactory", null)
		Globals.set("levels", null)
		Globals.set("inventory", null)
		Globals.set("scrolls", null)
		Globals.set("shops", null)
		Globals.set("mapobjects", null)
		Globals.set("mapindex", null)
		Globals.set("available_spells", null)
		get_tree().quit()