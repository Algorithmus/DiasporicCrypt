
extends Node2D

var is_set = false
var collision
var is_valid = true
var fail = false
var sampleplayer
var soundid

func _ready():
	set_fixed_process(true)
	set_opacity(0.5)
	get_node("AnimationPlayer").play("rotate")
	collision = get_node("collision")
	sampleplayer = get_node("SamplePlayer")

func _fixed_process(delta):
	if (fail):
		if (!sampleplayer.is_active()):
			if (soundid == null):
				soundid = sampleplayer.play("fail")
			else:
				queue_free()
	else:
		if (!is_set):
			# this algorithm doesn't yet detect edge of levels or
			# certain zones (eg, underwater)
			# clever level designs or implementations of blocks for
			# detecting underwater may be designed for more "playable"
			# levels.
			is_valid = true
			var collisions = collision.get_overlapping_areas()
			for i in collisions:
				if (i.get_name() == "oneway" || i.get_name().match("slope*") || i.get_name() == "damagable"):
					is_valid = false
			if (is_valid):
				collisions = collision.get_overlapping_bodies()
				if (!collisions.empty()):
					is_valid = false
			update_appearance()
		else:
			update_appearance()

func update_appearance():
	var color = Color(1, 1, 1)
	var alpha = 1
	if (!is_set):
		if (is_valid):
			color = Color(0, 1, 181/255.0)
			alpha = 0.5
		else:
			color = Color(1, 0, 0)
			alpha = 0.25
	get_node("portalBG").set_modulate(color)
	get_node("portalFG").set_modulate(color)
	set_opacity(alpha)