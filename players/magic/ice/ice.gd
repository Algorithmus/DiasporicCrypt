
extends "res://players/magic/BaseProjectile.gd"

var dust
var type = "ice"

func _ready():
	sprite = get_node("Iceball")
	dust = get_node("dust")
	charge_sfx = "charge"
	release_sfx = "ice"
	collision = get_node("Area2D")
	sampleplayer = get_node("SamplePlayer")
	soundid = charge_sfx
	sampleplayer.get_node(soundid).play()

func change_scale(scale):
	.change_scale(scale)
	sampleplayer.get_node(soundid).set_volume_db(5 * (scale - 1))

func change_direction(new_direction):
	.change_direction(new_direction)
	dust.position.x = direction*-16
