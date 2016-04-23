
extends Area2D

var gateclass = preload("res://scenes/colosseum/gate.tscn")
var gate

var enemyclass = preload("res://scenes/common/damagables/BaseEnemy.gd")

var isfighting = false
var waves
var currentwave = 0
var tilemap

func _ready():
	tilemap = get_parent().get_parent()
	if (!Globals.get("current_quest_complete")):
		set_fixed_process(true)

func _fixed_process(delta):
	if (!isfighting):
		var collisions = get_overlapping_bodies()
		for i in collisions:
			if (i.get_name() == "player"):
				gate = gateclass.instance()
				gate.set_global_pos(Vector2(-432, -48))
				tilemap.get_node("GateGroup").add_child(gate)
				isfighting = true
				get_node("CollisionShape2D").queue_free()
				var level = Globals.get("levels")[Globals.get("current_level")]
				waves = level.waves
				var wave = waves[currentwave].instance()
				tilemap.add_child(wave)
	elif (tilemap.has_node("EnemiesGroup")):
		var enemies_defeated = true
		var nonenemy_objects = []
		for entity in tilemap.get_node("EnemiesGroup").get_children():
			if (entity extends enemyclass):
				enemies_defeated = false
			else:
				nonenemy_objects.append(entity)
		if (enemies_defeated):
			currentwave += 1
			if (currentwave >= waves.size()):
				Globals.set("current_quest_complete", true)
				var level = Globals.get("levels")[Globals.get("current_level")]
				level.complete = true
				Globals.get("levels")[Globals.get("current_level")] = level
				var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
				level_display.get_node("title").set_text("KEY_VICTORY")
				level_display.get_node("AnimationPlayer").play("quest")
				gate.queue_free()
				set_fixed_process(false)
			else:
				var wave = waves[currentwave].instance()
				var size = nonenemy_objects.size()
				for i in range(0, size):
					var obj = nonenemy_objects[i]
					wave.add_child(obj)
				var oldGroup = tilemap.get_node("EnemiesGroup")
				tilemap.remove_child(oldGroup)
				oldGroup.queue_free()
				tilemap.add_child(wave)