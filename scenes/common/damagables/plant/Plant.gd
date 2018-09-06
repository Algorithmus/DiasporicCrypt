
extends "res://scenes/common/damagables/statues/Statue.gd"

func _ready():
	follow_player = false

func check_attack():
	var offsetX = player.get_node("player").get_global_position().x - (get_global_position().x + projectile_offset.x)
	#Shouldn't this be x? See https://github.com/godotengine/godot/issues/17405
	if (offsetX != 0 && offsetX / abs(offsetX) != get_scale().y):
		.check_attack()