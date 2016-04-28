
extends "res://gui/menu/MenuContent.gd"

# display level and map information

func _ready():
	pass

func update_container():
	var level = Globals.get("levels")[Globals.get("current_level")]
	get_node("title").set_text(level.location.id)
	get_node("level").set_text(level.title)
	for icon in get_node("icons").get_children():
		if (level.type == icon.get_name()):
			icon.show()
			if (level.type == "bonus"):
				icon.get_node("counter").set_text(str(level.mincounter))
		else:
			icon.hide()
	if (Globals.get("current_quest_complete")):
		get_node("complete").show()
	else:
		get_node("complete").hide()