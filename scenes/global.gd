extends Node

# Global menu entry point into game

const MAIN = "main"
const NEWGAME = "newgame"
const SETTINGS = "settings"
const INFO = "info"
const FIRSTRUN = "firstrun"
const LOADMENU = "loadmenu"
const QUITWARN = "quit"

const GLOBALSAVE = "global.save"

var state = MAIN
var animationplayer
var friederich
var adela
var sound
var loading
var settings
var info
var licenses
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
var currentline = 0

const gamepad_names = {
"Xbox Gamepad (userspace driver)": "xbox",
"RetroUSB.com RetroPad": "nintendo",
"RetroUSB.com Super RetroPort": "nintendo",
"hori": "playstation",
"HORI CO.,LTD. FIGHTING STICK 3": "playstation",
"HORI CO.,LTD. REAL ARCADE Pro.V3": "playstation",
"HORI Gem Pad 3": "playstation",
"Twin USB PS2 Adapter": "playstation",
"NEXT Classic USB Game Controller": "nintendo",
"Sony PS2 pad with SmartJoy adapter": "playstation",
"GameCube {WiseGroup USB box}": "nintendo",
"Gravis GamePad Pro USB": "nintendo",
"GameCube {HuiJia USB box}": "nintendo",
"Mad Catz Wired Xbox 360 Controller": "xbox",
"PS3 Controller": "playstation",
"Sony DualShock 4 Wireless Adaptor": "playstation",
"Sony DualShock 4": "playstation",
"Sony Computer Entertainment Wireless Controller": "playstation",
"Sony DualShock 4 V2": "playstation",
"Thrustmaster Firestorm Dual Power": "generic",
"Thrustmaster Run N Drive  Wireless": "playstation",
"Thrustmaster Run N Drive Wireless PS3": "playstation",
"Thrustmaster Dual Analog 4": "generic",
"Thrustmaster 2 in 1 DT": "playstation",
"Thrustmaster Dual Trigger 3-in-1": "playstation",
"X360 Wireless Controller": "xbox",
"Microsoft X-Box pad (Japan)": "xbox",
"Microsoft X-Box pad v2 (US)": "xbox",
"Microsoft X-Box 360 pad": "xbox",
"X360 Controller": "xbox",
"SpeedLink XEOX Pro Analog Gamepad pad": "playstation",
"Speedlink TORID Wireless Gamepad": "xbox",
"Microsoft X-Box One pad": "xbox",
"Microsoft X-Box One pad v2": "xbox",
"Super Joy Box 5 Pro": "playstation",
"Logitech WingMan Cordless RumblePad": "xbox",
"Logitech Logitech Dual Action": "generic",
"Logitech F310 Gamepad (DInput)": "xbox",
"Logitech Logitech RumblePad 2 USB": "generic",
"Logitech Cordless RumblePad 2": "generic",
"Logitech F710 Gamepad (DInput)": "xbox",
"Logitech F310 Gamepad (XInput)": "xbox",
"Logitech F510 Gamepad (XInput)": "xbox",
"Logitech F710 Gamepad (XInput)": "xbox",
"JC-U3613M - DirectInput Mode": "xbox",
"Logic3 Controller": "generic",
"Generic X-Box pad": "xbox",
"Rock Candy Gamepad for PS3": "playstation",
"PDP Rock Candy Wireless Controller for PS3": "playstation",
"EA Sports PS3 Controller for": "playstation",
"Afterglow Wired Controller for Xbox One": "xbox",
"Rock Candy Wired Controller for XBox One": "xbox",
"DragonRise Inc. Generic USB Joystick": "generic",
"Retrolink Classic Controller": "nintendo",
"RetroLink Saturn Classic Controller": "nintendo",
"iBuffalo USB 2-axis 8-button Gamepad": "nintendo",
"Razer Onza Tournament": "xbox",
"Razer Onza Classic Edition": "xbox",
"GreenAsia Inc. USB Joystick": "playstation",
"Saitek P880": "generic",
"Saitek P2900 Wireless Pad": "generic",
"Saitek PLC Saitek P3200 Rumble Pad": "xbox",
"Saitek Cyborg V.1 Game Pad": "generic",
"Hori Pad EX Turbo 2": "xbox",
"Mad Catz XBox 360 Controller": "xbox",
"Mad Catz Fightpad SFxT": "xbox",
"Jess Technology USB Game Controller": "generic",
"Tomee SNES USB Controller": "nintendo",
"HJC Game GAMEPAD": "xbox",
"Toodles 2008 Chimp PC/PS3": "playstation",
"HitBox (PS3/PC) Analog Mode": "playstation",
"Valve Streaming Gamepad": "xbox",
"Goodbetterbest Ltd USB Controller": "generic",
"InterAct GoPad I-73000 (Fighting Game Layout)": "nintendo",
"3dfx InterAct HammerHead FX": "nintendo",
"Nintendo Wiimote": "nintendo",
"8Bitdo SFC30 GamePad": "nintendo",
"OUYA Game Controller": "generic",
"Mad Catz C.T.R.L.R ": "xbox",
"GameStop Gamepad": "generic",
"PS3 Controller (Bluetooth)": "playstation",
"PS4 Controller (Bluetooth)": "playstation",
"Sony DualShock 4 V2 BT": "playstation",
"Nintendo Wii U Pro Controller": "nintendo",
"8Bitdo Zero GamePad": "xbox",
"VR-BOX": "generic",
"Moga Pro": "xbox",
"Piranha xtreme": "generic",
"Gamestop BB-070 X360 Controller": "xbox",
"Sega Saturn USB Gamepad": "nintendo",
"Sega Saturn": "nintendo",
"G-Shark GP-702": "generic",
"Mayflash WiiU Pro Game Controller Adapter (DInput)": "nintendo",
"Xbox Wireless Controller": "xbox",
"Thrustmaster Dual Analog 3.2": "xbox",
"SFC30 Joystick": "nintendo",
"Mayflash Wii Classic Controller": "nintendo",
"HORIPAD FPS PLUS 4": "playstation",
"Wii U Pro Controller": "nintendo",
"Wii Remote": "nintendo",
"SVEN X-PAD": "playstation",
"Gembird JPD-DualForce": "generic",
"PowerA Pro Ex": "playstation",
"Saitek P2500": "generic",
"Mayflash Wiimote PC Adapter": "nintendo",
"Acme": "generic",
"Multilaser JS071 USB": "playstation",
"Generic Speedlink": "playstation",
"Mayflash GameCube Controller Adapter": "nintendo",
"NGS Phantom": "generic",
"Logitech RumblePad 2 USB": "generic",
"Dual Trigger 3-in-1": "playstation",
"NYKO AIRFLO": "generic",
"Ipega PG-9023": "xbox",
"OUYA Controller": "generic",
"Afterglow PS3 Controller": "playstation",
"EXEQ RF USB Gamepad 8206": "xbox",
"Saitek P480 Rumble Pad": "playstation",
"GamePad Pro USB": "nintendo",
"PS3 DualShock": "playstation",
"8Bitdo NES30 PRO Wireless": "nintendo",
"PS2 USB": "playstation",
"PS1 USB": "playstation",
"HORIPAD 4": "playstation",
"Hatsune Miku Sho Controller": "playstation",
"8Bitdo NES30 Pro USB": "nintendo",
}

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
	info = get_node("CanvasLayer/menu/info")
	licenses = info.get_node("container").get_bbcode()
	info.get_node("container").set_bbcode(parse_info() + licenses)
	animationplayer = get_node("AnimationPlayer")
	friederich = get_node("CanvasLayer/menu/BG/friederich")
	adela = get_node("CanvasLayer/menu/BG/adela")
	quitwarn = get_node("CanvasLayer/menu/quit")
	var controls = {}
	var gamepad = {}
	var keyboard = {}
	var joystick_supported = Input.get_connected_joypads().size() > 0
	if (joystick_supported):
		var gamepad_name = Input.get_joy_name(Input.get_connected_joypads()[0])
		var layout = "generic"
		if (gamepad_names.has(gamepad_name)):
			layout = gamepad_names[gamepad_name]
		ProjectSettings.set("current_input", layout)
	else:
		ProjectSettings.set("current_input", "keyboard")
	settings.get_node("settings").set_layout_index(ProjectSettings.get("current_input"))
	settings.get_node("settings").update_container()
	for actionid in InputMap.get_actions():
		if (actionid != "ui_accept" && actionid != "ui_cancel"):
			for event in InputMap.get_action_list(actionid):
				if (event is InputEventJoypadButton):
					if (joystick_supported):
						controls[actionid] = event.button_index
					gamepad[actionid] = event.button_index
				if (event is InputEventKey):
					if (!joystick_supported):
						controls[actionid] = event.scancode
					keyboard[actionid] = event.scancode
	ProjectSettings.set("debugmode", true)
	ProjectSettings.set("demomode", false)
	ProjectSettings.set("controls", controls)
	ProjectSettings.set("keyboard_controls", keyboard)
	ProjectSettings.set("gamepad_controls", gamepad)
	ProjectSettings.set("newcontrols", controls)
	ProjectSettings.set("savedir", "user://saves")
	var globaldir = "user://"
	ProjectSettings.set("globaldir", globaldir)
	ProjectSettings.set("serialization", serialization.new())
	
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
						ProjectSettings.set("bgmvolume", globalsettings.bgmvolume)
						ProjectSettings.set("sfxvolume", globalsettings.sfxvolume)
						ProjectSettings.set("bgmmute", globalsettings.bgmmute)
						ProjectSettings.set("sfxmute", globalsettings.sfxmute)
						ProjectSettings.set("keyboard_controls", globalsettings.keyboard)
						ProjectSettings.set("gamepad_controls", globalsettings.gamepad)
						# Only set the requested gamepad layout if gamepad is connected
						if (joystick_supported):
							ProjectSettings.set("controls", globalsettings.gamepad)
						else:
							ProjectSettings.set("controls", globalsettings.keyboard)
						ProjectSettings.set("newcontrols", ProjectSettings.get("controls"))
						ProjectSettings.get("serialization").unserialize_controls(globalsettings.keyboard, true)
						ProjectSettings.get("serialization").unserialize_controls(globalsettings.gamepad, false)
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
	settings.get_node("settings").connect("nogamepad", self, "reload_backkeys")
	friederich.hide()
	adela.hide()
	loading.hide()
	loading.connect("complete", self, "gamestart")
	quitwarn.hide()
	get_node("CanvasLayer/menu/BG").set_position(Vector2(0, 0))
	logo.get_node("Sprite").modulate.a = 1
	set_process_input(true)
	var language = settings.get_node("language")
	language.connect("language_selected", self, "on_language_selected")
	language.connect("translation_changed", self, "translate")
	settings.get_node("settings").reset()
	settings.get_node("settings").update_container()
	var info_container = info.get_node("container")
	var info_button = get_node("CanvasLayer/menu/main/info")
	if (!global_found || ProjectSettings.get("demomode")):
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
		info.hide()
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
	var savedir = ProjectSettings.get("savedir")
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
	info.hide()
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
			if (state == INFO):
				_on_info_back_pressed()
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
				#TODO - play sounds properly
				#sound.play("confirm")
				pass
			echo = false
	if ((event.is_action("ui_down") || event.is_action("ui_up")) && state == INFO):
		var container = info.get_node("container")
		if (event.is_action("ui_down") && container.get_v_scroll().get_max() > container.get_v_scroll().get_value() + container.get_size().y):
			currentline += 1
		elif (event.is_action("ui_up")):
			currentline -= 1
		currentline = max(currentline, 0)
		info.get_node("container").scroll_to_line(currentline)

