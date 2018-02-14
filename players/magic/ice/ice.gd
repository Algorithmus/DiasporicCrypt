
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
	#TODO - play sounds properly
	#soundid = sampleplayer.play(charge_sfx)

func change_scale(scale):
	.change_scale(scale)
	#TODO - play sounds properly
	#sampleplayer.set_volume_db(soundid, 5 * (scale - 1))

func change_direction(new_direction):
	.change_direction(new_direction)
	dust.position.x = direction*-16
