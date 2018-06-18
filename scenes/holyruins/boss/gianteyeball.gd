
extends "res://scenes/common/target.gd"

#Implementation for Giant Eyeball boss

# moves horizontally across the screen and has two kinds of attacks:
# *create a sunbeam that fills almost the entire room
# *respawn enemies

const ATTACK_COOLDOWN = 500
var current_attack_delay = 0
const SUNBEAM_DELAY = 200
var current_sunbeam_delay = 0
var respawnpos = [Vector2(48, 432), Vector2(-96, 272), Vector2(-288, 432)]
var spawnclass = preload("res://scenes/holyruins/boss/eyeball.tscn")
var topazkeyclass = preload("res://scenes/items/special/topazkey.tscn")
var manapotionplusclass = preload("res://scenes/items/potion/manapotionplus.tscn")
var expclass = preload("res://scenes/items/exporb/exporb.tscn")
var cycle = "active"
var hp = 100
var current_hp = 100
var ep = 5000
var currentx = 0
var sunbeam
const RED = Color(1, 56/255.0, 56/255.0)

func _ready():
	sunbeam = get_parent().get_node("Sunbeam")

func _physics_process(delta):
	if (cycle != "sunbeam" && get_parent().has_node(sunbeam.get_name())):
		get_parent().remove_child(sunbeam)
	if (!frozen):
		var new_animation = current_animation
		if (cycle == "active"):
			currentx += PI/60
			var x = cos(currentx)
			set_global_position(Vector2(48 + x * 320, get_global_position().y))
			var spawncount = 0
			# respawn enemies when there are none left
			var objects = get_parent().get_parent().get_children()
			for object in objects:
				if (object is spawnclass.instance().get_script()):
					spawncount += 1
			if (spawncount == 0):
				for pos in respawnpos:
					var spawn = spawnclass.instance()
					spawn.set_global_position(pos)
					get_parent().get_parent().add_child(spawn)
			current_attack_delay += 1
			if (current_attack_delay >= ATTACK_COOLDOWN):
				cycle = "flash"
				new_animation = "flash"
				current_attack_delay = 0
		elif (cycle == "flash"):
			# warn player before sunbeam attack
			if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length()):
				cycle = "sunbeam"
				new_animation = "idle"
				get_parent().add_child(sunbeam)
		elif (cycle == "sunbeam"):
			current_sunbeam_delay += 1
			if (current_sunbeam_delay >= SUNBEAM_DELAY):
				cycle = "active"
				current_sunbeam_delay = 0
		elif (cycle == "dying"):
			new_animation = "die"
			if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length()):
				cycle = "die"
				ProjectSettings.set("current_quest_complete", true)
				var level = ProjectSettings.get("levels")[ProjectSettings.get("current_level")]
				level.complete = true
				get_tree().get_root().get_node("world").check_available_levels()
				ProjectSettings.get("levels")[ProjectSettings.get("current_level")] = level
				var level_display = get_tree().get_root().get_node("world/gui/CanvasLayer/level")
				level_display.get_node("title").set_text("KEY_VICTORY")
				level_display.get_node("AnimationPlayer").play("quest")
		else:
			var item = topazkeyclass.instance()
			if (ProjectSettings.get("inventory").inventory.has("ITEM_TOPAZKEY")):
				item = manapotionplusclass.instance()
			var exporb = expclass.instance()
			var bonus = ProjectSettings.get("bonus_effects")
			var rate = 1
			if (bonus.exp):
				rate = 2
			exporb.set_value(ep * rate)
			exporb.set_global_position(Vector2(48, 528))
			item.set_global_position(Vector2(48, 496))
			get_parent().get_parent().add_child(exporb)
			get_parent().get_parent().add_child(item)
			set_physics_process(false)
			get_parent().queue_free()
		update_animation(new_animation)
	
func check_hp(damage):
	current_hp -= damage
	var damage_color = Color(1, 1, 1).linear_interpolate(RED, current_hp / hp)
	get_node("sprite").set_modulate(damage_color)
	if (current_hp <= 0):
		cycle = "dying"
		dying = true
		collision_rect.queue_free()
		update_animation("die")
