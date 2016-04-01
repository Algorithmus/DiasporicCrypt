
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
var keymapclass = preload("res://gui/KeyboardCharacters.gd")
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
	for item in list:
		if (item.type == InputEvent.KEY):
			currentinput = item

	set_key(currentinput.scancode)
	key.set("custom_colors/font_color", null)

func set_key(scancode):
	key.set_text(keymap.map_key(OS.get_scancode_string(scancode)))

func _input(event):
	if (!iscapture && event.is_action_pressed("ui_accept") && event.is_pressed() && !event.is_echo()):
		_on_key_pressed()
		sfx.play("cursor")
	elif(iscapture && event.type == InputEvent.KEY && event.is_pressed() && !event.is_echo()):
		sfx.play("confirm")
		inputinfo.hide()
		var keylist = get_parent().get_children()
		# also check to make sure the new input isn't already in use
		for i in keylist:
			# if the key is already in use, swap it
			if (i.get("currentinput").scancode == event.scancode && i != self):
				i.set("currentinput", currentinput)
				i.set_key(currentinput.scancode)
				i.get_node("key").set("custom_colors/font_color", Color(1, 1, 0))
		if (currentinput.scancode != event.scancode):
			key.set("custom_colors/font_color", Color(1, 1, 0))
		currentinput = event
		set_key(currentinput.scancode)
		iscapture = false
	elif(!iscapture):
		isfocusable = true
		set_focus_neighbour(MARGIN_TOP, focusup)
		set_focus_neighbour(MARGIN_BOTTOM, focusdown)

# commit inputs to InputMap
func set_input():
	var old_event
	# remove any old inputs
	for e in InputMap.get_action_list(actionid):
		if (e.type == InputEvent.KEY):
			InputMap.action_erase_event(actionid, e)
			old_event = e
	InputMap.action_add_event(actionid, currentinput)
	# also replace mapped inputs.
	# ui_accept maps to ui_attack, ui_magic and ui_blood
	# ui_cancel maps to ui_jump
	if (old_event != null):
		var mapped_action
		if (actionid == "ui_blood" || actionid == "ui_attack" || actionid == "ui_magic"):
			mapped_action = "ui_accept"
		elif (actionid == "ui_jump"):
			mapped_action = "ui_cancel"
		if (mapped_action != null):
			for e in InputMap.get_action_list(mapped_action):
				if (e.type == InputEvent.KEY && e.scancode == old_event.scancode):
					InputMap.action_erase_event(mapped_action, e)
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
