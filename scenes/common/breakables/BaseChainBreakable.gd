# Breaks after a certain number of chain hits

extends "res://scenes/common/breakables/BaseBreakable.gd"

var chaingui
var dust_particles = []
var dust = preload("res://scenes/common/breakables/dust.tscn")
var sprite
var player
var counter = ""

func _ready():
	chaingui = get_tree().get_root().get_node("world/gui/CanvasLayer/chain")
	sprite = get_node("KinematicBody2D/Sprite")
	player = get_tree().get_root().get_node("world/playercontainer")
	set_physics_process(false)

func _physics_process(delta):
	# clean up dust particles
	for i in dust_particles:
		if(!i.get_node("particles").is_emitting()):
			if (has_node(i.get_name())):
				remove_child(i)
			dust_particles.erase(i)

func dust():
	var dust_obj = dust.instance()
	add_child(dust_obj)
	dust_obj.set_position(Vector2(randf()*32 - 16, randf()*32 - 16))
	dust_obj.get_node("particles").set_color(sprite.get_modulate())
	dust_obj.get_node("particles").set_emitting(true)
	dust_particles.append(dust_obj)

func crumble():
	is_crumbling = false
	player.get_node("player").set("hit_enemy", true)
	check_chain()

func check_chain():
	pass


