
extends "res://gui/menu/MenuContent.gd"

# allow players to adjust settings for sounds and controls

var sfxslider
var bgmslider

var sfxMute = false
var bgmMute = false

var sfxValue
var bgmValue

func _ready():
	has_content = true
	if (!Globals.has("sfxvolume")):
		Globals.set("sfxvolume", 1)
	if (!Globals.has("bgmvolume")):
		Globals.set("bgmvolume", 1)
	sfxValue = Globals.get("sfxvolume")
	bgmValue = Globals.get("bgmvolume")
	sfxslider = get_node("sfxslider")
	bgmslider = get_node("bgmslider")

func update_container():
	sfxValue = Globals.get("sfxvolume")
	bgmValue = Globals.get("bgmvolume")
	sfxslider.set_val(sfxValue)
	bgmslider.set_val(bgmValue)
	if (!Globals.has("sfxmute")):
		Globals.set("sfxmute", false)
	sfxMute = Globals.get("sfxmute")
	if (!Globals.has("bgmmute")):
		Globals.set("bgmmute", false)
	bgmMute = Globals.get("bgmmute")
	update_mute_controls()
	var resetwidth = get_node("reset").get_size().x
	get_node("reset").set_pos(Vector2(704 - resetwidth, get_node("reset").get_pos().y))

func _on_sfxslider_value_changed( value ):
	if (!sfxMute):
		AudioServer.set_fx_global_volume_scale(value)

func _on_bgmslider_value_changed( value ):
	if (!bgmMute):
		AudioServer.set_stream_global_volume_scale(value)

func unfocus_all():
	reset()
	if (get_focus_owner() != null):
		get_focus_owner().release_focus()

func reset():
	sfxMute = Globals.get("sfxmute")
	bgmMute = Globals.get("bgmmute")
	var sfx = sfxValue
	if (sfxMute):
		sfx = 0
	var bgm = bgmValue
	if (bgmMute):
		bgm = 0
	update_mute_controls()
	AudioServer.set_fx_global_volume_scale(sfx)
	AudioServer.set_stream_global_volume_scale(bgm)
	sfxslider.set_val(sfxValue)
	bgmslider.set_val(bgmValue)
	for key in get_node("inputs").get_children():
		key.update_key()

func update_mute_controls():
	if (sfxMute):
		sfxslider.set_self_opacity(0.5)
	else:
		sfxslider.set_self_opacity(1)
	if (bgmMute):
		bgmslider.set_self_opacity(0.5)
	else:
		bgmslider.set_self_opacity(1)

func save():
	sfxValue = sfxslider.get_val()
	bgmValue = bgmslider.get_val()
	Globals.set("sfxvolume", sfxValue)
	Globals.set("bgmvolume", bgmValue)
	Globals.set("sfxmute", sfxMute)
	Globals.set("bgmmute", bgmMute)
	for key in get_node("inputs").get_children():
		key.set_input()

func _on_sfxslider_focus_exit():
	if (get_focus_owner() != null && get_focus_owner() == get_parent().get_node("tabs/HBoxContainer/settings")):
		unfocus_all()

func _on_reset_pressed():
	reset()

func _on_save_pressed():
	save()

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
		sfxMute = !sfxMute
		if (sfxMute):
			AudioServer.set_fx_global_volume_scale(0)
			sfxslider.set_self_opacity(0.5)
		else:
			AudioServer.set_fx_global_volume_scale(sfxValue)
			sfxslider.set_self_opacity(1)

func _on_bgmslider_input_event( ev ):
	if (ev.is_action_pressed("ui_accept") && ev.is_pressed() && !ev.is_echo()):
		bgmMute = !bgmMute
		if (bgmMute):
			AudioServer.set_stream_global_volume_scale(0)
			bgmslider.set_self_opacity(0.5)
		else:
			AudioServer.set_stream_global_volume_scale(bgmValue)
			bgmslider.set_self_opacity(1)
