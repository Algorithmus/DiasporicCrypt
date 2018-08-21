
extends "res://scenes/common/damagables/statues/Statue.gd"

func _ready():
	ep = 250
	consume_factor = 25
	is_consumable = true
	ignore_collision = true
	
	projectile_offset.y = -48
	projectile_offset.x = 16
	consumable_size = Vector2(4, 1)

func bleed():
	.bleed()
	if (consumable):
		var color = get_node("die").get_modulate()
		get_node("cloud").set_modulate(color)
		if (current_consume_value <= 0):
			get_node("cloud").hide()

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
