
extends "res://scenes/common/damagables/BaseMovingEnemy.gd"

var consumable = false
var base_consume_value = 10
var blood = preload("res://scenes/common/blood.xml")
var blood_particles = []
var current_consume_value
var color_increments = Color()
var consumable_instance = preload("res://scenes/common/damagables/consumable.xml")
var consumable_offset

func _ready():
	hp = 50
	current_consume_value = base_consume_value * (randf() * 0.5 - 0.25) + base_consume_value
	var color = get_node("die").get_modulate()
	color_increments = Color((1 - color.r)/current_consume_value, -color.g/current_consume_value, -color.b/current_consume_value)
	consumable_offset = sprite_offset
	
func cleanup_bloodparticles():
	# clean up blood particles
	for i in blood_particles:
		if(!i.get_node("particles").is_emitting()):
			if (has_node(i.get_name())):
				remove_child(i)
			blood_particles.erase(i)
	if (blood_particles.empty() && current_consume_value <= 0):
		queue_free()
		
func check_animations(new_animation, animation_speed, horizontal_motion, ladderY):
	var new_animation = .check_animations(new_animation, animation_speed, horizontal_motion, ladderY)
	if (consumable):
		new_animation["animation"] = "die"
	return new_animation
	
func bleed():
	var blood_obj = blood.instance()
	add_child(blood_obj)
	blood_obj.set_pos(Vector2(randf()*consumable_offset.x + consumable_offset.x/2 - 16, sprite_offset.y - randf()*consumable_offset.y*2))
	blood_obj.get_node("particles").set_emitting(true)
	blood_obj.get_node("sound").play("blood")
	blood_particles.append(blood_obj)

	if (consumable):
		current_consume_value -= 1
		var color = get_node("die").get_modulate()
		get_node("die").set_modulate(Color(color.r + color_increments.r, color.g + color_increments.g, color.b + color_increments.b))
		if (current_consume_value <= 0):
			get_node("die").hide()

func horizontal_input_permitted():
	return .horizontal_input_permitted() && !consumable

func step_player(delta):
	.step_player(delta)
	cleanup_bloodparticles()

func die():
	# turn into consumable object instead of disappearing
	consumable = true
	is_dying = false
	if (has_node(damage_rect.get_name())):
		remove_child(damage_rect)
	var consumable_obj = consumable_instance.instance()
	consumable_offset = consumable_obj.get_node("CollisionShape2D").get_shape().get_extents()
	consumable_obj.set_pos(Vector2(0, sprite_offset.y - consumable_offset.y))
	add_child(consumable_obj)
	
func check_dying():
	bleed()
	.check_dying()