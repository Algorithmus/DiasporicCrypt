
extends Node2D

export var overlay = ""
var area
var sprite_offset
var overlay_obj

func _ready():
	area = get_node("fake")
	sprite_offset = area.get_node("CollisionShape2D").get_shape().get_extents()
	sprite_offset.x = sprite_offset.x * area.get_scale().x
	sprite_offset.y = sprite_offset.y * area.get_scale().y
	overlay_obj = get_node(overlay)
	set_physics_process(false)

func _physics_process(delta):
	var collisions = area.get_overlapping_bodies()
	var playerfound = false
	for i in collisions:
		if (i.get_name() == "player"):
			var playeroffset = i.get("sprite_offset")
			if (i.get_global_position().x + playeroffset.x < get_global_position().x + sprite_offset.x && i.get_global_position().x - playeroffset.x > get_global_position().x - sprite_offset.x):
				if (i.get_global_position().y + playeroffset.y <= get_global_position().y + sprite_offset.y && i.get_global_position().y - playeroffset.y >= get_global_position().y - sprite_offset.y):
					playerfound = true
					overlay_obj.hide()
			i.get("area2d_blacklist").append(area)
	if (!playerfound):
		overlay_obj.show()

func enter_screen():
	set_physics_process(true)

func exit_screen():
	set_physics_process(false)

