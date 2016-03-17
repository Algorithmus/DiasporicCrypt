
extends Node2D

var player
var camera
var tilemap
var screen
var physicsChanged = false
var camera_offset
var earthquake_interval = 0
var earthquake_direction = 1
var earthquake_delay = 0
var earthquake_duration = 100
var earthquake_power = 0
var rock = preload("res://players/magic/earth/rock.scn")
var sampleplayer
var atk = 10

func _ready():
	set_fixed_process(true)
	screen = get_node("screen")
	sampleplayer = get_node("SamplePlayer")

func _fixed_process(delta):
	# effects of scaling won't take place in this call, so we do the detection next time
	if (!physicsChanged && get_scale() == Vector2(1, 1)):
		camera_offset = camera.get_offset()
		set_scale(Vector2(-camera_offset.x/16.0, -camera_offset.y/16.0))
		physicsChanged = true
		var soundid = sampleplayer.play("earth")
		sampleplayer.set_volume_db(soundid, earthquake_power * 10)
	# detect all enemies on screen (that are not in the air) and stun them
	elif (screen != null && !physicsChanged):
		var collisions = screen.get_overlapping_areas()
		for i in collisions:
			if (i.get_name() == "damagable" && i.get_parent() != null && i.get_parent().has_method("request_stun") && !i.get_parent().get("falling")):
				i.get_parent().request_stun()
		player.remove_from_blacklist(screen)
		remove_child(screen)
		screen = null
	elif (physicsChanged):
		physicsChanged = false

	# shake camera for earthquake effect
	camera.set_offset(Vector2(camera_offset.x, camera_offset.y + earthquake_interval))
	earthquake_interval += earthquake_direction * 2
	if (earthquake_interval >= 6 || earthquake_interval <= -6):
		earthquake_direction = -earthquake_direction
		earthquake_interval += earthquake_direction * 4
	earthquake_delay += 1
	
	# only rain down rocks if power level above a certain threshold
	if (earthquake_power > 50):
		var probability = ((earthquake_power - 50)/50.0) * 30
		if (probability > randf() * 100):
			var position = fmod(randi(), -camera_offset.x * 2) + camera.get_camera_pos().x + camera_offset.x
			var size = randf() * 2 * (earthquake_power - 50) / 50.0 + 1
			var rock_obj = rock.instance()
			player.add_to_blacklist(rock_obj.get_node("collision"))
			rock_obj.set_global_pos(Vector2(position, camera.get_camera_pos().y + camera_offset.y))
			rock_obj.set("atk", max(atk - 10, 10) * size + 10)
			rock_obj.set("player", player)
			rock_obj.set("camera", camera)
			tilemap.add_child(rock_obj)
			rock_obj.set_size(size)
	
	if (earthquake_delay >= earthquake_duration):
		camera.set_offset(Vector2(camera_offset.x, camera_offset.y))
		player.set("magic_delay", false)
		queue_free()