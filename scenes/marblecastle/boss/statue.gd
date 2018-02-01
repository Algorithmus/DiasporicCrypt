
extends Node2D

# Statues for Statue Head boss. Can only be attacked at certain times.

# This class is a target modified to only take damage from certain types
# of attacks.

var player
var collision_rect
var hpclass = preload("res://gui/hud/hp.tscn")
var hud
var hurt_delay = 10
var current_delay = 0
var sprite_offset
var dying = false
var animation_player
var current_animation = "idle"
var combo = ""
var elemental_weaknesses = []
var elemental_protection = []
var hp = 100
var current_hp = 100
const RED = Color(1, 72 / 255.0, 72 / 255.0, 1)

func _ready():
	collision_rect = get_node("collision")
	sprite_offset = collision_rect.get_node("CollisionShape2D").get_shape().get_extents()
	player = get_tree().get_root().get_node("world/playercontainer")
	hud = get_tree().get_root().get_node("world/gui/hpcontainer")
	animation_player = get_node("AnimationPlayer")

func _physics_process(delta):
	var new_animation = current_animation
	# check damage
	if (current_delay == 0 && !dying):
		var player_obj = player.get_node("player")
		var damageTiles = collision_rect.get_overlapping_areas()
		for i in damageTiles:
			var collider
			var damage = 0
			if (i.has_node("weapon")):
				var type = i.get("type")
				collider = i.get_node("weapon")
				player_obj.set("hit_enemy", true)
				new_animation = "hurt"
				if (i.get_name().to_lower().begins_with(combo)):
					var special_factor = 1
					if (i.get("atk")):
						special_factor = i.get("atk")
					var atk_adjusted = player_obj.get_atk_adjusted_damage(player_obj.get("atk")*special_factor, type)
					var critical = player_obj.get_critical_bonus(atk_adjusted)
					damage = max(atk_adjusted + critical, 0)

			if (collider != null && damage > 0):
				var hp_obj = hpclass.instance()
				hud.add_child(hp_obj)
				current_hp -= damage
				get_node("Sprite").set_modulate(RED.linear_interpolate(Color(1, 1, 1), current_hp/hp))
				if (current_hp <= 0):
					dying = true
				var hitpos = hp_obj.calculate_hitpos(i.get_global_position(), collider.get_shape().get_extents(), get_global_position(), sprite_offset)
				hp_obj.display_damage(hitpos, damage)
				current_delay += 1
				
	else:
		current_delay += 1
		if (current_delay >= hurt_delay):
			current_delay = 0

	if (dying):
		hide_collision()
		new_animation = "die"
		
	if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length()):
		if (current_animation == "hurt" || current_animation == "deactivate" || current_animation == "activate"):
			new_animation = "idle"
			update_animation("idle")
		elif (current_animation == "die"):
			set_physics_process(false)
	if (current_animation != "activate" && current_animation != "deactivate"):
		update_animation(new_animation)

func hide_collision():
	if (has_node("collision")):
		remove_child(collision_rect)
		combo = ""
		update_animation("deactivate")

func show_collision():
	if (!has_node("collision")):
		add_child(collision_rect)
		update_animation("activate")

func update_animation(new_animation):
	if (current_animation != new_animation):
		current_animation = new_animation
		animation_player.play(current_animation)
