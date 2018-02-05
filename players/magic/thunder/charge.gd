
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
	#TODO - play sounds properly
	#soundid = sampleplayer.play("charge")
	#sampleplayer.set_volume_db(soundid, -10)

func _physics_process(delta):
	#TODO - play sounds properly
	#if (!sampleplayer.is_active()):
		#soundid = sampleplayer.play("charge")
		pass

func change_scale(scale):
	set_scale(Vector2(scale, scale))
	#TODO - play sounds properly
	#sampleplayer.set_volume_db(soundid, -10 + (scale - 1) * 5)
