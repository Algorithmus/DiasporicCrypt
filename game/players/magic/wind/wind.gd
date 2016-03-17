
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

func _ready():
	set_fixed_process(true)
	screen = get_node("screen")
	set_opacity(0)
	sampleplayer = get_node("SamplePlayer")

func set_size(scale):
	gust_power = scale

func update_size():
	if (camera != null):
		var scaleX = -camera.get_offset().x
		var scaleY = -camera.get_offset().y
		screen.set_scale(Vector2((scaleX + 16)/32.0, (scaleY + 32)/16.0))
		get_node("BG").set_scale(Vector2(direction * (scaleX + 16)/32.0, (scaleY + 32)/16.0))
		var actionlines = get_node("actionlines")
		var gust = get_node("gust")
		actionlines.set_scale(Vector2(direction, 1))
		actionlines.set_emission_half_extents(Vector2(scaleX, scaleY * 2))
		gust.set_scale(Vector2(direction, 1))
		gust.set_emission_half_extents(Vector2(scaleX, scaleY * 2))
		gust.set_param(Particles2D.PARAM_FINAL_SIZE, 0.8 * gust_power + 0.2)
		if (gust_power > 0.5):
			screen.get_node("collision").set_name("magic")
		var soundid = sampleplayer.play("wind")
		sampleplayer.set_volume_db(soundid, gust_power * 10)

func _fixed_process(delta):
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
	set_global_pos(Vector2(camera.get_camera_pos().x - direction * (camera.get_offset().x/ 2.0 - 16), camera.get_camera_pos().y))
	set_opacity((gust_duration - gust_current_duration)/float(gust_duration))
	if (gust_current_duration >= gust_duration):
		player.set("magic_delay", false)
		player.remove_from_blacklist(screen)
		queue_free()