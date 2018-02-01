
extends "res://scenes/common/Sensor.gd"

# sensor for Fire Dragon

var rubykeyclass = preload("res://scenes/items/special/rubykey.tscn")

func _ready():
	gateclass = preload("res://scenes/lavacave/gate.tscn")
	gatepos = Vector2(-208, -400)
	if (Globals.get("current_quest_complete")):
		tilemap.get_node("BossGroup/FireDragon").queue_free()
		if (!Globals.get("inventory").inventory.has("ITEM_RUBYKEY")):
			var item = rubykeyclass.instance()
			item.set_global_position(Vector2(272, -304))
			tilemap.get_node("BossGroup").add_child(item)

func trigger_fighting():
	var head = tilemap.get_node("BossGroup/FireDragon/head")
	head.get_node("SamplePlayer").play("roar")
	head.set_physics_process(true)

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("FireDragon")):
		gate.queue_free()
		set_physics_process(false)
