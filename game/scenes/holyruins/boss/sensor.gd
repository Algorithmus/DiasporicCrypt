
extends "res://scenes/common/Sensor.gd"

# Sensor for Giant Eyeball

var topazkeyclass = preload("res://scenes/items/special/topazkey.tscn")
var access

func _ready():
	gatepos = Vector2(-360, -80)
	access = tilemap.get_node("AccessGroup")
	var eyeball = tilemap.get_node("BossGroup/GiantEyeball")
	if (Globals.get("current_quest_complete")):
		eyeball.queue_free()
		# clear gate
		if (!Globals.get("inventory").inventory.has("ITEM_TOPAZKEY")):
			var item = topazkeyclass.instance()
			item.set_global_pos(Vector2(48, 496))
			tilemap.get_node("BossGroup").add_child(item)

func _fixed_process(delta):
	var eyeball = tilemap.get_node("BossGroup/GiantEyeball")
	if (!isfighting) :
		if (eyeball.has_node("Sunbeam")):
			eyeball.remove_child(eyeball.get_node("Sunbeam"))
		if (tilemap.has_node("AccessGroup")):
			tilemap.remove_child(access)

func trigger_fighting():
	var eyeball = tilemap.get_node("BossGroup/GiantEyeball")
	eyeball.get_node("target").set_fixed_process(true)

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("GiantEyeball")):
		gate.queue_free()
		set_fixed_process(false)
		tilemap.add_child(access)