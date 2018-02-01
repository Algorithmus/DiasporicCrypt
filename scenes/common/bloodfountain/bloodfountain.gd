
extends Node2D

var blood = preload("res://scenes/common/blood.tscn")
var blood_particles = []
var current_consume_value = 100
var consumable_offset
var consume_factor = 50

func _ready():
	consumable_offset = get_node("consumable/CollisionShape2D").get_shape().get_extents()

func bleed():
	var blood_obj = blood.instance()
	add_child(blood_obj)
	blood_obj.set_position(Vector2(randf()*consumable_offset.x + consumable_offset.x/2 - 16, consumable_offset.y - randf()*consumable_offset.y*2))
	blood_obj.get_node("particles").set_emitting(true)
	blood_obj.get_node("sound").play("blood")
	blood_particles.append(blood_obj)
