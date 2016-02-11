
extends KinematicBody2D

var player
#var damage_flash = false
var flash_delay = 0
var hpclass = preload("res://gui/hud/hp.scn")
var hud
var hurt_delay = 10
var current_delay = 0
var blood = preload("res://scenes/common/blood.xml")
var blood_particles = []
var sprite_offset
var current_animation = "idle"
var animation_player

func _ready():
	set_fixed_process(true)
	sprite_offset = get_node("collision/CollisionShape2D").get_shape().get_extents()
	player = get_tree().get_root().get_node("world/playercontainer")
	hud = get_tree().get_root().get_node("world/gui/hpcontainer")
	animation_player = get_node("AnimationPlayer")

func bleed():
	var blood_obj = blood.instance()
	add_child(blood_obj)
	blood_obj.set_pos(Vector2(randf()*sprite_offset.x + sprite_offset.x/2 - 16, sprite_offset.y - randf()*sprite_offset.y*2))
	blood_obj.get_node("particles").set_emitting(true)
	blood_obj.get_node("sound").play("blood")
	blood_particles.append(blood_obj)

func _fixed_process(delta):
	var collision_rect = get_node("collision")
	var damageTiles = collision_rect.get_overlapping_areas()
	var new_animation = current_animation
	# modulate color on hit
	"""
	var color = Color(1, 1, 1, 1)
	if (damage_flash):
		flash_delay += 1
		color = Color(1, 0, 0, 1)
		if (flash_delay >= 10):
			flash_delay = 0
			damage_flash = false
	get_node("Sprite").set_modulate(color)
	"""
	if (current_delay == 0):
		for i in damageTiles:
			if (i.has_node("weapon")):
				player.get_node("player").set("hit_enemy", true)
				var hp = hpclass.instance()
				hud.add_child(hp)
				bleed()
				var hitpos = hp.calculate_hitpos(i.get_global_pos(), i.get_node("weapon").get_shape().get_extents(), get_global_pos(), get_node("collision/CollisionShape2D").get_shape().get_extents())
				#TODO - calculate damage
				hp.display_damage(hitpos, 1)
				#get_node("Sprite").set_modulate(Color(1, 0, 0, 1))
				#damage_flash = true
				current_delay += 1
				new_animation = "hurt"
				
	else:
		current_delay += 1
		if (current_delay >= hurt_delay):
			current_delay = 0

	# clean up blood particles
	for i in blood_particles:
		if(!i.get_node("particles").is_emitting()):
			if (has_node(i.get_name())):
				remove_child(i)
			blood_particles.erase(i)
	if (current_animation == "hurt" && animation_player.get_current_animation_pos() == animation_player.get_current_animation_length()):
		new_animation = "idle"

	if (current_animation != new_animation):
		current_animation = new_animation
		animation_player.play(current_animation)