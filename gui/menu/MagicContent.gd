
extends "res://gui/menu/MenuContent.gd"

# display current magic spells

var items
var itemclass = preload("res://gui/menu/magicitem.tscn")
var scrollrange
var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	has_content = true
	sfx = sfxclass.instance()
	add_child(sfx)
	items = get_node("ScrollContainer/VBoxContainer")
	scrollrange = get_node("ScrollContainer").get_size()

func update_container():
	if (ProjectSettings.has_setting("available_spells")):
		var spells = ProjectSettings.get("available_spells")
		for spell in spells:
			var magicitem
			if (items.has_node(spell["id"])):
				magicitem = items.get_node(spell["id"])
			else:
				magicitem = itemclass.instance()
				magicitem.set_name(spell["id"])
				magicitem.set("effects", spell["effects"])
				magicitem.get_node("info/icon").set_texture(load("res://players/magic/" + spell["id"] + "/icon.png"))
				magicitem.get_node("title").set_text(tr("MAGIC_" + spell["id"].to_upper()))
				magicitem.get_node("description").set_bbcode(tr("MAGIC_" + spell["id"].to_upper() + "_DESCRIPTION"))
				magicitem.connect("focus_entered", self, "check_scroll")
				magicitem.connect("pressed", self, "toggle_info")
				if (items.get_child_count() == 0):
					magicitem.set_focus_neighbour(1, get_parent().get_parent().get_node("tabs/HBoxContainer/magic").get_path())
				items.add_child(magicitem)
			var mpuse = str(spell["mp"])
			if (!spell["is_single"]):
				mpuse = "1 - " + mpuse
			var atk = tr("KEY_NA")
			if (spell.has("atk")):
				if (typeof(spell["atk"]) == TYPE_INT):
					atk = str(spell["atk"])
				else:
					atk = str(round(float(spell["atk"]) * 100)) + "%"
			var info = tr("MAGIC_STAT").replace("[mp]", mpuse)
			info = info.replace("[atk]", atk)
			info = info.replace("[break]","\n")
			magicitem.get_node("info/stats").set_bbcode(info)
			
func check_scroll():
	var item = get_focus_owner()
	var vscroll = get_node("ScrollContainer").get_v_scroll()
	var itempos = item.get_position().y
	var itemsize = item.get_size().y
	if (vscroll > itempos || vscroll + scrollrange.y < itempos + itemsize):
		get_node("ScrollContainer").set_v_scroll(itempos)

func display_stats(effects):
	var statsString = ""
	for effect in effects:
		statsString += tr("STATS_" + effect.to_upper()) + ": +" + str(effects[effect] * 100) + "%\n"
	return statsString.left(statsString.length() - 1)

func toggle_info():
	sfx.get_node("confirm").play()
	var item = get_focus_owner()
	if (item.get("isDescription")):
		item.get_node("description").set_bbcode(display_stats(item.get("effects")))
		item.set("isDescription", false)
	else:
		item.get_node("description").set_bbcode(tr("MAGIC_" + item.get_name().to_upper() + "_DESCRIPTION"))
		item.set("isDescription", true)

func reset_content():
	for item in items.get_children():
		items.remove_child(item)

func unfocus_all():
	for item in items.get_children():
		item.release_focus()
	get_node("ScrollContainer").set_v_scroll(0)
