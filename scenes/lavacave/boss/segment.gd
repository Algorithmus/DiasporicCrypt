
extends Node2D

# move neck segments with curve

var curve
var offset
export var percent = 0.0

func _ready():
	pass

func set_curve(value):
	curve = value
	set_physics_process(true)

func _physics_process(delta):
	var pos = percent * curve.get_baked_length()
	var point = curve.interpolate_baked(pos)
	set_position(point)
