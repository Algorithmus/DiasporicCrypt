
extends "res://scenes/common/Sensor.gd"

# sensor for Lich

var amethystkeyclass = preload("res://scenes/items/special/amethystkey.tscn")

func _ready():
	gateclass = preload("res://scenes/crypt/gate.tscn")
	gatepos = Vector2(-208, -400)
	if (ProjectSettings.get("current_quest_complete")):
		tilemap.get_node("BossGroup/Lich").queue_free()
		if (!ProjectSettings.get("inventory").inventory.has("ITEM_AMETHYSTKEY")):
			var item = amethystkeyclass.instance()
			item.set_global_position(Vector2(512, -624))
			tilemap.get_node("BossGroup").add_child(item)

func trigger_fighting():
	var lich = tilemap.get_node("BossGroup/Lich")
	lich.set_physics_process(true)

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("Lich")):
		gate.queue_free()
		set_physics_process(false)
