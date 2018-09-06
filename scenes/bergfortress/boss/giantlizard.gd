
extends "res://scenes/bergfortress/boss/ChainTarget.gd"

var patrolrange = 6
var origin
var direction = 1
var cycle = "walk"
var walkspeed = 3
var armor
const ATTACK_COOLDOWN = 300
var current_attack_delay = 0
const HAMMER_DELAY = 300
var current_hammer_delay = 0
var hammer
var hammer_collision
var hammer_oneway
var animation_player
var current_animation = "idle"
var ep = 5000
var emeraldkeyclass = preload("res://scenes/items/special/emeraldkey.tscn")
var potionplusclass = preload("res://scenes/items/potion/potionplus.tscn")
var expclass = preload("res://scenes/items/exporb/exporb.tscn")
const RED = Color(1, 96 / 255.0, 96 / 255.0)

func _ready():
	origin = get_global_position()
	armor = get_node("ArmorGroup")
	hammer = get_node("hammer")
	hammer_collision = hammer.get_node("collision")
	hammer_oneway = hammer.get_node("oneway")
	animation_player = get_node("AnimationPlayer")
	set_physics_process(false)
	get_node("sprite").set_modulate(Color(1, 1, 1))
	get_node("arm").set_modulate(Color(1, 1, 1))

func activate():
	set_physics_process(true)
	animation_player.play(current_animation)
	for armor_obj in armor.get_children():
		armor_obj.set_physics_process(true)

func step_target():
	var new_animation = "current_animation"
	if (cycle == "walk"):
		if (hammer.has_node(hammer_oneway.get_name())):
			hammer.remove_child(hammer_oneway)
		new_animation = "idle"
		set_global_position(Vector2(get_global_position().x + direction*walkspeed, get_global_position().y))
		if (get_global_position().x > origin.x + patrolrange * 32 || get_global_position().x < origin.x - patrolrange * 32):
			direction = direction * -1
			set_scale(Vector2(direction, 1))
		current_attack_delay += 1
		if (current_attack_delay >= ATTACK_COOLDOWN):
			var startRange = 6*32*direction + get_global_position().x
			var playerR = player.get_global_position().x + player.sprite_offset.x
			var playerL = player.get_global_position().x - player.sprite_offset.x
			var player_in_range = false
			if (direction > 0 && startRange < playerR && startRange + 96 > playerL):
				player_in_range = true
			elif (direction < 0 && startRange > playerL && startRange - 96 < playerR):
				player_in_range = true
			if (player_in_range):
				cycle = "attack"
				current_attack_delay = 0
				new_animation = "attack"
				hammer_collision.set_name("damagable")
	elif (cycle == "attack"):
		new_animation = "attack"
		if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length() && current_animation == "attack"):
			hammer_collision.set_name("collision")
			hammer.remove_child(hammer_collision)
			hammer.add_child(hammer_oneway)
			cycle = "hammer"
	elif (cycle == "hammer"):
		new_animation = "attack"
		current_hammer_delay += 1
		if (current_hammer_delay >= HAMMER_DELAY):
			current_hammer_delay = 0
			new_animation = "return"
			hammer.add_child(hammer_collision)
			hammer.remove_child(hammer_oneway)
			cycle = "walk"
	elif (cycle == "dying"):
		new_animation = "die"
		if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length() && current_animation == "die"):
			ProjectSettings.set("current_quest_complete", true)
			var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
			level.complete = true
			get_tree().get_root().get_node("world").check_available_levels()
			ProjectSettings.get("levels")[ProjectSettings.get("current_level")] = level
			var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
			level_display.get_node("title").set_text("KEY_VICTORY")
			level_display.get_node("AnimationPlayer").play("quest")
			cycle = "die"
	else:
		var item = emeraldkeyclass.instance()
		if (ProjectSettings.get("inventory").inventory.has("ITEM_EMERALDKEY")):
			item = potionplusclass.instance()
		var exporb = expclass.instance()
		var bonus = ProjectSettings.get("bonus_effects")
		var rate = 1
		if (bonus.exp):
			rate = 2
		exporb.set_value(ep * rate)
		exporb.set_global_position(Vector2(-608, -416))
		item.set_global_position(Vector2(-608, -448))
		get_parent().add_child(exporb)
		get_parent().add_child(item)
		set_physics_process(false)
		queue_free()
	update_animation(new_animation)

func update_animation(new_animation):
	if (new_animation != current_animation):
		current_animation = new_animation
		animation_player.play(current_animation)

func check_hp(damage):
	.check_hp(damage)
	var color = RED.linear_interpolate(Color(1, 1, 1), float(current_hp)/hp)
	get_node("sprite").set_modulate(color)
	get_node("arm").set_modulate(color)
	if (current_hp <= 0):
		update_animation("die")
		remove_child(collision_rect)
		cycle = "dying"

func available():
	return armor.get_child_count() == 0
