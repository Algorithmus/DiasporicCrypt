
extends Node

var input = ""
var vertical_input = ""
var jump_input = ""
var target
var player_distance = 0.3
var follow_player = false # update sprite to "watch" player

# AI pattern for static enemies.

func _ready():
	pass

func step(space_state):
	input = ""
	var player = target.get("player").get_node("player")
	if (follow_player):
		if (player.get_global_pos().x > target.get_global_pos().x):
			input = "right"
		else:
			input = "left"
	if (!target.get("is_hurt") && !target.get("is_stunned") && !target.get("frozen")):
		if (target.can_attack() && ((player.get_global_pos().y >= target.get_global_pos().y - target.get("sprite_offset").y && player.get_global_pos().y <= target.get_global_pos().y + target.get("sprite_offset").y) || follow_player)):
			var camera = player.get_node("Camera2D")
			var endpos = target.get_global_pos().x + target.get("direction") * (target.get("sprite_offset").x - camera.get_offset().x * (1 - player_distance))
			if (player.get_global_pos().x * target.get("direction") <= endpos * target.get("direction") && player.get_global_pos().x * target.get("direction") >= target.get_global_pos().x * target.get("direction")):
				input = "attack"