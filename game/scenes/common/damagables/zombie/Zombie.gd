
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	var follow_ai = preload("res://scenes/common/damagables/ai/follow.gd")
	ai_obj = follow_ai.new()
	ai_obj.set("target", self)
	follow_player = true
	
func do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY):
	new_animation = .do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY)
	if (new_animation == "walk" && ai_obj.get("input") == ""):
		new_animation = "idle"
	return new_animation