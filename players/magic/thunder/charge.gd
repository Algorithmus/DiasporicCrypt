
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
	soundid = "charge"
	sampleplayer.get_node(soundid).play()
	sampleplayer.get_node(soundid).set_volume_db(-10)

func _physics_process(delta):
	if (!sampleplayer.get_node(soundid).playing):
		soundid = "charge"
		sampleplayer.get_node(soundid).play()

func change_scale(scale):
	set_scale(Vector2(scale, scale))
	sampleplayer.get_node(soundid).set_volume_db(-10 + (scale - 1) * 5)
