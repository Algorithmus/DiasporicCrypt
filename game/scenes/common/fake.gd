
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

func _fixed_process(delta):
	var collisions = area.get_overlapping_bodies()
	var playerfound = false
	for i in collisions:
		if (i.get_name() == "player"):
			var playeroffset = i.get("sprite_offset")
			if (i.get_global_pos().x + playeroffset.x < get_global_pos().x + sprite_offset.x && i.get_global_pos().x - playeroffset.x > get_global_pos().x - sprite_offset.x):
				if (i.get_global_pos().y + playeroffset.y <= get_global_pos().y + sprite_offset.y && i.get_global_pos().y - playeroffset.y >= get_global_pos().y - sprite_offset.y):
					playerfound = true
					overlay_obj.hide()
			i.get("area2d_blacklist").append(area)
	if (!playerfound):
		overlay_obj.show()

func enter_screen():
	set_fixed_process(true)

func exit_screen():
	set_fixed_process(false)
