
extends "res://scenes/common/damagables/BaseMine.gd"

var player
var countdown = 100

# Mine used by players

func _ready():
	sampleplayer.play("set")

func collision_setup():
	collision = get_node("collision")
	remove_child(collision)

func collision_check(i):
	return .collision_check(i) && i.get_name() != "damage"

func countdown():
	countdown -= 1
	get_node("mine").set_modulate(Color(1, countdown/100.0, countdown/100.0, 1))
	if (countdown <= 0):
		set_explosion()

func clear_explosion():
	player.clear_mine(self)
	player.remove_from_blacklist(collision)
	.clear_explosion()

func set_explosion():
	.set_explosion()
	player.remove_from_blacklist(sensor)
	player.add_to_blacklist(collision)