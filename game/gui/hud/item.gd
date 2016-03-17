
extends Node2D

var expire = 100
var delay = 0
var expired = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if (!expired):
		delay += 1
		if (delay >= expire):
			expired = true
