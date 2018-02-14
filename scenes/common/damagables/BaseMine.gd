
extends Node2D

var attack
var collision
var is_exploding = false
var explosion
var sensor
var sampleplayer
var atk = 40

# This object has two collision shapes: one for detecting enemies
# and the other for damage collision. Damage collision (the explosion)
# is triggered by contact with enemies or automatically after a countdown.

func _ready():
	set_physics_process(true)
	get_node("AnimationPlayer").play("rotate")
	explosion = get_node("explosion")
	explosion.hide()
	sensor = get_node("sensor")
	collision_setup()
	sampleplayer = get_node("SamplePlayer")

func collision_setup():
	collision = get_node("damagable")
	remove_child(collision)

func collision_check(i):
	return i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder" && i.get_name() != "sensor" && i.get_name() != "water"

func countdown():
	pass

func _physics_process(delta):
	if (!is_exploding):
		var collisions = sensor.get_overlapping_areas()
		for i in collisions:
			if (collision_check(i)):
				set_explosion()
		countdown()
	else:
		if (!explosion.is_emitting()):
			# remove from tilemap as well since queue free is too slow
			clear_explosion()

func clear_explosion():
	if (self.get_parent() != null):
		self.get_parent().remove_child(self)
	queue_free()

func set_explosion():
	is_exploding = true
	remove_child(sensor)
	add_child(collision)
	# switch collision objects
	explosion.show()
	explosion.set_emitting(true)
	get_node("AnimationPlayer").stop()
	get_node("mine").hide()
	#TODO - play sounds properly
	#sampleplayer.play("mine")
