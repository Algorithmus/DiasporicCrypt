
extends Node2D

var expire = 100
var delay = 0
var expired = false

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	if (!expired):
		delay += 1
		if (delay >= expire):
			expired = true

