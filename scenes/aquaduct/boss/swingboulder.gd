
extends Node2D

# special type of tile that works similar to falling platforms, but
# swinging causes the tile to fall

export var groundplane = 0
var boulder
var swingable
var collision_rect
var state = "idle"
const SWING_DURATION = 100
var current_duration = 0
var accel = 0
var dormant_duration = 50
var current_dormant_duration = 0
var player
var collided = false
var shakex = PI / 2

func _ready():
	boulder = get_node("boulder")
	collision_rect = boulder.get_node("swingboulder")
	swingable = boulder.get_node("SwingBlock")
	player = get_tree().get_root().get_node("world/playercontainer/player")
	set_physics_process(true)

func _physics_process(delta):
	if (state == "idle"):
		if(player.swing_block == swingable.get_node("swingable") && player.is_swinging):
			current_duration += 1
			var sprite = boulder.get_node("boulder")
			var percent = float(current_duration) / SWING_DURATION
			# shake to indicate boulder will fall soon
			if (percent > 0.75):
				shakex += PI / 2
				var x = cos(shakex) * 4
				sprite.set_offset(Vector2(sprite.get_offset().x + x, sprite.get_offset().y))
			if (current_duration >= SWING_DURATION):
				sprite.set_offset(Vector2(0, sprite.get_offset().y))
				shakex = PI / 2
				current_duration = 0
				state = "falling"
				var swingable_rect = swingable.get_node("swingable")
				swingable_rect.set_name("unavailable")
				swingable_rect.set_collision_layer_bit(1, false)
				swingable_rect.set_collision_layer_bit(0, false)
				player.stop_swinging()
	elif (state == "falling"):
		accel += 1
		boulder.set_global_position(Vector2(boulder.get_global_position().x, boulder.get_global_position().y + accel))
		if (boulder.get_global_position().y + 32 >= groundplane || collided):
			state = "dormant"
			collision_rect.set_collision_layer_bit(1, false)
			collision_rect.set_collision_layer_bit(0, false)
			boulder.hide()
			accel = 0
			boulder.set_position(Vector2(0, 0))
			collided = false
	elif (state == "dormant"):
		current_dormant_duration += 1
		if (current_dormant_duration >= dormant_duration):
			current_dormant_duration = 0
			collision_rect.set_collision_layer_bit(1, true)
			collision_rect.set_collision_layer_bit(0, true)
			boulder.show()
			state = "idle"
			var swingable_rect = swingable.get_node("unavailable")
			swingable_rect.set_name("swingable")
			swingable_rect.set_collision_layer_bit(1, true)
			swingable_rect.set_collision_layer_bit(0, true)
