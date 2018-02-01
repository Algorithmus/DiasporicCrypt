# Block only breaks when touched by a sunbeam

extends "res://scenes/common/breakables/BaseBreakable.gd"

var dust
var animation_player
var period
var current_delay = 0

func _ready():
	dust = get_node("KinematicBody2D/Dust")
	animation_player = get_node("AnimationPlayer")
	period = (randi() % 400) + 100

func _physics_process(delta):
	if (!animation_player.is_playing() && !is_crumbling):
		current_delay += 1
		if (current_delay >= period):
			period = (randi() % 400) + 100
			current_delay = 0
			animation_player.play("dust")

func check_crumble(i):
	return i.get_name() == "sunbeam"

func sprite_opacity(alpha):
	.sprite_opacity(alpha)
.modulate.a = alpha
