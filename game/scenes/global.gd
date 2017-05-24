extends Node

# Global menu entry point into game

const MAIN = "main"
const NEWGAME = "newgame"
const SETTINGS = "settings"
const FIRSTRUN = "firstrun"
const LOADMENU = "loadmenu"
const QUITWARN = "quit"

const WHITE = Color(1, 1, 1)
const BLUE = Color(34/255.0, 71/255.0, 134/255.0)

const GLOBALSAVE = "global.save"

var state = MAIN
var animationplayer
var friederich
var adela
var sound
var loading
var settings
var logo
var main
var options
var newgame
var loadmenu
var quitwarn
var echo = false
var serialization = preload("res://gui/save/Serialization.gd")
var loadclass = preload("res://gui/menu/loadsave.tscn")
var selfclass = preload("res://scenes/global.tscn")

func _ready():
	# Empty built in inputs are not properly removed
	# Delete and re add the inputs to workaround this issue for now
	if InputMap.has_action("ui_focus_next"):
		InputMap.erase_action("ui_focus_next")
	InputMap.add_action("ui_focus_next")
	if InputMap.has_action("ui_focus_prev"):
		InputMap.erase_action("ui_focus_prev")
	InputMap.add_action("ui_focus_prev")
	sound = get_node("sound")
	logo = get_node("CanvasLayer/menu/logo")
	main = get_node("CanvasLayer/menu/main")
	newgame = get_node("CanvasLayer/menu/newgame")
	loadmenu = get_node("CanvasLayer/menu/loadmenu")
	options = main.get_node("options")
	loading = get_node("CanvasLayer/menu/loading")
	settings = get_node("CanvasLayer/menu/settingsmenu")
	settings.get_node("settings").set("is_global", true)
	animationplayer = get_node("AnimationPlayer")
	friederich = get_node("CanvasLayer/menu/BG/friederich")
	adela = get_node("CanvasLayer/menu/BG/adela")
	quitwarn = get_node("CanvasLayer/menu/quit")
	var controls = {}
	for actionid in InputMap.get_actions():
		if (actionid != "ui_accept" && actionid != "ui_cancel"):
			for event in InputMap.get_action_list(actionid):
				if (event.type == InputEvent.KEY):
					controls[actionid] = event.scancode
	Globals.set("controls", controls)
	Globals.set("newcontrols", controls)
	Globals.set("savedir", "user://saves")
	var globaldir = "user://"
	Globals.set("globaldir", globaldir)
	Globals.set("serialization", serialization.new())
	
	# Try to look for and load configuration from global config file
	var dir = Directory.new()
	var file = File.new()
	var global_found = false
	if (dir.dir_exists(globaldir)):
		if(dir.open(globaldir) == 0):
			dir.list_dir_begin()
			var filename = dir.get_next()
			while (filename != "" && !global_found):
				if (!dir.current_is_dir() && filename == GLOBALSAVE):
					var globalsettings = {}
					file.open(globaldir + "/" + filename, File.READ)
					while (!file.eof_reached()):
						var string = file.get_line()
						globalsettings.parse_json(string)
						Globals.set("bgmvolume", globalsettings.bgmvolume)
						Globals.set("sfxvolume", globalsettings.sfxvolume)
						Globals.set("bgmmute", globalsettings.bgmmute)
						Globals.set("sfxmute", globalsettings.sfxmute)
						Globals.set("controls", globalsettings.controls)
						Globals.set("newcontrols", globalsettings.controls)
						Globals.get("serialization").unserialize_controls(globalsettings.controls)
						if (TranslationServer.get_locale() != globalsettings.locale):
							TranslationServer.set_locale(globalsettings.locale)
							translate()
							settings.get_node("language").translate()
					file.close()
					global_found = true
				filename = dir.get_next()
			dir.list_dir_end()
	if (!check_gamesaves()):
		disable_loadmenu()
	settings.get_node("settings").connect("saved", self, "on_settings_saved")
	friederich.hide()
	adela.hide()
	loading.hide()
	loading.connect("complete", self, "gamestart")
	quitwarn.hide()
	get_node("CanvasLayer/menu/BG").set_pos(Vector2(0, 0))
	logo.get_node("Sprite").set_opacity(1)
	set_process_input(true)
	var language = settings.get_node("language")
	language.connect("language_selected", self, "on_language_selected")
	language.connect("translation_changed", self, "translate")
	settings.get_node("settings").reset()
	settings.get_node("settings").update_container()
	if (!global_found):
		# no global config file found
		# do firstrun stuff
		settings.get_node("back").hide()
		settings.get_node("title").set_text(tr("KEY_FIRSTRUN"))
		settings.get_node("language").grab_focus()
		settings.show()
		settings.get_node("settings/sfxslider").set_focus_neighbour(MARGIN_TOP, "")
		logo.hide()
		main.hide()
		newgame.hide()
		state = FIRSTRUN
	else:
		load_backkeys()
		show_menu()
		focus_main()

