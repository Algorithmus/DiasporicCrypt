
extends "res://gui/menu/MenuContent.gd"

# allow players to adjust settings for sounds and controls

var sfxslider
var bgmslider

var sfxMute = false
var bgmMute = false

var sfxValue
var bgmValue

var mute = preload("res://gui/menu/icons/mute.png")
var sound = preload("res://gui/menu/icons/sound.png")
var sfxclass = preload("res://gui/menu/sfx.tscn")
var AudioFunctions = preload("res://gui/AudioFunctions.gd")
var sfx

var is_global = false

var layouts = [{"id": "keyboard", "name": "INPUT_KEYBOARD"},
	{"id": "nintendo", "name": "INPUT_NINTENDO"},
	{"id": "playstation", "name": "INPUT_PLAYSTATION"},
	{"id": "xbox", "name": "INPUT_XBOX"},
	{"id": "generic", "name": "INPUT_GENERIC"}
]
var layout_index = 0
var old_layout_index = 0

signal saved
signal nogamepad

func _ready():
	detect_gamepad()
	set_layout_index(ProjectSettings.get("current_input"))
	has_content = true
	if (!ProjectSettings.has_setting("sfxvolume")):
		ProjectSettings.set("sfxvolume", 1)
	if (!ProjectSettings.has_setting("bgmvolume")):
		ProjectSettings.set("bgmvolume", 1)
	sfxValue = ProjectSettings.get("sfxvolume")
	bgmValue = ProjectSettings.get("bgmvolume")
	sfxslider = get_node("sfxslider")
	bgmslider = get_node("bgmslider")
	sfx = sfxclass.instance()
	add_child(sfx)
	set_process_input(false)

func detect_gamepad():
	if (Input.get_connected_joypads().size() == 0):
		ProjectSettings.set("current_input", "keyboard")
		set_layout_index(ProjectSettings.get("current_input"))
		get_node("layout").set_disabled(true)
		emit_signal("nogamepad")
	else:
		get_node("layout").set_disabled(false)

func update_container():
	detect_gamepad()
	sfxValue = ProjectSettings.get("sfxvolume")
	bgmValue = ProjectSettings.get("bgmvolume")
	sfxslider.value = sfxValue
	bgmslider.value = bgmValue
	if (!ProjectSettings.has_setting("sfxmute")):
		ProjectSettings.set("sfxmute", false)
	sfxMute = ProjectSettings.get("sfxmute")
	if (!ProjectSettings.has_setting("bgmmute")):
		ProjectSettings.set("bgmmute", false)
	bgmMute = ProjectSettings.get("bgmmute")
	sfxMute = ProjectSettings.get("sfxmute")
	update_mute_controls()
	get_node("layout").set_text(tr(layouts[old_layout_index].name))
	for key in get_node("inputs").get_children():
		key.update_key()
	if (ProjectSettings.get("controls") != null):
		ProjectSettings.set("newcontrols", ProjectSettings.get("controls").duplicate())
	var resetwidth = get_node("reset").get_size().x
	get_node("reset").set_position(Vector2(689 - resetwidth, get_node("reset").get_position().y))

func _on_sfxslider_value_changed( value ):
	if (!sfxMute):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), AudioFunctions.scale_to_db(value))

func _on_bgmslider_value_changed( value ):
	if (!bgmMute):
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), AudioFunctions.scale_to_db(value))

func unfocus_all():
	reset()
	if (get_focus_owner() != null):
		get_focus_owner().release_focus()

func reset_content():
	reset()

func reset():
	sfxMute = ProjectSettings.get("sfxmute")
	bgmMute = ProjectSettings.get("bgmmute")
	var sfx_index = AudioServer.get_bus_index("SFX")
	var bgm_index = AudioServer.get_bus_index("BGM")
	var sfx = sfxValue
	if (sfxMute):
		AudioServer.set_bus_mute(sfx_index, true)
	else:
		AudioServer.set_bus_mute(sfx_index, false)
	var bgm = bgmValue
	if (bgmMute):
		AudioServer.set_bus_mute(bgm_index, true)
	else:
		AudioServer.set_bus_mute(bgm_index, false)
	update_mute_controls()
	AudioServer.set_bus_volume_db(sfx_index, AudioFunctions.scale_to_db(sfx))
	AudioServer.set_bus_volume_db(bgm_index, AudioFunctions.scale_to_db(bgm))
	sfxslider.value = sfxValue
	bgmslider.value = bgmValue
	layout_index = old_layout_index
	get_node("layout").set_text(tr(layouts[old_layout_index].name))
	ProjectSettings.set("current_input", layouts[old_layout_index].id)
	for key in get_node("inputs").get_children():
		key.update_key()
	ProjectSettings.set("newcontrols", ProjectSettings.get("controls").duplicate())

