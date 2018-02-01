
extends "res://scenes/common/Sensor.gd"

# sensor for Monster Plant

var peridotkeyclass = preload("res://scenes/items/special/peridotkey.tscn")

func _ready():
	gatepos = Vector2(-208, -400)
	var plant = tilemap.get_node("BossGroup/MonsterPlant")
	if (Globals.get("current_quest_complete")):
		plant.queue_free()
		# clear gate
		if (!Globals.get("inventory").inventory.has("ITEM_PERIDOTKEY")):
			var item = peridotkeyclass.instance()
			item.set_global_position(Vector2(-608, -368))
			tilemap.get_node("BossGroup").add_child(item)

func trigger_fighting():
	var plant = tilemap.get_node("BossGroup/MonsterPlant")
	plant.set_physics_process(true)

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("MonsterPlant")):
		gate.queue_free()
		tilemap.get_node("SolidGroup").queue_free()
		set_physics_process(false)
