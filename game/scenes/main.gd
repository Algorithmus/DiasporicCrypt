
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

var map
var map_position = preload("res://gui/maps/position.scn")

var select_f_size
var select_a_size
var fscale
var ascale
var fOffset
var aOffset

var fspriteOffset
var aspriteOffset

var friederich = preload("res://players/friederich/friederich.scn")
var adela = preload("res://players/adela/adela.scn")
var selected_character

var inventoryclass = preload("res://scenes/items/Inventory.gd")
var itemfactory = preload("res://scenes/items/ItemFactory.gd")

func _ready():
	# Initialization here
	Globals.set("itemfactory", itemfactory.new())
	root = get_tree().get_root()
	original_size = root.get_rect().size
	root.connect("size_changed", self, "_on_resolution_changed")
	pause = get_node("gui/CanvasLayer/pause")
	pausemenu = pause.get_node("menu")
	sequences = get_node("gui/CanvasLayer/sequences")
	sequences.get_node("demonic/sprite/friederich").hide()
	sequences.get_node("demonic/sprite/adela").hide()
	sequences.get_node("demonic").hide()
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
	if (!gameover && dialog.get("dialogs") == null):
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
	if (dialog.get("dialogs") != null):
		if (event.is_action_pressed("ui_accept") && event.is_pressed() && !event.is_echo()):
			dialog.check_dialog()

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
	display_level_title("LVL_SANDBOX")
	map.set("camera", player.get_node("Camera2D"))
	map.load_map(get_node("level/LVL_SANDBOX"))
	get_node("gui/sound").play("confirm")
	player.set_global_pos(Vector2(-160, -416))
	get_node("playercontainer").add_child(player)
	player.load_tilemap(get_node("level/LVL_SANDBOX"))
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
	teleport("res://levels/sandbox/sandbox.scn", Vector2(-160, -416), null)
	is_paused = false
	pause.hide()
	gameover = false
	Globals.get("inventory").clear_inventory()
	Globals.set("gold", 0)
	Globals.set("scrolls", {})
	get_tree().set_pause(false)

func reset():
	get_node("gui/sound").play("confirm")
	hide_choice()
	map.reset()
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
	var level = load("res://levels/sandbox/sandbox.scn").instance()
	get_node("level").add_child(level)
	gameover = false
	is_paused = true
	pause.hide()
	select.show()

func display_level_title(title):
	var level = get_node("gui/CanvasLayer/level")
	level.get_node("title").set_text(title)
	level.get_node("AnimationPlayer").play("show")

func teleport(new_level, pos, teleport):
	var new_level_obj = load(new_level).instance()
	map.set("current_teleport", teleport)
	map.load_map(new_level_obj)
	var level = get_node("level")
	var old_level = level.get_child(0)
	level.remove_child(old_level)
	old_level.queue_free()
	level.add_child(new_level_obj)
	var player = get_node("playercontainer/player")
	player.load_tilemap(new_level_obj)
	player.set_global_pos(pos)
	var level_title = get_node("gui/CanvasLayer/level/AnimationPlayer")
	level_title.stop()
	level_title.seek(0, true)
	if (new_level_obj.get_name() != "LVL_NOTITLE"):
		display_level_title(new_level_obj.get_name())
	# check that any scrolls already collected do not appear in the level again
	if (new_level_obj.has_node("tilemap/ScrollGroup")):
		for i in new_level_obj.get_node("tilemap/ScrollGroup").get_children():
			if (Globals.get("scrolls").has(i.get("title"))):
				i.queue_free()

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
