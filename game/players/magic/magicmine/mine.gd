
extends Node2D

var player
var attack
var collision
var is_exploding = false
var countdown = 100
var explosion
var sensor

# This object has two collision shapes: one for detecting enemies
# and the other for damage collision. Damage collision (the explosion)
# is triggered by contact with enemies or automatically after a countdown.

func _ready():
	set_fixed_process(true)
	get_node("AnimationPlayer").play("rotate")
	explosion = get_node("explosion")
	explosion.hide()
	collision = get_node("collision")
	sensor = get_node("sensor")
	remove_child(collision)
	
func _fixed_process(delta):
	if (!is_exploding):
		var collisions = sensor.get_overlapping_areas()
		for i in collisions:
			if (i.get_name() != "damage" && i.get_name() != "oneway" && !i.get_name().match("slope*") && i.get_name() != "ladder" && i.get_name() != "sensor"):
				set_explosion()
		countdown -= 1
		get_node("mine").set_modulate(Color(1, countdown/100.0, countdown/100.0, 1))
		if (countdown <= 0):
			set_explosion()
	else:
		if (!explosion.is_emitting()):
			player.clear_mine(self)
			player.remove_from_blacklist(collision)
			# remove from tilemap as well since queue free is too slow
			if (self.get_parent() != null):
				self.get_parent().remove_child(self)
			queue_free()

func set_explosion():
	is_exploding = true
	remove_child(sensor)
	add_child(collision)
	# switch collision objects
	player.remove_from_blacklist(sensor)
	player.add_to_blacklist(collision)
	explosion.show()
	explosion.set_emitting(true)
	get_node("AnimationPlayer").stop()
	get_node("mine").hide()