func on_settings_saved():
	# save settings to global config
	var data = {}
	data.bgmvolume = ProjectSettings.get("bgmvolume")
	data.sfxvolume = ProjectSettings.get("sfxvolume")
	data.bgmmute = ProjectSettings.get("bgmmute")
	data.sfxmute = ProjectSettings.get("sfxmute")
	data.keyboard = ProjectSettings.get("keyboard_controls")
	data.gamepad = ProjectSettings.get("gamepad_controls")
	data.locale = TranslationServer.get_locale()
	var globaldir = ProjectSettings.get("globaldir")
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
		reload_backkeys()
		hide_settings()
	state = MAIN

func reload_backkeys():
	var back = settings.get_node("back")
	if (back.get("actionid") == null):
		load_backkeys()
	back.reload_key()
	newgame.get_node("backbutton/key").set_text(back.get_node("key").get_text())

func gamestart(resource):
	get_tree().change_scene("res://scenes/main.tscn")

func parse_info():
	var translation = tr("KEY_INFO")
	return translation.replace("[break]", "\n")

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
	var info_ref = reference.get_node("CanvasLayer/menu/info")
	info.get_node("backbutton/back").set_text(tr(info_ref.get_node("backbutton/back").get_text()))
	info.get_node("container").set_bbcode(parse_info() + licenses)
	size = settings_input.get_child_count()
	for i in range(0, size):
		var input = settings_input.get_child(i)
		var input_ref = settings_input_ref.get_child(i)
		input.set_text(tr(input_ref.get_text()))
		input.get_node("input").set_text(tr(input_ref.get_node("input").get_text()))
	settings.get_node("settings/save").set_text(tr(settings_ref.get_node("settings/save").get_text()))
	settings.get_node("settings/reset").set_text(tr(settings_ref.get_node("settings/reset").get_text()))
	var layouts = settings.get_node("settings").get("layouts")
	var index = settings.get_node("settings").get("layout_index")
	settings.get_node("settings/layout").set_text(tr(layouts[index].name))
	settings.get_node("back/input").set_text(tr("MAP_BACK"))
	var quit = get_node("CanvasLayer/menu/quit")
	var quit_ref = reference.get_node("CanvasLayer/menu/quit")
	quit.get_node("text").set_text(tr(quit_ref.get_node("text").get_text()))
	quit.get_node("options/yes").set_text(tr(quit_ref.get_node("options/yes").get_text()))
	quit.get_node("options/no").set_text(tr(quit_ref.get_node("options/no").get_text()))

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
	loadmenu_obj.set_position(Vector2(32, 12))
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
	friederich.modulate.a = 1
	friederich.raise()
	sound.play("cursor")

