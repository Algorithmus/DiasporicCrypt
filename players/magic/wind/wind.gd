
extends Node2D

var screen
var player
var camera
var gust_power
var direction
var gust_duration = 100
var gust_current_duration = 0
var sampleplayer
var atk = 10
var type = "wind"

func _ready():
	set_physics_process(true)
	screen = get_node("screen")
	modulate.a = 0
	sampleplayer = get_node("SamplePlayer")

func set_size(scale):
	gust_power = scale

func update_size():
	if (camera != null):
		var scaleX = -camera.get_offset().x * 2
		var scaleY = -camera.get_offset().y * 2
		screen.set_scale(Vector2((scaleX + 16)/32.0, (scaleY + 32)/16.0))
		get_node("BG").set_scale(Vector2(direction * (scaleX + 16)/32.0, (scaleY + 32)/16.0))
		var actionlines = get_node("actionlines")
		var gust = get_node("gust")
		actionlines.set_scale(Vector2(direction, 1))
		actionlines.process_material.emission_box_extents = Vector3(scaleX, scaleY * 2, 1)
		gust.set_scale(Vector2(direction, 1))
		gust.process_material.emission_box_extents = Vector3(scaleX, scaleY * 2, 1)
		gust.process_material.scale = 0.8 * gust_power + 0.2
		if (gust_power > 0.5):
			screen.get_node("collision").set_name("magic")
		sampleplayer.get_node("wind").play()
		sampleplayer.get_node("wind").set_volume_db(gust_power * 10)

func _physics_process(delta):
	if (screen.get_scale() == Vector2(1, 1)):
		update_size()
	# blow back enemies
	var collisions = screen.get_overlapping_areas()
	for i in collisions:
		if (i.get_name() == "damagable" && i.get_parent() != null && i.get_parent().get("gustx") != null):
			var enemy = i.get_parent()
			enemy.set("gustx", (6 + gust_power * 2) * direction)
	gust_current_duration += 1
	# stay with camera
	set_global_position(Vector2(camera.get_camera_position().x - direction * (camera.get_offset().x/ 2.0 - 16), camera.get_camera_position().y))
	modulate.a = (gust_duration - gust_current_duration)/float(gust_duration)
	if (gust_current_duration >= gust_duration):
		player.set("magic_delay", false)
		player.remove_from_blacklist(screen)
		queue_free()
