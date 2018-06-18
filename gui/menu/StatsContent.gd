
extends "res://gui/menu/MenuContent.gd"

# display character stats and gold
var shield
var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	has_content = true
	sfx = sfxclass.instance()
	add_child(sfx)
	shield = get_node("shield")
	shield.hide()

func update_container():
	var title
	if (ProjectSettings.get("player") == "friederich"):
		get_node("profile_a").hide()
		get_node("profile_f").show()
		title = "Friederich "
	else:
		get_node("profile_a").show()
		get_node("profile_f").hide()
		title = "Adela "

	var player = get_tree().get_root().get_node("world/playercontainer/player")

	title = title + tr("STATS_LEVEL") + " " + str(player.get("level"))

	var current_hp = str(player.get("current_hp"))
	if (player.get("current_hp") / float(player.get("hp")) <= 0.1):
		current_hp = "[color=red]" + current_hp + "[/color]"

	var hp = current_hp + "/" + str(player.get("hp"))
	var mp = str(player.get("current_mp")) + "/" + str(player.get("mp"))
	var atk = str(player.get("base_atk"))
	var def = str(player.get("base_def"))
	var mag = str(player.get("base_mag"))
	var luck = str(player.get("base_luck"))
	
	var hpbonus = ""
	var mpbonus = ""

	var styx_bonus = ProjectSettings.get("bonus_effects")

	if (player.get("is_demonic")):
		hpbonus = "([color=yellow]+" + str(round(player.get("demonic_hp") * 100) + int(styx_bonus.hp) * 10) + "%[/color])"
		mpbonus = "([color=yellow]+" + str(round(player.get("demonic_mp") * 100) + int(styx_bonus.mp) * 10) + "%[/color])"
		atk = atk + " + [color=yellow]" + str(round(player.get("demonic_atk") * 100) + int(styx_bonus.atk) * 10) + "%[/color]"
		def = def + " + [color=yellow]" + str(round(player.get("demonic_def") * 100) + int(styx_bonus.def) * 10) + "%[/color]"
		mag = mag + " + [color=yellow]" + str(round(player.get("demonic_mag") * 100) + int(styx_bonus.mag) * 10) + "%[/color]"
		luck = luck + " + [color=yellow]" + str(round(player.get("demonic_luck") * 100) + int(styx_bonus.luck) * 10) + "%[/color]"
	else:
		var bonustext = " + [color=yellow]10%[/color]"
		var bonustextp = "([color=yellow]+10%[/color])"
		if (player.get("styx_atk") > 0):
			atk = atk + bonustext
		if (player.get("styx_def") > 0):
			def = def + bonustext
		if (player.get("styx_mag") > 0):
			mag = mag + bonustext
		if (player.get("styx_luck") > 0):
			luck = luck + bonustext
		if (player.get("styx_hp") > 0):
			hpbonus = bonustextp
		if (player.get("styx_mp") > 0):
			mpbonus = bonustextp

	var exp_obj = player.get("exp_growth_obj")
	var ep = str(exp_obj.get("total_exp"))
	var required = str(exp_obj.get("exp_required") - exp_obj.get("current_exp"))
	
	var infostring = tr("STATS_ALL").replace("[break]", "\n")
	infostring = infostring.replace("[hp]", hp)
	infostring = infostring.replace("[mp]", mp)
	infostring = infostring.replace("[hpbonus]", hpbonus)
	infostring = infostring.replace("[mpbonus]", mpbonus)
	infostring = infostring.replace("[atk]", atk)
	infostring = infostring.replace("[def]", def)
	infostring = infostring.replace("[mag]", mag)
	infostring = infostring.replace("[luck]", luck)
	infostring = infostring.replace("[exp]", ep)
	infostring = infostring.replace("[rexp]", required)
	infostring = infostring.replace("[gold]", str(ProjectSettings.get("gold")))
	
	get_node("title").set_text(title)
	get_node("info").set_bbcode(infostring)

func _on_quit():
	sfx.get_node("confirm").play()
	shield.show()
	shield.get_node("options/no").grab_focus()

func block_cancel():
	return shield.is_visible()

func block_pause():
	return block_cancel()

func quitgame():
	sfx.get_node("confirm").play()
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("BGM"), 0, false)
	get_tree().change_scene("res://scenes/global.tscn")

func no_pressed():
	sfx.get_node("confirm").play()
	shield.hide()
	get_node("quit").grab_focus()

