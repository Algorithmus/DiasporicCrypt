
extends "res://scenes/common/damagables/SimpleProjectileEnemy.gd"

# Base class for static enemies. They don't move at all, but can
# still attack.

var static_ai = preload("res://scenes/common/damagables/ai/static.gd")
var gust_enabled = false # set to true to allow gust to move enemy

func _ready():
	runspeed = 0
	hp = 50
	ai_obj = static_ai.new()
	ai_obj.set("target", self)
	ai_obj.set("follow_player", true)

func closestXTile(direction, desiredX, space_state):
	if (gust_enabled):
		return .closestXTile(direction, desiredX, space_state)
	return 0