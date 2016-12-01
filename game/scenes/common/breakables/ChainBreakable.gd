# Breaks after a certain number of chain hits

extends "res://scenes/common/breakables/BaseBreakable.gd"

export var hp = 5
var max_hp
var chaingui
var dust_particles = []
var dust = preload("res://scenes/common/breakables/dust.tscn")
var sprite
var player
var counter = ""

const CRUMBLE_COLOR = Color(12/255.0, 118/255.0, 112/255.0)

func _ready():
	chaingui = get_tree().get_root().get_node("world/gui/CanvasLayer/chain")
	sprite = get_node("KinematicBody2D/Sprite")
	max_hp = float(hp)
	player = get_tree().get_root().get_node("world/playercontainer")

func _fixed_process(delta):
	# clean up dust particles
	for i in dust_particles:
		if(!i.get_node("particles").is_emitting()):
			if (has_node(i.get_name())):
				remove_child(i)
			dust_particles.erase(i)

func dust():
	var dust_obj = dust.instance()
	add_child(dust_obj)
	dust_obj.set_pos(Vector2(randf()*32 - 16, randf()*32 - 16))
	dust_obj.get_node("particles").set_color(sprite.get_modulate())
	dust_obj.get_node("particles").set_emitting(true)
	dust_particles.append(dust_obj)

func crumble():
	is_crumbling = false
	var chain_counter = chaingui.get_node("chaintext/counterGroup/counter").get_text()
	player.get_node("player").set("hit_enemy", true)
	if (chaingui.is_visible() && chain_counter != counter):
		counter = chain_counter
		hp -= 1
		sprite.set_modulate(sprite.get_modulate().linear_interpolate(CRUMBLE_COLOR, 1 - hp/max_hp))
		dust()
	if (hp == 0):
		is_crumbling = true

