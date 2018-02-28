
extends Node

var map = {	"Up":"CHAR_UP", 
			"Down":"CHAR_DOWN", 
			"Left":"CHAR_LEFT", 
			"Right":"CHAR_RIGHT", 
			"Shift":"CHAR_SHIFT", 
			"Control":"CHAR_CTRL", 
			"Alt":"CHAR_ALT", 
			"Tab":"CHAR_TAB",
			"Escape":"CHAR_ESC",
			"BackSpace":"CHAR_BACKSPACE",
			"Space":"CHAR_SPACE",
			"Return":"CHAR_RETURN",
			"Print":"CHAR_PRINT",
			"Pause":"CHAR_PAUSE",
			"Insert":"CHAR_INS",
			"Delete":"CHAR_DEL",
			"Home":"CHAR_HOME",
			"End":"CHAR_END",
			"PageUp":"CHAR_PAGEUP",
			"PageDown":"CHAR_PAGEDOWN",
			"Meta":"CHAR_META",
			"Kp Enter":"CHAR_ENTER",
			"Enter":"CHAR_ENTER",
			"CapsLock":"CHAR_CAPS",
			"NumLock":"CHAR_NUM",
			"ScrollLock":"CHAR_SCROLL",
			"F1":"CHAR_F1",
			"F2":"CHAR_F2",
			"F3":"CHAR_F3",
			"F4":"CHAR_F4",
			"F5":"CHAR_F5",
			"F6":"CHAR_F6",
			"F7":"CHAR_F7",
			"F8":"CHAR_F8",
			"F9":"CHAR_F9",
			"F10":"CHAR_F10",
			"F11":"CHAR_F11",
			"F12":"CHAR_F12",
			"F13":"CHAR_F13",
			"F14":"CHAR_F14",
			"F15":"CHAR_F15",
			"F16":"CHAR_F16",
			"Kp Multiply":"CHAR_*",
			"Kp Divide":"CHAR_/",
			"Kp Subtract":"CHAR_-",
			"Kp Period":"CHAR_.",
			"Kp Add":"CHAR_+",
			"Kp 0":"CHAR_0",
			"Kp 1":"CHAR_1",
			"Kp 2":"CHAR_2",
			"Kp 3":"CHAR_3",
			"Kp 4":"CHAR_4",
			"Kp 5":"CHAR_5",
			"Kp 6":"CHAR_6",
			"Kp 7":"CHAR_7",
			"Kp 8":"CHAR_8",
			"Kp 9":"CHAR_9",
			"Plus":"CHAR_+",
			"Comma":"CHAR_,",
			"Minus":"CHAR_-",
			"Period":"CHAR_.",
			"Slash":"CHAR_/",
			"0":"CHAR_0",
			"1":"CHAR_1",
			"2":"CHAR_2",
			"3":"CHAR_3",
			"4":"CHAR_4",
			"5":"CHAR_5",
			"6":"CHAR_6",
			"7":"CHAR_7",
			"8":"CHAR_8",
			"9":"CHAR_9",
			"Semicolon":"CHAR_;",
			"Less":"CHAR_<",
			"Equal":"CHAR_=",
			"Apostrophe":"CHAR_'",
			"Asterisk":"CHAR_*",
			"QuoteLeft":"CHAR_`",
			"Acute":"CHAR_´",
			"A":"CHAR_A",
			"B":"CHAR_B",
			"C":"CHAR_C",
			"D":"CHAR_D",
			"E":"CHAR_E",
			"F":"CHAR_F",
			"G":"CHAR_G",
			"H":"CHAR_H",
			"I":"CHAR_I",
			"J":"CHAR_J",
			"K":"CHAR_K",
			"L":"CHAR_L",
			"M":"CHAR_M",
			"N":"CHAR_N",
			"O":"CHAR_O",
			"P":"CHAR_P",
			"Q":"CHAR_Q",
			"R":"CHAR_R",
			"S":"CHAR_S",
			"T":"CHAR_T",
			"U":"CHAR_U",
			"V":"CHAR_V",
			"W":"CHAR_W",
			"X":"CHAR_X",
			"Y":"CHAR_Y",
			"Z":"CHAR_Z",
			"BracketLeft":"CHAR_[",
			"BraceLeft":"CHAR_[",
			"BackSlash":"CHAR_\\",
			"BracketRight":"CHAR_]",
			"BraceRight":"CHAR_]",
			"AsciiCircum":"CHAR_^",
			"Adiaeresis":"CHAR_Ä",
			"Odiaeresis":"CHAR_Ö",
			"Udiaeresis":"CHAR_Ü",
			"NumberSign":"CHAR_#",
			"Ssharp":"CHAR_ß"}

