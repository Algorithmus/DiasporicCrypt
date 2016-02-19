
extends "res://players/magic/BaseProjectile.gd"

var dust

func _ready():
	sprite = get_node("Iceball")
	dust = get_node("dust")
	charge_sfx = "charge"
	release_sfx = "ice"
	collision = get_node("Area2D")
	sampleplayer = get_node("SamplePlayer")
	soundid = sampleplayer.play(charge_sfx)

func change_scale(scale):
	.change_scale(scale)
	sampleplayer.set_volume_db(soundid, 5 * (scale - 1))

func change_direction(new_direction):
	.change_direction(new_direction)
	dust.set_emissor_offset(Vector2(direction*-16, 0))