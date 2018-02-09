extends Node

# Implementation for water that rises and falls

export var automatic = true # set to false when you want to use it with switches
export var start_fall = true
export var speed_scale = 1.0

var water
var animationplayer
var currentAnimation

func _ready():
	water = get_node("TestWaterSurface")
	animationplayer = get_node("AnimationPlayer")
	animationplayer.playback_speed = speed_scale
	var waterScale = water.get_node("Sprite").get_scale()
	var rise = animationplayer.get_animation("rise")
	var fall = animationplayer.get_animation("fall")
	var fullscale = Vector2(waterScale.x, waterScale.y)
	var emptyscale = Vector2(waterScale.x, 0)
	var emptypos = Vector2(0, waterScale.y*16)
	rise.track_set_key_value(0, 0, emptyscale)
	rise.track_set_key_value(0, 1, fullscale)
	rise.track_set_key_value(1, 0, emptypos)
	rise.track_set_key_value(2, 0, emptyscale)
	rise.track_set_key_value(2, 1, fullscale)
	rise.track_set_key_value(3, 0, emptypos)
	
	fall.track_set_key_value(0, 1, emptyscale)
	fall.track_set_key_value(0, 0, fullscale)
	fall.track_set_key_value(1, 1, emptypos)
	fall.track_set_key_value(2, 1, emptyscale)
	fall.track_set_key_value(2, 0, fullscale)
	fall.track_set_key_value(3, 1, emptypos)
	
	if (start_fall):
		currentAnimation = "fall"
	else:
		currentAnimation = "rise"
	if (automatic):
		animationplayer.play(currentAnimation)
	
func change_tide():
	if (automatic):
		if (currentAnimation == "rise"):
			currentAnimation = "fall"
		else:
			currentAnimation = "rise"
		animationplayer.play(currentAnimation)
