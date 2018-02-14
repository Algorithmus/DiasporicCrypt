
extends Node2D

# Monster Plant boss attack pattern
# This boss has a simple attack pattern and just moves horizontally
# and fires projectiles every now and then
# movement is only stopped when the player is standing on top
# weakened state is only activated when being knocked with boulders

var currentx = PI/2
var mouth
var top
var origin
var cycle = "attack"
var player
const GULP_COOLDOWN = 100
var gulp_delay = 0
const CLAMP_DELAY = 100
var clamp_current_delay = 0
const HURT_DELAY = 10
var current_hurt_delay = 0
const WEAK_DELAY = 500
var current_weak_delay = 0
const ATTACK_COOLDOWN = 200
var current_attack_delay = 0
var boulderhp = 3
var current_boulderhp = 3
var hp = 200
var current_hp = 200
var ep = 1000
var targetclass = preload("res://scenes/aquaduct/boss/target.tscn")
var target
var trap # detects if player is standing on this boss
var peridotkeyclass = preload("res://scenes/items/special/peridotkey.tscn")
var potionplusclass = preload("res://scenes/items/potion/potionplus.tscn")
var expclass = preload("res://scenes/items/exporb/exporb.tscn")
var projectileclass = preload("res://scenes/common/damagables/attacks/zombiefish.tscn")
var animation_player
var current_animation = "idle"
const RED = Color(1, 65 / 255.0, 65 / 255.0)

func _ready():
	mouth = get_node("mouth")
	origin = mouth.get_global_position()
	player = get_tree().get_root().get_node("world/playercontainer/player")
	trap = mouth.get_node("trap")
	top = mouth.get_node("top")
	mouth.remove_child(top)
	animation_player = get_node("AnimationPlayer")
	set_physics_process(false)

func _physics_process(delta):
	var new_animation = current_animation
	if (cycle == "attack"):
		new_animation = "idle"
		var playerfound = false
		var tiles = trap.get_overlapping_areas()
		# trap player and stop moving when player is detected
		for tile in tiles:
			if (tile.get_name() == "damage"):
				cycle = "catch"
				playerfound = true
		if (!playerfound):
			gulp_delay = 0
			currentx += PI/60
			var offset = calculate_circle()
			mouth.set_global_position(Vector2(origin.x + offset.x, origin.y + offset.y))
			current_attack_delay += 1
			# handle projectile attacks
			if (current_attack_delay >= ATTACK_COOLDOWN):
				current_attack_delay = 0
				var projectile = projectileclass.instance()
				var projectileleft = projectileclass.instance()
				var projectileright = projectileclass.instance()
				var camera = player.get_node("Camera2D")
				projectile.camera = camera
				projectile.rateY = -6
				projectile.direction = 0
				get_parent().add_child(projectile)
				projectile.set_global_position(mouth.get_global_position())
				projectileleft.camera = camera
				projectileleft.direction = -1
				projectileleft.rateY = -6
				projectileleft.rateX = -6
				get_parent().add_child(projectileleft)
				projectileleft.set_global_position(mouth.get_global_position())
				projectileright.camera = camera
				projectileright.direction = 1
				projectileright.rateY = -6
				projectileright.rateX = 6
				get_parent().add_child(projectileright)
				projectileright.set_global_position(mouth.get_global_position())
		check_damage()
	# stop moving when player is standing on top
	elif (cycle == "catch"):
		var playerfound = false
		var tiles = trap.get_overlapping_areas()
		for tile in tiles:
			if (tile.get_name() == "damage"):
				playerfound = true
				if (gulp_delay == 0):
					cycle = "clamp"
					mouth.add_child(top)
				else:
					gulp_delay += 1
					if (gulp_delay >= GULP_COOLDOWN):
						gulp_delay = 0
		if (!playerfound):
			cycle = "attack"
		check_damage()
	#trap player
	elif (cycle == "clamp"):
		new_animation = "close"
		clamp_current_delay += 1
		if (clamp_current_delay >= CLAMP_DELAY):
			clamp_current_delay = 0
			mouth.remove_child(top)
			gulp_delay += 1
			cycle = "catch"
			new_animation = "open"
	elif (cycle == "weakened"):
	#show weak spot target
		new_animation = "idle"
		var color = RED.linear_interpolate(Color(1, 1, 1), float(current_weak_delay) / WEAK_DELAY)
		mouth.get_node("bottom").set_modulate(color)
		current_weak_delay += 1
		if (current_weak_delay >= WEAK_DELAY):
			current_weak_delay = 0
			target.get_node("AnimationPlayer").play("disappear")
			cycle = "recover"
	elif (cycle == "recover"):
		# return back to previous state before being weakened
		mouth.get_node("bottom").set_modulate(Color(1, 1, 1))
		new_animation = "idle"
		var target_player = target.get_node("AnimationPlayer")
		if (target_player.get_current_animation_position() == target_player.get_current_animation_length()):
			# save current hp based on damage taken on target
			cycle = "attack"
			current_hp = target.get_node("target").hp
			target.queue_free()
			target = null
	elif (cycle == "dying"):
		if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length()):
			cycle = "die"
	else:
		var item = peridotkeyclass.instance()
		if (ProjectSettings.get("inventory").inventory.has("ITEM_PERIDOTKEY")):
			item = potionplusclass.instance()
		var exporb = expclass.instance()
		exporb.set_value(ep)
		exporb.set_global_position(Vector2(-608, -336))
		item.set_global_position(Vector2(-608, -368))
		get_parent().add_child(exporb)
		get_parent().add_child(item)
		set_physics_process(false)
		queue_free()
	update_animation(new_animation)

func update_animation(new_animation):
	if (new_animation != current_animation):
		current_animation = new_animation
		animation_player.play(current_animation)

func check_damage():
	# detect collision with boulders
	if (current_hurt_delay == 0):
		if (!cycle == "weakened"):
			var tiles = trap.get_overlapping_areas()
			for tile in tiles:
				if (tile.get_name() == "swingboulder"):
					tile.get_parent().get_parent().collided = true
					current_hurt_delay += 1
					current_boulderhp -= 1
					if (current_boulderhp <= 0):
						# transfer current hp to target
						current_boulderhp = boulderhp
						cycle = "weakened"
						target = targetclass.instance()
						target.get_node("target").current_hp = current_hp
						target.get_node("target").hp = hp
						target.get_node("target").connect("no_hp", self, "die")
						add_child(target)
						target.set_global_position(mouth.get_global_position())
	else:
		current_hurt_delay += 1
		if (current_hurt_delay >= HURT_DELAY):
			current_hurt_delay = 0

func die():
	if (trap != null):
		var trap_ref = weakref(trap)
		if (trap_ref != null && trap_ref.get_ref()):
			trap_ref.get_ref().queue_free()
	ProjectSettings.set("current_quest_complete", true)
	var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
	level.complete = true
	get_tree().get_root().get_node("world").check_available_levels()
	ProjectSettings.get("levels")[ProjectSettings.get("current_level")] = level
	var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
	level_display.get_node("title").set_text("KEY_VICTORY")
	level_display.get_node("AnimationPlayer").play("quest")
	cycle = "dying"
	target.get_node("AnimationPlayer").play("die")
	update_animation("die")

func calculate_circle():
	var x = cos(currentx)*128
	var r = pow(128, 2) - pow(x, 2)
	var y = sqrt(abs(r))/2.0
	return Vector2(x, y)
