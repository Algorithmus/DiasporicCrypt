
extends Node2D

# Statue Head boss implementation
# Flies around and flashes random combos for special attacks.
# This boss has two phases:
# Fly about, attack the player and flash a special attack combo.
# Dock on top of another statue for a specified period of time
# or until the statue gets destroyed.
# When there are no more statues left, this boss dies.

# Attacking
# There are two types of attacks:
# Fire a beam down at the player while moving horizontally
# Fire off 6 projectiles that move in a circular motion

var is_beam = false
var is_fire = false
var combo = null
var combo_index = 0
var combo_id = ""
const BEAM_DELAY = 100
var beam_current_delay = 0
const ATTACK_COOLDOWN = 100
var attack_current_cooldown = 0
const DOCKING_DELAY = 500
var docking_current_delay = 0
const FLASH_DELAY = 100
var flash_current_delay = 0
const FLASH_ON = 50
var flashon_current_delay = 0
var current_statues
var cycle = "appear" # display - flash combo, docking - dock on statue
var camera
var currentx = PI / 2
var specials
var statues = []
var current_statue
var beamclass = preload("res://scenes/marblecastle/boss/beam.tscn")
var fireclass = preload("res://scenes/common/damagables/attacks/firecircle.tscn")
var sapphirekeyclass = preload("res://scenes/items/special/sapphirekey.tscn")
var potionplusclass = preload("res://scenes/items/potion/potionplus.tscn")
var expclass = preload("res://scenes/items/exporb/exporb.tscn")
var fireballclass = preload("res://scenes/common/damagables/attacks/fireball.tscn")
var ep = 5000
var atk = 10
var beam
var heads
var animation_player
var current_animation = "appear"
const DISPLAY_DEFAULT = Color(47 / 255.0, 44 / 255.0, 55 / 255.0)

func _ready():
	var player = get_tree().get_root().get_node("world/playercontainer/player")
	camera = player.get_node("Camera2D")
	specials = player.get("chain_specials")
	statues = get_parent().get_parent().get_node("StatueGroup").get_children()
	heads = get_node("heads")
	animation_player = get_node("AnimationPlayer")

func _physics_process(delta):
	var new_animation = current_animation
	if (cycle == "appear"):
		new_animation = "appear"
		if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length()):
			cycle = "display"
	elif (cycle == "display"):
		new_animation = "fly"
		for statue in statues:
			statue.hide_collision()
		# pick a new combo if we're not displaying it
		# void is excluded because not all players may have it
		if (combo == null):
			var combo_obj = specials[randi() % 8]
			combo = combo_obj.replace
			combo_id = combo_obj.id
		currentx += PI/60
		var x = cos(currentx)
		set_global_position(Vector2(-640 - x * 320, camera.get_global_position().y - 164))
		# flash the combo
		if (flash_current_delay >= FLASH_DELAY):
			var display = get_node("ring/"+combo.substr(combo_index, 1))
			if (flashon_current_delay >= FLASH_ON):
				flashon_current_delay = 0
				display.set_modulate(DISPLAY_DEFAULT)
				combo_index += 1
				flash_current_delay = 0
			elif (combo_index < combo.length()):
				display.set_modulate(Color(1, 0, 0))
				flashon_current_delay += 1
			else:
				# end attacking phase
				cycle = "docking"
				new_animation = "docking"
				flashon_current_delay = 0
				flash_current_delay = 0
				combo_index = 0
				current_statue = statues[randi() % statues.size()]
				current_statue.combo = combo_id
				heads.get_node("head").hide()
				heads.get_node(current_statue.get_name()).show()
				attack_current_cooldown = 0
				if (beam != null):
					beam.queue_free()
					beam = null
				beam_current_delay = 0
		else:
			flash_current_delay += 1
		# randomly pick an attack
		if (attack_current_cooldown >= ATTACK_COOLDOWN && beam_current_delay < BEAM_DELAY):
			if (randi() % 2 == 0):
				beam = beamclass.instance()
				var head = heads.get_node("head")
				beam.set_position(Vector2(head.get_position().x + 1, head.get_position().y + 48))
				beam.groundplane = -320
				add_child(beam)
				beam_current_delay += 1
				attack_current_cooldown = 0
				new_animation = "beam"
			else:
				for i in range(0, 6):
					x = cos(i * PI/3) * 32
					var r = pow(32, 2) - pow(x, 2)
					var s = 1
					if (fmod(currentx, 2*PI) > PI):
						s = -1
					var y = sqrt(abs(r))/2.0*s
					var fire = fireclass.instance()
					fire.set_global_position(Vector2(get_global_position().x + x, get_global_position().y + y))
					fire.pivot = fire.get_global_position()
					fire.initangle = i * PI/3
					fire.currentx = fire.initangle
					get_parent().add_child(fire)
				attack_current_cooldown = 0
		elif (beam_current_delay > 0 && beam_current_delay < BEAM_DELAY):
			beam_current_delay += 1
			new_animation = "beam"
		else:
			beam_current_delay = 0
			if (beam != null):
				beam.queue_free()
				beam = null
			attack_current_cooldown += 1
			new_animation = "fly"
	elif (cycle == "docking"):
		# fly over to statue to dock at
		var deltaX = (current_statue.get_global_position().x + 16 - get_global_position().x) / 2.0
		deltaX = sign(deltaX) * min(abs(deltaX), 5)
		var deltaY = (current_statue.get_global_position().y - 32 - get_global_position().y) / 2.0
		deltaY = sign(deltaY) * min(abs(deltaY), 5)
		var x = get_global_position().x + deltaX
		var y = get_global_position().y + deltaY
		set_global_position(Vector2(x, y))
		if (abs(x - current_statue.get_global_position().x - 16) < 1 && abs(y - current_statue.get_global_position().y + 32) < 1):
			cycle = "docked"
			current_statue.show_collision()
	elif (cycle == "docked"):
		# docked; don't do anything other than check statue status
		# and countdown
		if (current_statue.dying):
			statues.erase(current_statue)
			combo = null
			cycle = "undocking"
			heads.get_node(current_statue.get_name()).hide()
			heads.get_node("head").show()
			check_statues()
			animation_player.play()
		docking_current_delay += 1
		if (docking_current_delay >= DOCKING_DELAY):
			docking_current_delay = 0
			current_statue.hide_collision()
			combo = null
			heads.get_node(current_statue.get_name()).hide()
			heads.get_node("head").show()
			cycle = "undocking"
			animation_player.play()
	elif (cycle == "undocking"):
		# move back to regular flying pattern
		new_animation = "fly"
		var x = cos(currentx)
		x = -640 - x * 256
		var deltaX = (x - get_global_position().x) / 2.0
		deltaX = sign(deltaX) * min(abs(deltaX), 5)
		var y = camera.get_global_position().y - 164
		var deltaY = (y - get_global_position().y) / 2.0
		deltaY = sign(deltaY) * min(abs(deltaY), 5)
		set_global_position(Vector2(get_global_position().x + deltaX, get_global_position().y + deltaY))
		if (abs(get_global_position().x - x) < 1):
			cycle = "display"
	elif (cycle == "dying"):
		# show death animation
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
		# drop items
		var item = sapphirekeyclass.instance()
		if (ProjectSettings.get("inventory").inventory.has("ITEM_SAPPHIREKEY")):
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
	if (cycle == "docking" || cycle == "docked"):
		animation_player.stop(false)
	else:
		if (new_animation != current_animation):
			current_animation = new_animation
			animation_player.play(current_animation)

func check_statues():
	if (statues.size() == 0):
		cycle = "dying"
