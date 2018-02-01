
extends "res://scenes/common/Sensor.gd"

# sensor for Giant Lizard

var emeraldkeyclass = preload("res://scenes/items/special/emeraldkey.tscn")

func _ready():
	gateclass = preload("res://scenes/fallislandcastle/gate.tscn")
	gatepos = Vector2(-208, -400)
	var boss = tilemap.get_node("BossGroup/GiantLizard")
	if (Globals.get("current_quest_complete")):
		boss.queue_free()
		if (!Globals.get("inventory").inventory.has("ITEM_EMERALDKEY")):
			var item = emeraldkeyclass.instance()
			item.set_global_position(Vector2(-608, -448))
			tilemap.get_node("BossGroup").add_child(item)

func trigger_fighting():
	var boss = tilemap.get_node("BossGroup/GiantLizard")
	boss.animation_player.play("appear")
	boss.activate()

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("GiantLizard")):
		gate.queue_free()
		set_physics_process(false)
