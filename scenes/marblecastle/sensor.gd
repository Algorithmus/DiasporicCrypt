
extends "res://scenes/common/Sensor.gd"

# sensor for Statue Head

var sapphirekeyclass = preload("res://scenes/items/special/sapphirekey.tscn")
var playercamera

const CAMERA_V_OFFSET = -128
var original_voffset
var camera_direction = -1

var camera_moving = false

func _ready():
	gateclass = preload("res://scenes/marblecastle/gate.tscn")
	gatepos = Vector2(-208, -400)
	var head = tilemap.get_node("BossGroup/StatueHead")
	head.modulate.a = 0
	if (ProjectSettings.get("current_quest_complete")):
		head.queue_free()
		for statue in tilemap.get_node("StatueGroup").get_children():
			statue.hide_collision()
			statue.get_node("AnimationPlayer").stop()
			statue.get_node("rubble").show()
			statue.get_node("Sprite").hide()
		if (!ProjectSettings.get("inventory").inventory.has("ITEM_SAPPHIREKEY")):
			var item = sapphirekeyclass.instance()
			item.set_global_position(Vector2(-608, -368))
			tilemap.get_node("BossGroup").add_child(item)

func move_camera():
	playercamera.set_offset(Vector2(playercamera.get_offset().x, playercamera.get_offset().y + camera_direction))

func trigger_fighting():
	playercamera = player.get_node("Camera2D")
	original_voffset = playercamera.get_offset().y
	camera_moving = true
	var head = tilemap.get_node("BossGroup/StatueHead")
	head.animation_player.play("appear")
	head.set_physics_process(true)
	for statue in tilemap.get_node("StatueGroup").get_children():
		statue.set_physics_process(true)

func process_fighting():
	if (camera_moving):
		move_camera()
		if (camera_direction < 0 && playercamera.get_offset().y <= original_voffset + CAMERA_V_OFFSET):
			camera_moving = false
		elif(camera_direction > 0 && playercamera.get_offset().y >= original_voffset):
			camera_moving = false
			set_physics_process(false)
			return
	if (!tilemap.get_node("BossGroup").has_node("StatueHead") && !camera_moving):
		camera_moving = true
		camera_direction = 1
		gate.queue_free()