func load_backkeys():
	settings.get_node("back").set_key("ui_cancel")
	newgame.get_node("backbutton/key").set_text(settings.get_node("back/key").get_text())

func check_gamesaves():
	var dir = Directory.new()
	var file = File.new()
	var savedir = Globals.get("savedir")
	var regex = RegEx.new()
	regex.compile("^save\\d+.save$")
	if (dir.dir_exists(savedir)):
		if(dir.open(savedir) == 0):
			dir.list_dir_begin()
			var filename = dir.get_next()
			while (filename != ""):
				if (!dir.current_is_dir() && regex.find(filename) > -1):
					return true
				filename = dir.get_next()
			dir.list_dir_end()
	return false

func show_menu():
	settings.hide()
	logo.show()
	main.show()
	newgame.hide()

func on_language_selected():
	set_process_input(true)

func hide_settings():
	show_menu()
	options.get_node("settings").grab_focus()

# no game saves available
# go back to main menu
func load_empty():
	state = MAIN
	echo = true
	hide_loadmenu()
	show_menu()
	focus_main()
	disable_loadmenu()
	options.get_node("loadgame/icon").hide()

func disable_loadmenu():
	options.get_node("loadgame").set_disabled(true)

func hide_loadmenu():
	for item in loadmenu.get_children():
		remove_child(item)
		item.queue_free()

func load_game():
	loading.show()
	loading.load_resource("res://scenes/main.tscn")

func _input(event):
	var focus = get_node("CanvasLayer/menu").get_focus_owner()
	if (focus != null && event.is_pressed() && !event.is_echo()):
		if (event.is_action_pressed("ui_cancel")):
			var input_capture = focus.get_parent().get_name() == "inputs" && !focus.get("isfocusable")
			if (state == NEWGAME):
				_on_newgame_back_pressed()
			if (state == LOADMENU):
				var loadmenu_obj = loadmenu.get_node("save")
				if (!loadmenu_obj.get("optionsvisible") && !loadmenu_obj.get("echo")):
					hide_loadmenu()
					show_menu()
					options.get_node("loadgame").grab_focus()
					state = MAIN
				else:
					loadmenu_obj.block_cancel()
			if (state == SETTINGS && !input_capture):
				focus.release_focus()
				hide_settings()
				state = MAIN
			if (state == QUITWARN):
				hide_quit()
		if (event.is_action_pressed("ui_accept") && !echo):
			var playsound = true
			if (state == LOADMENU):
				playsound = false
			if (state == FIRSTRUN || state == SETTINGS):
				if (focus.get_name() != "language"):
					playsound = false
			if (playsound):
				sound.play("confirm")
		echo = false

func on_settings_saved():
	# save settings to global config
	var data = {}
	data.bgmvolume = Globals.get("bgmvolume")
	data.sfxvolume = Globals.get("sfxvolume")
	data.bgmmute = Globals.get("bgmmute")
	data.sfxmute = Globals.get("sfxmute")
	data.controls = Globals.get("controls")
	data.locale = TranslationServer.get_locale()
	var globaldir = Globals.get("globaldir")
	var dir = Directory.new()
	if (!dir.dir_exists(globaldir)):
		dir.make_dir(globaldir)
	var file = File.new()
	file.open(globaldir + "/" + GLOBALSAVE, File.WRITE)
	file.store_string(data.to_json())
	file.close()
	var back = settings.get_node("back")
	get_node("CanvasLayer/menu").get_focus_owner().release_focus()
	if (state == FIRSTRUN):
		settings.get_node("title").set_text(tr("KEY_SETTINGS"))
		load_backkeys()
		back.show()
		show_menu()
		focus_main()
	else:
		back.reload_key()
		newgame.get_node("backbutton/key").set_text(back.get_node("key").get_text())
		hide_settings()
	state = MAIN

