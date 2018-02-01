
extends "res://players/magic/BaseProjectile.gd"

var type = "fire"

func _ready():
	sprite = get_node("Fireball")
	charge_sfx = "charge"
	release_sfx = "fire"
	sampleplayer = get_node("SamplePlayer")
	collision = get_node("Area2D")
	soundid = sampleplayer.play(charge_sfx)
	sampleplayer.set_volume_db(soundid, -10)
