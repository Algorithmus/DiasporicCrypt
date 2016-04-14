
extends Node2D

export var is_horizontal = true
export var target_level = "res://levels/common/leveltemplate.scn"
export var teleport_to = Vector2()

var teleport
var main

func _ready():
	teleport = get_node("teleport")
	main = get_tree().get_root().get_node("world")

func _fixed_process(delta):
	var tiles = teleport.get_overlapping_areas()
	for i in tiles:
		if (i.get_name() == "damage"):
			var pos = teleport_to
			if (is_horizontal && i.get_global_pos().y - 64 >= get_global_pos().y - teleport.get_scale().y * 32 && i.get_global_pos().y + 64 <= get_global_pos().y + teleport.get_scale().y * 32):
				var player_delta = i.get_global_pos().y - get_global_pos().y
				pos.y = teleport_to.y + player_delta
				set_fixed_process(false)
				main.teleport(target_level, pos, self)
			elif (!is_horizontal && i.get_global_pos().x - 16 >= get_global_pos().x - teleport.get_scale().x * 32 && i.get_global_pos().x + 16 <= get_global_pos().x + teleport.get_scale().x * 32):
				var player_delta = i.get_global_pos().x - get_global_pos().x
				pos.x = teleport_to.x + player_delta
				set_fixed_process(false)
				main.teleport(target_level, pos, self)

func enter_screen():
	set_fixed_process(true)

func exit_screen():
	set_fixed_process(false)