var nintendo = {	"DPAD Up":"GAMEPAD_DUP",
			"DPAD Down":"GAMEPAD_DDOWN",
			"DPAD Left":"GAMEPAD_DLEFT",
			"DPAD Right":"GAMEPAD_DRIGHT",
			"Face Button Bottom":"GAMEPAD_B",
			"Face Button Right":"GAMEPAD_A",
			"Face Button Left":"GAMEPAD_Y",
			"Face Button Top":"GAMEPAD_X",
			"L":"GAMEPAD_L",
			"R":"GAMEPAD_R",
			"L2":"GAMEPAD_ZL",
			"R2":"GAMEPAD_ZR",
			"L3":"GAMEPAD_L3",
			"R3":"GAMEPAD_R3",
			"Select":"GAMEPAD_MINUS",
			"Start":"GAMEPAD_PLUS"}

var playstation = {	"DPAD Up":"GAMEPAD_DUP",
			"DPAD Down":"GAMEPAD_DDOWN",
			"DPAD Left":"GAMEPAD_DLEFT",
			"DPAD Right":"GAMEPAD_DRIGHT",
			"Face Button Bottom":"GAMEPAD_CROSS",
			"Face Button Right":"GAMEPAD_CIRCLE",
			"Face Button Left":"GAMEPAD_SQUARE",
			"Face Button Top":"GAMEPAD_TRIANGLE",
			"L":"GAMEPAD_L1",
			"R":"GAMEPAD_R1",
			"L2":"GAMEPAD_L2",
			"R2":"GAMEPAD_R2",
			"L3":"GAMEPAD_L3",
			"R3":"GAMEPAD_R3",
			"Select":"GAMEPAD_SELECT",
			"Start":"GAMEPAD_START"}

var xbox = {	"DPAD Up":"GAMEPAD_DUP",
			"DPAD Down":"GAMEPAD_DDOWN",
			"DPAD Left":"GAMEPAD_DLEFT",
			"DPAD Right":"GAMEPAD_DRIGHT",
			"Face Button Bottom":"GAMEPAD_A",
			"Face Button Right":"GAMEPAD_B",
			"Face Button Left":"GAMEPAD_X",
			"Face Button Top":"GAMEPAD_Y",
			"L2":"GAMEPAD_LT",
			"R2":"GAMEPAD_RT",
			"L":"GAMEPAD_LB",
			"R":"GAMEPAD_RB",
			"L3":"GAMEPAD_L3",
			"R3":"GAMEPAD_R3",
			"Select":"GAMEPAD_BACK",
			"Start":"GAMEPAD_NEXT"}

var generic = {	"DPAD Up":"GAMEPAD_DUP",
			"DPAD Down":"GAMEPAD_DDOWN",
			"DPAD Left":"GAMEPAD_DLEFT",
			"DPAD Right":"GAMEPAD_DRIGHT",
			"Face Button Bottom":"GAMEPAD_3",
			"Face Button Right":"GAMEPAD_2",
			"Face Button Left":"GAMEPAD_4",
			"Face Button Top":"GAMEPAD_1",
			"L":"GAMEPAD_L",
			"R":"GAMEPAD_R",
			"L2":"GAMEPAD_L2",
			"R2":"GAMEPAD_R2",
			"L3":"GAMEPAD_L3",
			"R3":"GAMEPAD_R3",
			"Select":"GAMEPAD_9",
			"Start":"GAMEPAD_10"}
var gamepads = {"nintendo": nintendo, "playstation": playstation, "xbox": xbox, "generic": generic}

var inputs = ["ui_up", "ui_down", "ui_left", "ui_right", "ui_jump", "ui_attack", "ui_magic", "ui_blood", "ui_spell_prev", "ui_spell_next", "ui_pause", "ui_select", "ui_cancel"]
var keys = {}

func _init():
	update_keys()

func update_keys():
	for i in inputs:
		update_key(i)

func update_key(key):
	for i in InputMap.get_action_list(key):
		if (!ProjectSettings.has_setting("current_input") || ProjectSettings.get("current_input") == "keyboard"):
			if (i is InputEventKey):
				keys[key] = i.scancode
		else:
			if (i is InputEventJoypadButton):
				keys[key] = i.button_index

func map_action(action):
	if (!ProjectSettings.has_setting("current_input") || ProjectSettings.get("current_input") == "keyboard"):
		return map_key(OS.get_scancode_string(keys[action]))
	return map_key(Input.get_joy_button_string(keys[action]))

func map_key(input):
	var current_input = "keyboard"
	if (ProjectSettings.has_setting("current_input")):
		current_input = ProjectSettings.get("current_input")
	if (current_input == "keyboard" || current_input == null):
		if (map.has(input)):
			return tr(map[input])
	else:
		if (gamepads[current_input].has(input)):
			return tr(gamepads[current_input][input])
	return input
