
extends Node2D

var boltball
var bolts
var sampleplayer
var soundid

func _ready():
	set_physics_process(true)
	boltball = get_node("Bolt")
	bolts = get_node("bolts")
	get_node("AnimationPlayer").play("runningbolts")
	sampleplayer = get_node("SamplePlayer")
	soundid = sampleplayer.play("charge")
	sampleplayer.set_volume_db(soundid, -10)

func _physics_process(delta):
	if (!sampleplayer.is_active()):
		soundid = sampleplayer.play("charge")

func change_scale(scale):
	set_scale(Vector2(scale, scale))
	sampleplayer.set_volume_db(soundid, -10 + (scale - 1) * 5)
