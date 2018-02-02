
extends "res://gui/dialogue/choice.gd"

# capture input events while focused

var key
var inputinfo
export var actionid = "ui_up"
var iscapture = false
var isfocusable = true
var focusup
var focusdown
var currentinput
var keymapclass = preload("res://gui/InputCharacters.gd")
var keymap

func _ready():
	keymap = keymapclass.new()
	key = get_node("key")
	inputinfo = get_node("input")
	inputinfo.hide()
	focusup = get_focus_neighbour(MARGIN_TOP)
	focusdown = get_focus_neighbour(MARGIN_BOTTOM)
	update_key()

func update_key():
	var list = InputMap.get_action_list(actionid)
	var is_keyboard = ProjectSettings.get("current_input") == "keyboard"
	for item in list:
		if (is_keyboard && item is InputEventKey):
			currentinput = item
		elif (!is_keyboard && item is InputEventJoypadButton):
			currentinput = item

	if (is_keyboard):
		set_key(currentinput.scancode)
	else:
		set_key(currentinput.button_index)
	key.set("custom_colors/font_color", null)

func set_key(scancode):
	var string = ""
	if (ProjectSettings.get("current_input") == "keyboard"):
		string = OS.get_scancode_string(scancode)
	else:
		string = Input.get_joy_button_string(scancode)
	key.set_text(keymap.map_key(string))

func _input(event):
	var is_keyboard = ProjectSettings.get("current_input") == "keyboard"
	# Help key in demo mode is special; don't overwrite it.
	var helpPressed = (ProjectSettings.get("demomode") && event.is_action_pressed("ui_help"))
	if (!iscapture && event.is_action_pressed("ui_accept") && event.is_pressed() && !event.is_echo()):
		_on_key_pressed()
		sfx.play("cursor")
	elif(iscapture && event.is_pressed() && !event.is_echo() && !helpPressed):
		var inputvalue = ""
		if (event is InputEventKey && is_keyboard):
			inputvalue = "scancode"
		elif (event is InputEventJoypadButton && !is_keyboard):
			inputvalue = "button_index"
		else:
			return

		var keylist = get_parent().get_children()

		# also check to make sure the new input isn't already in use
		for i in keylist:
			# if the key is already in use, swap it
			if (i.get("currentinput")[inputvalue] == event[inputvalue] && i != self):
				i.set("currentinput", currentinput)
				i.set_key(currentinput[inputvalue])
				i.get_node("key").set("custom_colors/font_color", Color(1, 1, 0))
				ProjectSettings.get("newcontrols")[i.get("actionid")] = currentinput[inputvalue]
		if (currentinput[inputvalue] != event[inputvalue]):
			key.set("custom_colors/font_color", Color(1, 1, 0))
		currentinput = event
		ProjectSettings.get("newcontrols")[actionid] = currentinput[inputvalue]
		set_key(currentinput[inputvalue])
		sfx.play("confirm")
		inputinfo.hide()
		iscapture = false
	elif(!iscapture):
		isfocusable = true
		set_focus_neighbour(MARGIN_TOP, focusup)
		set_focus_neighbour(MARGIN_BOTTOM, focusdown)

# commit inputs to InputMap
func set_input():
	var old_event
	var is_keyboard = ProjectSettings.get("current_input") == "keyboard"
	# remove any old inputs
	for e in InputMap.get_action_list(actionid):
		if ((e is InputEventKey && is_keyboard) || (e is InputEventJoypadButton && !is_keyboard)):
			InputMap.action_erase_event(actionid, e)
			old_event = e
	InputMap.action_add_event(actionid, currentinput)
	# also replace mapped inputs.
	# ui_accept maps to ui_attack, ui_magic and ui_blood
	# ui_cancel maps to ui_jump
	if (old_event != null):
		var mapped_action
		var shared_actions
		var newcontrols = ProjectSettings.get("newcontrols")
		if (actionid == "ui_blood" || actionid == "ui_attack" || actionid == "ui_magic"):
			mapped_action = "ui_accept"
			shared_actions = [newcontrols["ui_blood"], newcontrols["ui_attack"], newcontrols["ui_magic"]]
		elif (actionid == "ui_jump"):
			mapped_action = "ui_cancel"
			shared_actions = []
		if (mapped_action != null):
			for e in InputMap.get_action_list(mapped_action):
				# Can't tell from here if previous inputs for this mapped action are already included by another action with the same mapping
				# and happens to have the same scancode as this input
				# so save inputs globally and check those as well
				if ((is_keyboard && e is InputEventKey && e.scancode == old_event.scancode && shared_actions.find(e.scancode) < 0) ||
				(!is_keyboard && e is InputEventJoypadButton && e.button_index == old_event.button_index && shared_actions.find(e.button_index) < 0)):
					InputMap.action_erase_event(mapped_action, e)
			if (!InputMap.action_has_event(mapped_action, currentinput)):
				InputMap.action_add_event(mapped_action, currentinput)

func _on_key_pressed():
	iscapture = true
	isfocusable = false
	inputinfo.show()
	set_focus_neighbour(MARGIN_TOP, ".")
	set_focus_neighbour(MARGIN_BOTTOM, ".")

func _on_key_focus_enter():
	set_process_input(true)

func _on_key_focus_exit():
	set_process_input(false)

