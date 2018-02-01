
extends "res://scenes/common/damagables/BaseEnemy.gd"

func _ready():
	atk = 1
	def = 0
	hp = 50
	gold = 50
	ep = 50

	current_hp = hp
	sunbeam_immunity = false
	

	var follow_ai = preload("res://scenes/common/damagables/ai/follow.gd")
	ai_obj = follow_ai.new()
	ai_obj.set("target", self)
	follow_player = true
	
func do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY):
	new_animation = .do_animation_check(new_animation, animation_speed, horizontal_motion, ladderY)
	if (new_animation == "walk" && ai_obj.get("input") == ""):
		new_animation = "idle"
	return new_animation
