extends "res://gui/dialogue/choice.gd"

var characterBG
var id
var idnr
const SAVE = "saved"
const NEW = "new"
const OPTIONS = "options"
var state = SAVE
var saveGroup
var newGroup
var optionsGroup
var selectedOption
var gameData
var filename
var gameclock
var gameclock_class = preload("res://scenes/GameClock.gd")
var loadonly = false

var serialization
var savepos
var savelocation
var silentcursor = false
var echo = false

signal newsave
signal options_visible
signal delete
signal clone
signal echo
signal loadgame

func _ready():
	serialization = Globals.get("serialization")
	optionsGroup = get_node("options")
	if (loadonly):
		optionsGroup.get_node("options/save").hide()
	else:
		gameclock = get_tree().get_root().get_node("world/gameclock")
	id = get_node("id")
	characterBG = get_node("characterBG")
	saveGroup = get_node("saved")
	newGroup = get_node("new")
	set_process_input(true)
	setState(state)

func setState(value):
	state = value
	if (state == SAVE):
		characterBG.show()
		saveGroup.show()
		optionsGroup.hide();
		newGroup.hide()
		emit_signal("options_visible", false)
	elif (state == NEW):
		characterBG.hide()
		saveGroup.hide()
		optionsGroup.hide()
		newGroup.show()
		emit_signal("options_visible", false)
	elif (state == OPTIONS):
		optionsGroup.show()
		newGroup.hide()
		emit_signal("options_visible", true)

func set_id(value):
	idnr = int(value)
	id.set_text("#" + value)

func hideSavedRecently():
	saveGroup.get_node("saved").hide()

func show_optionsmenu():
	unfocus_options()
	optionsGroup.get_node("options/" + selectedOption).grab_focus()
	optionsGroup.get_node("description").hide()
	optionsGroup.get_node("choice").hide()
	for option in optionsGroup.get_node("options").get_children():
		option.set_opacity(1)

func unfocus_options():
	for option in optionsGroup.get_node("options").get_children():
		option.release_focus()
		option.get_node("icon").hide()

func reset_options():
	for option in optionsGroup.get_node("options").get_children():
		option.set_opacity(1)

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		var focus = get_focus_owner()
		if (event.is_action_pressed("ui_accept") && !echo):
			if (focus == self):
				sfx.play("confirm")
				if (state == NEW):
					save()
					emit_signal("newsave")
				elif (state == SAVE):
					setState(OPTIONS)
					selectedOption = "load"
					unfocus_options()
					optionsGroup.get_node("options/load").grab_focus()
					optionsGroup.get_node("choice").hide()
					optionsGroup.get_node("description").hide()
			elif (state == OPTIONS):
				sfx.play("confirm")
				if (optionsGroup.get_node("choice").is_visible()):
					if (focus.get_name() == "no"):
						show_optionsmenu()
					else:
						if (selectedOption == "load"):
							if (loadonly):
								Globals.set("gamedata", gameData)
								Globals.set("player", gameData.player.character)
								emit_signal("loadgame")
							else:
								var root = get_tree().get_root().get_node("world")
								root.load_game(gameData)
						elif (selectedOption == "save"):
							save()
							silentcursor = true
							self.grab_focus()
							reset_options()
						elif (selectedOption == "delete"):
							emit_signal("delete", get_index(), filename)
				else:
					unfocus_options()
					if (focus.get_name() == "load"):
						selectedOption = "load"
						optionsGroup.get_node("description").set_text("KEY_CONFIRMLOAD")
					elif (focus.get_name() == "save"):
						selectedOption = "save"
						optionsGroup.get_node("description").set_text("KEY_CONFIRMOVERWRITE")
					elif (focus.get_name() == "delete"):
						selectedOption = "delete"
						optionsGroup.get_node("description").set_text("KEY_CONFIRMDELETE")
					elif (focus.get_name() == "clone"):
						emit_signal("clone", gameData)
						setState(SAVE)
					if (focus.get_name() != "clone"):
						for option in optionsGroup.get_node("options").get_children():
							option.set_opacity(0.25)
						focus.set_opacity(1)
						optionsGroup.get_node("description").show()
						optionsGroup.get_node("choice").show()
						optionsGroup.get_node("choice/yes").grab_focus()
		if (event.is_action_pressed("ui_cancel")):
			if (state == OPTIONS):
				if (optionsGroup.get_node("choice").is_visible()):
					show_optionsmenu()
				else:
					setState(SAVE)
					emit_signal("echo")
					self.grab_focus()
		echo = false