func _on_adela_focus_enter():
	adela.modulate.a = 1
	adela.raise()
	sound.play("cursor")

func _on_friederich_focus_exit():
	friederich.modulate.a = 0

func _on_adela_focus_exit():
	adela.modulate.a = 0

func _on_friederich_selected():
	ProjectSettings.set("player", "friederich")
	start_newgame()

func _on_adela_selected():
	ProjectSettings.set("player", "adela")
	start_newgame()

func start_newgame():
	newgame.hide()
	load_game()

# ProjectSettings with preloaded assets are not cleared properly. Until this is
# fixed, we are clearing them manually ourselves.
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		ProjectSettings.set("magic_spells", null)
		ProjectSettings.set("itemfactory", null)
		ProjectSettings.set("levels", null)
		ProjectSettings.set("inventory", null)
		ProjectSettings.set("scrolls", null)
		ProjectSettings.set("shops", null)
		ProjectSettings.set("mapobjects", null)
		ProjectSettings.set("mapindex", null)
		ProjectSettings.set("available_spells", null)
		get_tree().quit()

func _on_info_pressed():
	main.hide()
	state = INFO
	currentline = 0
	info.get_node("container").scroll_to_line(currentline)
	info.show()
	info.get_node("backbutton/back").grab_focus()

func _on_info_back_pressed():
	get_node("CanvasLayer/menu/main/info").grab_focus()
	info.hide()
	main.show()
	state = MAIN
