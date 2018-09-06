
extends "res://scenes/common/damagables/Flying.gd"

var follow_ai = preload("res://scenes/common/damagables/ai/follow.gd")

func _ready():
	atk = 100
	def = 0
	hp = 1000
	gold = 150
	ep = 5000

	current_hp = hp

	ai_obj = follow_ai.new()
	ai_obj.set("target", self)
	ai_obj.set("follow_player", true)
	
	sunbeam_immunity = false
