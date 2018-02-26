
extends "res://players/magic/BaseProjectile.gd"

var type = "fire"

func _ready():
	sprite = get_node("Fireball")
	charge_sfx = "charge"
	release_sfx = "fire"
	sampleplayer = get_node("SamplePlayer")
	collision = get_node("Area2D")
	soundid = charge_sfx
	sampleplayer.get_node(charge_sfx).play()
	sampleplayer.get_node(charge_sfx).set_volume_db(-10)
