
extends Node

var input = ""
var vertical_input = ""
var jump_input = ""
var target
var player_distance = 0.3
var preferred_distance = 0 # preferred horizontal distance to keep between player and enemy
var chase_delay = 100 # some delay between hitting player

# AI pattern for enemies that follow the player.

func _ready():
	pass

func step(space_state):
	var player = target.get("player").get_node("player")
	# check potential collisions before moving
	if (!target.get("is_hurt") && !target.get("is_stunned") && !player.get("is_hurt") && !target.get("frozen")):
		var camera = player.get_node("Camera2D")
		var inrange = false
		var vertical_inrange = true
		var desired_direction = 0
		if (target.get_global_pos().x >= camera.get_camera_screen_center().x + camera.get_offset().x && target.get_global_pos().x <= camera.get_camera_screen_center().x - camera.get_offset().x):
			if (target.get_global_pos().y >= camera.get_camera_screen_center().y + camera.get_offset().y && target.get_global_pos().y <= camera.get_camera_screen_center().y - camera.get_offset().y):
				# match vertical position on flying enemies
				if (target.get("ignore_collision")):
					vertical_input = ""
					vertical_inrange = false
					var vertical_direction = 0
					if (target.get_global_pos().y > player.get_global_pos().y):
						vertical_direction = -1
					elif (target.get_global_pos().y < player.get_global_pos().y):
						vertical_direction = 1
					if (abs(target.get_global_pos().y - player.get_global_pos().y) < abs(target.get("direction") * target.get("runspeed") + target.get("gustx"))):
						vertical_direction = 0
					if (vertical_direction != 0):
						if (vertical_direction > 0):
							vertical_input = "down"
						else:
							vertical_input = "up"
					if (target.get_global_pos().y > player.get_global_pos().y - player.get("sprite_offset").y && target.get_global_pos().y < player.get_global_pos().y + player.get("sprite_offset").y):
						vertical_inrange = true
				var relative_direction = 1
				if (player.get_global_pos().x > target.get_global_pos().x):
					relative_direction = -1
				var desired_pos = player.get_global_pos().x + preferred_distance * relative_direction
				if (target.get_global_pos().x > desired_pos):
					desired_direction = -1
				elif (target.get_global_pos().x < desired_pos):
					desired_direction = 1
				# if we're close enough, don't bother closing the gap since the current runspeed will overstep
				# the desired position anyways
				if (abs(target.get_global_pos().x - desired_pos) < abs(target.get("direction") * target.get("runspeed") + target.get("gustx"))):
					desired_direction = 0
				if (vertical_inrange && (desired_direction == relative_direction || desired_direction == 0)):
					inrange = true
			if (desired_direction != 0 && !target.get("ignore_collision")):
				# do regular collision detection for horizontal motion
				var is_wall = false
				var cache_direction = desired_direction
				var netX = cache_direction * target.get("runspeed") + target.get("gustx")
				var frontX = target.get_global_pos().x + sign(netX) * target.get("sprite_offset").x + netX
				var frontTile = space_state.intersect_ray(Vector2(frontX, target.get_global_pos().y - target.get("sprite_offset").y), Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y - 1), [target, player.get_node("player")])
				if (frontTile != null && frontTile.has("position") && frontTile.has("collider")):
					desired_direction = 0
					is_wall = true
						
				frontTile = space_state.intersect_ray(Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y), Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y + 32), [target, player.get_node("player")])
		
				if (frontTile == null || !frontTile.has("position") && !target.get("falling")):
					desired_direction = 0
				if (frontTile != null && frontTile.has("collider")):
					var collider = frontTile["collider"]
					if (collider.get_name() == "player" && collider.get_global_pos().y - collider["sprite_offset"].y > target.get_global_pos().y + target.get("sprite_offset").y):
						desired_direction = 0
				# slope tiles and one way tiles don't count
				var areaTile = space_state.intersect_ray(Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y - 32), Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y + 32), target.get("area2d_blacklist"), 2147483647, 16)
				if (areaTile != null && areaTile.has("collider")):
					if (target.isSlope(areaTile["collider"].get_name())):
						desired_direction = cache_direction
					if (!is_wall && areaTile["collider"].get_name() == "oneway" && areaTile["collider"].get_global_pos().y - 32 / 2 > target.get_global_pos().y + target.get("sprite_offset").y - 1):
						desired_direction = cache_direction
	
			if (desired_direction != 0):
				if (desired_direction > 0):
					input = "right"
				else:
					input = "left"
			else:
				input = ""
		if (target.can_attack() && inrange):
			input = "attack"
	else:
		input = ""
		vertical_input = ""
		jump_input = ""