func update_mute_controls():
	if (sfxMute):
		sfxslider.self_modulate.a = 0.5
		sfxslider.get_node("mute").set_texture(mute)
	else:
		sfxslider.self_modulate.a = 1
		sfxslider.get_node("mute").set_texture(sound)
	if (bgmMute):
		bgmslider.self_modulate.a = 0.5
		bgmslider.get_node("mute").set_texture(mute)
	else:
		bgmslider.self_modulate.a = 1
		bgmslider.get_node("mute").set_texture(sound)

func save():
	sfxValue = sfxslider.value
	bgmValue = bgmslider.value
	ProjectSettings.set("sfxvolume", sfxValue)
	ProjectSettings.set("bgmvolume", bgmValue)
	ProjectSettings.set("sfxmute", sfxMute)
	ProjectSettings.set("bgmmute", bgmMute)
	ProjectSettings.set("controls", ProjectSettings.get("newcontrols").duplicate())
	if (ProjectSettings.get("current_input") == "keyboard"):
		ProjectSettings.set("keyboard_controls", ProjectSettings.get("controls").duplicate())
	else:
		ProjectSettings.set("gamepad_controls", ProjectSettings.get("controls").duplicate())
	for key in get_node("inputs").get_children():
		key.set_input()
		key.get_node("key").set("custom_colors/font_color", null)
	old_layout_index = layout_index
	emit_signal("saved")

func _on_sfxslider_focus_exit():
	if (get_focus_owner() != null && get_focus_owner() == get_parent().get_node("tabs/HBoxContainer/settings")):
		unfocus_all()

func _on_reset_pressed():
	reset()
	sfx.get_node("confirm").play()

func _on_save_pressed():
	save()
	sfx.get_node("confirm").play()

func block_cancel():
	# block focusing on tabs while capturing input
	for i in get_node("inputs").get_children():
		if (!i.get("isfocusable")):
			return true
	return false

func block_pause():
	# also block pause button as well during capture
	return block_cancel()

func _on_sfxslider_input_event( ev ):
	if (ev.is_action_pressed("ui_accept") && ev.is_pressed() && !ev.is_echo()):
		var sfx_index = AudioServer.get_bus_index("SFX")
		sfxMute = !sfxMute
		if (sfxMute):
			AudioServer.set_bus_mute(sfx_index, true)
			sfxslider.self_modulate.a = 0.5
			sfxslider.get_node("mute").set_texture(mute)
		else:
			AudioServer.set_bus_mute(sfx_index, false)
			AudioServer.set_bus_volume_db(sfx_index, AudioFunctions.scale_to_db(sfxslider.value))
			sfxslider.self_modulate.a = 1
			sfxslider.get_node("mute").set_texture(sound)

func _on_bgmslider_input_event( ev ):
	if (ev.is_action_pressed("ui_accept") && ev.is_pressed() && !ev.is_echo()):
		var bgm_index = AudioServer.get_bus_index("BGM")
		bgmMute = !bgmMute
		if (bgmMute):
			AudioServer.set_bus_mute(bgm_index, true)
			bgmslider.self_modulate.a = 0.5
			bgmslider.get_node("mute").set_texture(mute)
		else:
			AudioServer.set_bus_mute(bgm_index, false)
			AudioServer.set_bus_volume_db(bgm_index, AudioFunctions.scale_to_db(bgmslider.value))
			bgmslider.self_modulate.a = 1
			bgmslider.get_node("mute").set_texture(sound)

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		var old_index = layout_index
		if (event.is_action_pressed("ui_left")):
			layout_index -= 1
			if (layout_index < 0):
				layout_index = layouts.size() - 1
		elif (event.is_action_pressed("ui_right")):
			layout_index += 1
			if (layout_index >= layouts.size()):
				layout_index = 0

		if (old_index != layout_index):
			get_node("layout").set_text(tr(layouts[layout_index].name))
			var current_input = layouts[layout_index].id
			ProjectSettings.set("current_input", current_input)
			for key in get_node("inputs").get_children():
				key.update_key()
			if (current_input == "keyboard"):
				ProjectSettings.set("controls", ProjectSettings.get("keyboard_controls").duplicate())
			else:
				ProjectSettings.set("controls", ProjectSettings.get("gamepad_controls").duplicate())
			ProjectSettings.set("newcontrols", ProjectSettings.get("controls").duplicate())

func set_layout_index(id):
	var size = layouts.size()
	for i in range(0, size):
		if (layouts[i].id == id):
			layout_index = i
			old_layout_index = i

func _on_layout_focus_enter():
	set_process_input(true)

func _on_layout_focus_exit():
	set_process_input(false)
