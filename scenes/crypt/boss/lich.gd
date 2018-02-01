
extends Node2D

var cycle = "attack"
var currentx = 0
var currenty = 0
var hp = 100
var current_hp = 100
var ep = 50000
var collision_rect
const HURT_DELAY = 50
var current_hurt_delay = 0
var inversehexclass = preload("res://scenes/crypt/boss/inversehex.tscn")
var inversehex = false
var inversehex_index = 0
var projectileclass = preload("res://scenes/crypt/boss/projectile.tscn")
var amethystkeyclass = preload("res://scenes/items/special/amethystkey.tscn")
var potionplusplusclass = preload("res://scenes/items/potion/potionplus.tscn")
var expclass = preload("res://scenes/items/exporb/exporb.tscn")
const INVERSEHEX_DELAY = 50
var current_inversehex_delay = 0
var hpclass = preload("res://gui/hud/hp.tscn")
var hud
const ATTACK_COOLDOWN = 200
var current_attack_delay = 0
const INVERSEHEX_LEFT = -192
const INVERSEHEX_RIGHT = 1218
var inversehex_count
var inversehex_direction = 1
var player
var animation_player
var current_animation = "idle"
const RED = Color(1, 45 / 255.0, 45 / 255.0)

func _ready():
	collision_rect = get_node("damagable")
	animation_player = get_node("AnimationPlayer")
	hud = get_tree().get_root().get_node("world/gui/hpcontainer")
	inversehex_count = (INVERSEHEX_RIGHT - 128 - INVERSEHEX_LEFT) / 320
	player = get_tree().get_root().get_node("world/playercontainer/player")

func _physics_process(delta):
	var new_animation = current_animation
	if (cycle == "attack"):
		new_animation = "idle"
		currentx += PI/180
		currenty += PI/30
		var x = cos(currentx) * 608
		var y = cos(currenty) * 64
		set_global_position(Vector2(512 + x, y - 848))
		if (current_hurt_delay == 0):
			check_damage()
		else:
			new_animation = "hurt"
			current_hurt_delay += 1
			if (current_hurt_delay >= HURT_DELAY):
				current_hurt_delay = 0
		if (inversehex):
			current_inversehex_delay += 1
			if (current_inversehex_delay >= INVERSEHEX_DELAY):
				current_inversehex_delay = 0
				var inversehex_obj = inversehexclass.instance()
				get_parent().add_child(inversehex_obj)
				inversehex_obj.change_scale(2)
				var offsetx = INVERSEHEX_LEFT + 64
				if (inversehex_direction < 1):
					offsetx = INVERSEHEX_RIGHT - 64
				inversehex_obj.player = player
				inversehex_obj.length = 33
				inversehex_obj.set_global_position(Vector2(offsetx + inversehex_index * 320 * inversehex_direction, -1376))
				inversehex_obj.release()
				inversehex_index += 1
				if (inversehex_index > inversehex_count):
					inversehex = false
					inversehex_index = 0
					current_attack_delay = 0
		else:
			if (current_attack_delay >= ATTACK_COOLDOWN):
				var attack = randi() % 2
				if (attack == 0):
					inversehex = true
					inversehex_direction = inversehex_direction * -1
				else:
					create_projectile(0, -6, 3*PI/2, 0)
					create_projectile(6, -6, 7*PI/4, 1)
					create_projectile(1, 0, 0, 1)
					create_projectile(6,6, PI/4, 1)
					create_projectile(0, 6, PI/2, 0)
					create_projectile(-6, 6, 3*PI/4, -1)
					create_projectile(-1, 0, PI, -1)
					create_projectile(-6, -6, 5*PI/4, -1)
					current_attack_delay = 0
			else:
				current_attack_delay += 1
	elif(cycle == "dying"):
		new_animation = "die"
		if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length() && current_animation == "die"):
			cycle = "die"
	else:
		# drop items
		var item = amethystkeyclass.instance()
		if (Globals.get("inventory").inventory.has("ITEM_AMETHYSTKEY")):
			item = potionplusplusclass.instance()
		var exporb = expclass.instance()
		exporb.set_value(ep)
		exporb.set_global_position(Vector2(512, -592))
		item.set_global_position(Vector2(512, -624))
		get_parent().add_child(exporb)
		get_parent().add_child(item)
		set_physics_process(false)
		queue_free()

func update_animation(new_animation):
	if (new_animation != current_animation):
		current_animation = new_animation
		animation_player.play(current_animation)

func create_projectile(ratex, ratey, angle, direction):
	var projectile = projectileclass.instance()
	projectile.set("rateX", ratex)
	projectile.set("rateY", ratey)
	projectile.set("camera", player.get_node("Camera2D"))
	projectile.set("direction", direction)
	var x = 112 * cos(angle)
	var y = 112 * sin(angle)
	projectile.set_global_position(Vector2(get_global_position().x + x, get_global_position().y + y))
	get_parent().add_child(projectile)

func check_damage():
	var tiles = collision_rect.get_overlapping_areas()
	for tile in tiles:
		if (tile.get_name() == "sunbeam"):
			var hp_obj = hpclass.instance()
			hud.add_child(hp_obj)
			var damage = 0.05 * hp
			current_hp -= damage
			var color = RED.linear_interpolate(Color(1, 1, 1), current_hp / hp)
			get_node("sprite").set_modulate(color)
			if (current_hp <= 0):
				cycle = "dying"
				update_animation("die")
				collision_rect.queue_free()
				Globals.set("current_quest_complete", true)
				var level = Globals.get("levels")[Globals.get("current_level")]
				level.complete = true
				get_tree().get_root().get_node("world").check_available_levels()
				Globals.get("levels")[Globals.get("current_level")] = level
				var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
				level_display.get_node("title").set_text("KEY_VICTORY")
				level_display.get_node("AnimationPlayer").play("quest")
			var hitpos = hp_obj.calculate_hitpos(tile.get_global_position(), tile.get_child(0).get_shape().get_extents(), get_global_position(), collision_rect.get_child(0).get_shape().get_extents())
			hp_obj.display_damage(hitpos, damage)
			current_hurt_delay += 1
