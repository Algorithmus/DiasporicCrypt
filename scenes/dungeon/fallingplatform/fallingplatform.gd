extends Node2D

# Member variables
var lOffset = 0
var rOffset = 0
var blockR
var blockL
var climbableL
var climbableR
var animationplayer
var state = "idle"
var platform_duration = 100
var current_duration = 0
var camera
var accel = 0
var dormant_duration = 200
var current_dormant_duration = 0
export var is_climbable = true

func _physics_process(delta):
	if (camera == null):
		camera = get_tree().get_root().get_node("world/playercontainer/player/Camera2D")
	if (state == "idle"):
		var space = get_world_2d().get_space()
		var space_state = Physics2DServer.space_get_direct_state(space)
		var collisions = space_state.intersect_ray(Vector2(lOffset + get_global_position().x - 16, get_global_position().y - 18), Vector2(rOffset + get_global_position().x + 16, get_global_position().y - 18), [self, get_node("Area2D")])
		if (collisions.has("collider") && collisions["collider"].get_name() == "damage"):
			var player = collisions["collider"]
			if (is_climbable || (!is_climbable && player.get_global_position().y + player.get_parent().sprite_offset.y <= get_global_position().y - 16)):
				current_duration += 1
				if (current_duration / float(platform_duration) >= 0.65 && animationplayer.get_current_animation() != "shake"):
					animationplayer.play("shake")
				if (current_duration >= platform_duration):
					current_duration = 0
					state = "falling"
		else:
			animationplayer.play("idle")
	elif (state == "falling"):
		animationplayer.play("idle")
		accel += 1
		blockL.set_global_position(Vector2(blockL.get_global_position().x, blockL.get_global_position().y + accel))
		blockR.set_global_position(Vector2(blockR.get_global_position().x, blockR.get_global_position().y + accel))
		if (camera.get_camera_position().x + camera.get_offset().x > blockR.get_global_position().x - 16 ||
			camera.get_camera_position().x - camera.get_offset().x < blockL.get_global_position().x + 16 ||
			camera.get_camera_position().y + camera.get_offset().y > blockR.get_global_position().y + 16 ||
			camera.get_camera_position().y - camera.get_offset().y < blockR.get_global_position().y - 16):
			state = "dormant"
			blockL.set_collision_layer_bit(1, false)
			blockR.set_collision_layer_bit(1, false)
			blockL.set_collision_layer_bit(0, false)
			blockR.set_collision_layer_bit(0, false)
			blockL.hide()
			blockR.hide()
			accel = 0
			blockL.set_position(Vector2(lOffset, 0))
			blockR.set_position(Vector2(rOffset, 0))
	elif (state == "dormant"):
		current_dormant_duration += 1
		if (current_dormant_duration >= dormant_duration):
			var tiles = get_node("Area2D").get_overlapping_areas()
			var blacklisted_tiles = false
			for tile in tiles:
				if (tile.get_name() == "lava" || tile.get_name() == "water"):
					blacklisted_tiles = true
			if (tiles.empty() || blacklisted_tiles):
				current_dormant_duration = 0
				blockL.set_collision_layer_bit(0, true)
				blockR.set_collision_layer_bit(0, true)
				blockR.set_collision_layer_bit(1, true)
				blockL.set_collision_layer_bit(1, true)
				blockL.show()
				blockR.show()
				state = "idle"

func _ready():
	blockL = get_node("blockL")
	blockR = get_node("blockR")
	climbableL = blockL.get_node("climbable")
	climbableR = blockR.get_node("climbable")
	if (!is_climbable):
		blockL.get_node("climbable").set_name("CollisionShape2D")
		blockR.get_node("climbable").set_name("CollisionShape2D")
	lOffset = blockL.get_position().x
	rOffset = blockR.get_position().x
	animationplayer = get_node("AnimationPlayer")
	set_physics_process(false)

func enter_screen():
	set_physics_process(true)

func exit_screen():
	set_physics_process(false)