func gamestart(resource):
	get_tree().change_scene("res://scenes/main.tscn")

func translate():
	var reference = selfclass.instance()
	var options_ref = reference.get_node("CanvasLayer/menu/main/options")
	var size = options.get_child_count()
	for i in range(0, size):
		options.get_child(i).set_text(tr(options_ref.get_child(i).get_text()))
	var newgame_ref = reference.get_node("CanvasLayer/menu/newgame")
	newgame.get_node("title").set_text(tr(newgame_ref.get_node("title").get_text()))
	newgame.get_node("backbutton/back").set_text(tr(newgame_ref.get_node("backbutton/back").get_text()))
	loading.get_node("text").set_text(tr(reference.get_node("CanvasLayer/menu/loading/text").get_text()))
	var settings_ref = reference.get_node("CanvasLayer/menu/settingsmenu")
	var settings_title = settings_ref.get_node("title").get_text()
	if (state == FIRSTRUN):
		settings_title = "KEY_FIRSTRUN"
	settings.get_node("title").set_text(tr(settings_title))
	settings.get_node("settings/sound").set_text(tr(settings_ref.get_node("settings/sound").get_text()))
	settings.get_node("settings/controls").set_text(tr(settings_ref.get_node("settings/controls").get_text()))
	var settings_input = settings.get_node("settings/inputs")
	var settings_input_ref = settings_ref.get_node("settings/inputs")
	size = settings_input.get_child_count()
	for i in range(0, size):
		var input = settings_input.get_child(i)
		var input_ref = settings_input_ref.get_child(i)
		input.set_text(tr(input_ref.get_text()))
		input.get_node("input").set_text(tr(input_ref.get_node("input").get_text()))
	settings.get_node("settings/save").set_text(tr(settings_ref.get_node("settings/save").get_text()))
	settings.get_node("settings/reset").set_text(tr(settings_ref.get_node("settings/reset").get_text()))
	settings.get_node("back/input").set_text(tr("MAP_BACK"))

# Connect to signals from player interaction with buttons

func focus_newgame():
	newgame.get_node("backbutton/back").grab_focus()

func focus_main():
	options.get_node("newgame").grab_focus()

func _quit_pressed():
	quitwarn.show()
	quitwarn.get_node("options/no").grab_focus()
	state = QUITWARN

func hide_quit():
	quitwarn.hide()
	options.get_node("quitgame").grab_focus()
	state = MAIN

func quit_game():
	get_tree().quit()

func _on_language_pressed():
	settings.get_node("language").select_language()
	set_process_input(false)

func _on_newgame_pressed():
	animationplayer.play("newgame")
	state = NEWGAME

# open loadsave panel
# but in load only mode
func _on_loadgame_pressed():
	main.hide()
	logo.hide()
	var loadmenu_obj = loadclass.instance()
	loadmenu_obj.set("loadonly", true)
	loadmenu_obj.set_pos(Vector2(32, 12))
	loadmenu_obj.get_node("BG").hide()
	loadmenu_obj.get_node("frame").hide()
	loadmenu_obj.connect("empty", self, "load_empty")
	loadmenu_obj.connect("loadgame", self, "load_game")
	loadmenu.add_child(loadmenu_obj)
	state = LOADMENU

func _on_settings_pressed():
	main.hide()
	logo.hide()
	state = SETTINGS
	settings.get_node("settings").update_container()
	settings.show()
	settings.get_node("language").grab_focus()

func _on_newgame_back_pressed():
	get_node("CanvasLayer/menu").get_focus_owner().release_focus()
	animationplayer.play("menu")
	state = MAIN

func _on_friederich_focus_enter():
	friederich.set_modulate(WHITE)
	friederich.raise()
	sound.play("cursor")

func _on_adela_focus_enter():
	adela.set_modulate(WHITE)
	adela.raise()
	sound.play("cursor")

func _on_friederich_focus_exit():
	friederich.set_modulate(BLUE)

func _on_adela_focus_exit():
	adela.set_modulate(BLUE)

func _on_friederich_selected():
	Globals.set("player", "friederich")
	start_newgame()

func _on_adela_selected():
	Globals.set("player", "adela")
	start_newgame()

func start_newgame():
	newgame.hide()
	load_game()

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