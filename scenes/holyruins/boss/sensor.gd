
extends "res://scenes/common/Sensor.gd"

# Sensor for Giant Eyeball

var topazkeyclass = preload("res://scenes/items/special/topazkey.tscn")
var access
var gate2
var gate2class = preload("res://scenes/holyruins/gate2.tscn")

# Don't start spawning until player lands on the platform
var grace_period = 30
var grace_delay = 0

func _ready():
	gateclass = preload("res://scenes/holyruins/gate.tscn")
	gatepos = Vector2(-368, 176)
	access = tilemap.get_node("AccessGroup")
	var eyeball = tilemap.get_node("BossGroup/GiantEyeball")
	if (Globals.get("current_quest_complete")):
		eyeball.queue_free()
		# clear gate
		if (!Globals.get("inventory").inventory.has("ITEM_TOPAZKEY")):
			var item = topazkeyclass.instance()
			item.set_global_position(Vector2(48, 496))
			tilemap.get_node("BossGroup").add_child(item)

func _physics_process(delta):
	var eyeball = tilemap.get_node("BossGroup/GiantEyeball")
	if (!isfighting) :
		if (eyeball.has_node("Sunbeam")):
			eyeball.remove_child(eyeball.get_node("Sunbeam"))
		if (tilemap.has_node("AccessGroup")):
			tilemap.remove_child(access)

func trigger_fighting():
	gate2 = gate2class.instance()
	gate2.set_global_position(Vector2(48, -208))
	tilemap.get_node("GateGroup").add_child(gate2)
	
	grace_delay = 1

func start_fighting():
	var eyeball = tilemap.get_node("BossGroup/GiantEyeball")
	eyeball.get_node("target").set_physics_process(true)

func process_fighting():
	if (!tilemap.get_node("BossGroup").has_node("GiantEyeball") && grace_delay == 0):
		gate.queue_free()
		gate2.queue_free()
		set_physics_process(false)
		tilemap.add_child(access)
	if (grace_delay > 0):
		grace_delay += 1
		if (grace_delay >= grace_period):
			grace_delay = 0
			start_fighting()
	
