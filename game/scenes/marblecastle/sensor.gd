
extends "res://scenes/common/Sensor.gd"

# sensor for Statue Head

var sapphirekeyclass = preload("res://scenes/items/special/sapphirekey.tscn")

func _ready():
	gatepos = Vector2(-208, -400)
	var head = tilemap.get_node("BossGroup/StatueHead")
	head.set_opacity(0)
	if (Globals.get("current_quest_complete")):
		head.queue_free()
		for statue in tilemap.get_node("StatueGroup").get_children():
			statue.hide_collision()
			statue.get_node("rubble").show()
			statue.get_node("Sprite").hide()
		if (!Globals.get("inventory").inventory.has("ITEM_SAPPHIREKEY")):
			var item = sapphirekeyclass.instance()
			item.set_global_pos(Vector2(-608, -368))
			tilemap.get_node("BossGroup").add_child(item)

func trigger_fighting():
	var head = tilemap.get_node("BossGroup/StatueHead")
	head.animation_player.play("appear")
	head.set_fixed_process(true)
	for statue in tilemap.get_node("StatueGroup").get_children():
		statue.set_fixed_process(true)

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("StatueHead")):
		gate.queue_free()
		set_fixed_process(false)