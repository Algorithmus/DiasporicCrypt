
extends Node2D

export var once = false
var activated = false
export var is_on = false
export var target_nodes = []
var targets = []
var target_containers = []
var tilemap

func _ready():
	tilemap = get_parent().get_parent()
	for target in target_nodes:
		print(target)
		var target_obj = tilemap.get_node(target)
		print(target_obj)
		targets.append(target_obj)
		target_containers.append(target_obj.get_parent())
	activate()
	activated = false

func activate():
	if (!is_on):
		var size = target_containers.size()
		for index in range(0, size):
			if (target_containers[index].has_node(targets[index].get_name())):
				target_containers[index].remove_child(targets[index])
			activated = true
	elif (is_on):
		var size = target_containers.size()
		for index in range(0, size):
			if (!target_containers[index].has_node(targets[index].get_name())):
				target_containers[index].add_child(targets[index])
				activated = true

func _fixed_process(delta):
	if ((once && !activated) || !once):
		check_activation()
		activate()

func enter_screen():
	set_fixed_process(true)

func exit_screen():
	set_fixed_process(false)

func check_activation():
	pass