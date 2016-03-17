
extends KinematicBody2D

var player
#var damage_flash = false
var flash_delay = 0
var collision_rect
var hpclass = preload("res://gui/hud/hp.scn")
var hud
var hurt_delay = 10
var current_delay = 0
var blood = preload("res://scenes/common/blood.xml")
var blood_particles = []
var sprite_offset
var current_animation = "idle"
var animation_player
var frozen = false
const FREEZE_DELAY = 300
var freeze_counter = 0
var freezeblock = preload("res://scenes/common/iceblock.scn")
var freezeblock_obj

func _ready():
	set_fixed_process(true)
	collision_rect = get_node("collision")
	sprite_offset = collision_rect.get_node("CollisionShape2D").get_shape().get_extents()
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

func calculate_atk_value(obj):
	if (obj.get_parent().get("atk") != null):
		return obj.get_parent().get("atk")
	elif (obj.get_parent().get_parent() != null && obj.get_parent().get_parent().get("atk") != null):
		return obj.get_parent().get_parent().get("atk")
	else:
		return player.get_node("player").get("mag")


func _fixed_process(delta):
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
	if (current_delay == 0 && !frozen):
		var damageTiles = collision_rect.get_overlapping_areas()
		for i in damageTiles:
			var collider
			var damage = 0
			var player_obj = player.get_node("player")
			if (i.has_node("weapon")):
				collider = i.get_node("weapon")
				player_obj.set("hit_enemy", true)
				var special_factor = 1
				if (i.get("atk")):
					special_factor = i.get("atk")
				var atk_adjusted = player_obj.get_atk_adjusted_damage(player_obj.get("atk")*special_factor)
				var critical = player_obj.get_critical_bonus(atk_adjusted)
				damage = max(atk_adjusted + critical, 0)

			if (i.has_node("magic")):
				# freeze enemy in a collision block when hit with an ice attack
				if (i.get_parent() != null && i.get_parent().get_name() == "Ice"):
					frozen = true
					freezeblock_obj = freezeblock.instance()
					var freezescale = sprite_offset.y / 16.0
					freezeblock_obj.get_node("block").set_scale(Vector2(sprite_offset.x / 16.0, freezescale))
					freezeblock_obj.get_node("block").set_pos(Vector2(0, sprite_offset.y - 16))
					freezeblock_obj.set_pos(Vector2(0, -sprite_offset.y + 16))
					add_child(freezeblock_obj)
					if (has_node(collision_rect.get_name())):
						remove_child(collision_rect)

				collider = i.get_node("magic")
				var hp = i.get_parent().get("hp")
				if (hp != null):
					i.get_parent().set("hp", hp - 1)
				damage = max(player_obj.get_atk_adjusted_damage(calculate_atk_value(i)), 0)
			if (collider != null):
				var hp = hpclass.instance()
				hud.add_child(hp)
				bleed()
				var hitpos = hp.calculate_hitpos(i.get_global_pos(), collider.get_shape().get_extents(), get_global_pos(), sprite_offset)
				#TODO - calculate damage
				hp.display_damage(hitpos, damage)
				#get_node("Sprite").set_modulate(Color(1, 0, 0, 1))
				#damage_flash = true
				current_delay += 1
				new_animation = "hurt"
				
	else:
		current_delay += 1
		if (current_delay >= hurt_delay):
			current_delay = 0

	if (frozen):
		freeze_counter += 1
		# flash to warn player that frozen state is almost over
		if (fmod(freeze_counter, 4) == 0 && float(freeze_counter)/FREEZE_DELAY > 0.75):
			freezeblock_obj.set_opacity(0)
		else:
			freezeblock_obj.set_opacity(1)
		if (freeze_counter >= FREEZE_DELAY):
			frozen = false
			freeze_counter = 0
			if (has_node(freezeblock_obj.get_name())):
				remove_child(freezeblock_obj)
			freezeblock_obj = null
			add_child(collision_rect)
			animation_player.play(current_animation)

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
	if (frozen):
		animation_player.stop()
