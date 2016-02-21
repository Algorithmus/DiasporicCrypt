
extends "res://scenes/common/damagables/BaseEnemy.gd"

export var patrolrange = 10 # number of tiles to patrol

# Base class for flying enemies. Ignores all regular collisions
# except attacks.

func _ready():
	ignore_collision = true
	ai_obj.set("originalX", get_global_pos().x)
	
func step_vertical(space_state, relevantTileA, relevantTileB, normalTileCheck, onOneWayTile, animation_speed, onSlope, oneWayTile, relevantSlopeTile):
	accel = 0
	var desiredY = 0
	if (ai_obj.get("vertical_input") == "up"):
		desiredY = -runspeed
		accel = -runspeed
	elif (ai_obj.get("vertical_input") == "down"):
		desiredY = runspeed
		accel = runspeed
	return {"desiredY": desiredY, "slope": false, "slopeTile": null, "abSlope": null, "animationSpeed": animation_speed, "ladderY": 0}

func closestXTile(direction, desiredX, space_state):
	var x = desiredX + gustx
	gustx = 0
	return x