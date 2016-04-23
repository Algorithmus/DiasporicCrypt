
extends Node

var input = ""
var vertical_input = ""
var jump_input = ""
var target
var player_distance = 0.3
var originalX = 0

# AI pattern for patrolling enemies. Walks from one end of the 
# current platform to the other.
# Flying enemies have their own specified patrol range since they
# don't rely on regular collision detection to determine the end
# of the patrol range.

func _ready():
	pass

func step(space_state):
	var change_direction = false
	# check potential collisions before patrolling
	if (!target.get("is_hurt") && !target.get("is_stunned") && !target.get("frozen")):
		var player = target.get("player").get_node("player")
		# direction changes if gust value is high enough
		var netX = target.get("direction") * target.get("runspeed") + target.get("gustx")
		var net_direction = sign(netX)
		if (target.get("ignore_collision")):
			if (target.get("direction") > 0):
				input = "right"
			else:
				input = "left"

			if (target.get_global_pos().x + netX >= originalX + target.get("patrolrange") * 32):
				input = "left"
			if (target.get_global_pos().x + netX <= originalX):
				input = "right"
		else:
			# check normal horizontal collisions
			var is_wall = false
			var frontX = target.get_global_pos().x + net_direction * target.get("sprite_offset").x + netX
			var frontTile = space_state.intersect_ray(Vector2(frontX, target.get_global_pos().y - target.get("sprite_offset").y), Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y - 1), [target, player])
			if (frontTile != null && frontTile.has("position") && frontTile.has("collider")):
				change_direction = true
				is_wall = true
					
			frontTile = space_state.intersect_ray(Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y), Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y + 32), [target, player])
	
			if (frontTile == null || !frontTile.has("position") && !target.get("falling")):
				change_direction = true
			if (frontTile != null && frontTile.has("collider")):
				var collider = frontTile["collider"]
				if (collider.get_name() == "player" && collider.get_global_pos().y - collider["sprite_offset"].y > target.get_global_pos().y + target.get("sprite_offset").y):
					change_direction = true
			# slope tiles and one way tiles don't count
			var areaTile = space_state.intersect_ray(Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y - 32), Vector2(frontX, target.get_global_pos().y + target.get("sprite_offset").y + 32), target.get("area2d_blacklist"), 2147483647, 16)
			if (areaTile != null && areaTile.has("collider")):
				if (target.isSlope(areaTile["collider"].get_name())):
					change_direction = false
				if (!is_wall && areaTile["collider"].get_name() == "oneway" && areaTile["collider"].get_global_pos().y - 32 / 2 > target.get_global_pos().y + target.get("sprite_offset").y - 1):
					change_direction = false
		
		if (!target.get("ignore_collision")):
			if (change_direction):
				if (target.get("direction") > 0):
					input = "left"
				else:
					input = "right"
			else:
				if (target.get("direction") > 0):
					input = "right"
				else:
					input = "left"
		if (target.can_attack() && (player.get_global_pos().y >= target.get_global_pos().y - target.get("sprite_offset").y && player.get_global_pos().y <= target.get_global_pos().y + target.get("sprite_offset").y)):
			var camera = player.get_node("Camera2D")
			var endpos = target.get_global_pos().x + target.get("direction") * (target.get("sprite_offset").x - camera.get_offset().x * (1 - player_distance))
			if (player.get_global_pos().x * target.get("direction") <= endpos * target.get("direction") && player.get_global_pos().x * target.get("direction") >= target.get_global_pos().x * target.get("direction")):
				input = "attack"
	else:
		input = ""