func save():
	var data = {}
	data.player = {}
	data.player.character = Globals.get("player")
	var player = get_tree().get_root().get_node("world/playercontainer/player")
	var stats = serialization.serialize_stats(player)
	data.player.stats = stats
	data.player.chainlist = Globals.get("chain")
	data.inventory = {}
	data.inventory.gold = Globals.get("gold")
	var scrolls = serialization.serialize_scrolls(Globals.get("scrolls"))
	data.inventory.scrolls = scrolls
	var inventory = serialization.serialize_items(Globals.get("inventory").get("inventory"))
	data.inventory.items = inventory
	var spells = serialization.serialize_spells(Globals.get("available_spells"))
	data.inventory.magic = spells
	data.settings = {}
	data.settings.bgmvolume = Globals.get("bgmvolume")
	data.settings.sfxvolume = Globals.get("sfxvolume")
	data.settings.bgmmute = Globals.get("bgmmute")
	data.settings.sfxmute = Globals.get("sfxmute")
	data.settings.controls = Globals.get("controls")
	data.levels = {}
	data.levels.currentLevel = Globals.get("current_level")
	data.levels.availableLevels = Globals.get("available_levels")
	data.levels.rewardTaken = Globals.get("reward_taken")
	data.levels.currentQuestComplete = Globals.get("current_quest_complete")
	var leveldata = serialization.serialize_levels(Globals.get("levels"))
	data.levels.data = leveldata
	data.maps = {}
	data.maps.id = Globals.get("mapid")
	var hudmap = get_tree().get_root().get_node("world/gui/CanvasLayer/map/container")
	data.maps.currentMap = hudmap.get("current_map")
	hudmap.cache_map()
	var mapindex = serialization.serialize_mapindex(hudmap, Globals.get("mapindex"))
	data.maps.index = mapindex
	var mapcache = Globals.get("mapobjects")
	var mapobjects = serialization.serialize_mapobjects(hudmap, Globals.get("mapobjects"))
	data.maps.objects = mapobjects
	data.shops = Globals.get("shops")
	data.deaths = Globals.get("deaths")
	data.position = [savepos.x, savepos.y]
	data.location = savelocation
	var date = OS.get_date()
	data.date = [date.day, date.month, date.year]
	data.playtime = gameclock.get("elapsed")

	Globals.set("lastsavepoint", {"id": hudmap.get("current_map"), "location": savelocation, "position": savepos})
	save_to_file(data)

func save_to_file(data):
	var savedir = Globals.get("savedir")
	var dir = Directory.new()
	if (!dir.dir_exists(savedir)):
		dir.make_dir(savedir)
	var file = File.new()
	if (filename == null):
		filename = "save" + str(idnr) + ".save"
	file.open(savedir + "/" + filename, File.WRITE)
	file.store_string(data.to_json())
	file.close()
	
	saveGroup.get_node("saved").show()
	displayGameData(data)
	setState(SAVE)

func save_from_data(data):
	save_to_file(data)
	saveGroup.get_node("saved").show()

func displayGameData(data):
	gameData = data
	if (data.player.character == "adela"):
		characterBG.set_texture(preload("res://gui/save/bgs/adela.png"))
	else:
		characterBG.set_texture(preload("res://gui/save/bgs/friederich.png"))
	saveGroup.get_node("location").set_text(data.location)
	saveGroup.get_node("gold").set_text(str(data.inventory.gold) + "G")
	saveGroup.get_node("stats").set_text("LV" + str(data.player.stats.level) + " " + str(data.player.stats.currentHp) + "/" + str(data.player.stats.hp) + "HP " + str(data.player.stats.currentMp) + "/" + str(data.player.stats.mp) + "MP")
	saveGroup.get_node("previewstats").set_text(str(data.deaths) + "    100%    " + str(data.date[0]).pad_zeros(2) + "." + str(data.date[1]).pad_zeros(2) + "." + str(data.date[2]))
	saveGroup.get_node("playtime").set_text(gameclock_class.display_time(int(data.playtime)))

func _on_choice_focus_enter():
	if (silentcursor):
		get_node("icon").show()
		silentcursor = false
	else:
		._on_choice_focus_enter()

func _on_choice_focus_exit():
	._on_choice_focus_exit()
	if (saveGroup != null):
		saveGroup.get_node("saved").hide()