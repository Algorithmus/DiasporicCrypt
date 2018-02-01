
extends Node2D

export var is_horizontal = true
export var target_level = "res://levels/common/leveltemplate.scn"
export var teleport_to = Vector2()

var teleport
var main

func _ready():
	teleport = get_node("teleport")
	main = get_tree().get_root().get_node("world")

func _physics_process(delta):
	var tiles = teleport.get_overlapping_areas()
	for i in tiles:
		if (i.get_name() == "damage"):
			var camera = i.get_parent().get_node("Camera2D")
			camera.set_offset(Vector2(-400, -296))
			var pos = teleport_to
			if (is_horizontal && i.get_global_position().y - 64 >= get_global_position().y - teleport.get_scale().y * 32 && i.get_global_position().y + 64 <= get_global_position().y + teleport.get_scale().y * 32):
				var player_delta = i.get_global_position().y - get_global_position().y
				pos.y = teleport_to.y + player_delta
				set_physics_process(false)
				main.teleport(target_level, pos, self)
			elif (!is_horizontal && i.get_global_position().x - 16 >= get_global_position().x - teleport.get_scale().x * 32 && i.get_global_position().x + 16 <= get_global_position().x + teleport.get_scale().x * 32):
				var player_delta = i.get_global_position().x - get_global_position().x
				pos.x = teleport_to.x + player_delta
				set_physics_process(false)
				main.teleport(target_level, pos, self)

func enter_screen():
	set_physics_process(true)

func exit_screen():
	set_physics_process(false)

