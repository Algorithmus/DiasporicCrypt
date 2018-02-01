
extends Node2D

var collision_rect
var player
var chainlimit = 5
export var hp = 100
var current_hp = 100
var elemental_weaknesses = []
var elemental_protection = []
var sprite_offset
var hud
var hpclass = preload("res://gui/hud/hp.tscn")
var hurt_delay = 10
var current_delay = 0

func _ready():
	player = get_tree().get_root().get_node("world/playercontainer/player")
	collision_rect = get_node("damagable")
	sprite_offset = collision_rect.get_node("CollisionShape2D").get_shape().get_extents()
	hud = get_tree().get_root().get_node("world/gui/hpcontainer")	
	current_hp = hp

func check_hp(damage):
	current_hp -= damage

func _physics_process(delta):
	step_target()
	check_damage()

func step_target():
	pass

func available():
	return true

func check_damage():
	var damageTiles = collision_rect.get_overlapping_areas()
	for i in damageTiles:
		var collider
		var damage = 0
		if (i.has_node("weapon")):
			var type = i.get("type")
			collider = i.get_node("weapon")
			player.set("hit_enemy", true)
			if (player.chain_counter > chainlimit && available()):
				var special_factor = 1
				if (i.get("atk")):
					special_factor = i.get("atk")
				var atk_adjusted = get_atk_adjusted_damage(player.get("atk")*special_factor, type)
				var critical = player.get_critical_bonus(atk_adjusted)
				damage = max(atk_adjusted + critical, 0)
		if (collider != null && damage > 0):
			var hp_obj = hpclass.instance()
			hud.add_child(hp_obj)
			check_hp(damage)
			var hitpos = hp_obj.calculate_hitpos(i.get_global_position(), collider.get_shape().get_extents(), get_global_position(), sprite_offset)
			hp_obj.display_damage(hitpos, damage)
			current_delay += 1

func get_atk_adjusted_damage(damage, type):
	# calculate effects of elemental weaknesses/immunity
	var elemental_constant = 1
	if (elemental_weaknesses.find(type) >= 0):
		elemental_constant = 1.5
	if (elemental_protection.find(type) >= 0):
		elemental_constant = 0
	return round(elemental_constant * (damage * 2 + randf()*0.1*damage))
