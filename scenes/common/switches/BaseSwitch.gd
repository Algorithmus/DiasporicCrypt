
extends Node2D

export var once = false
var activated = false
export var is_on = false
export var target_nodes = []
export var related_switches = []
export var enabled = true
export var invert = false

export var show_target = false
export var target_pos = Vector2()

var targets = []
var target_containers = []
var switches = []
var checked = false # Don't process if a related active switch has already been processed
var tilemap
var onscreen = false
var default_on

var targetspy = preload("res://scenes/common/TargetSpy.gd").new()

func _ready():
	default_on = is_on
	tilemap = get_parent().get_parent()
	var camera = get_tree().get_root().get_node("world/playercontainer/player/Camera2D")
	targetspy.set("camera", camera)
	targetspy.set("target", self)
	if (target_containers.empty()):
		for target in target_nodes:
			var target_obj = tilemap.get_node(target)
			targets.append(target_obj)
			target_containers.append(target_obj.get_parent())

	if (switches.empty()):
		for i in related_switches:
			var switch_obj = tilemap.get_node(i)
			switches.append(switch_obj)
	if (enabled):
		set_physics_process(true)
	else:
		set_physics_process(false)

func activate():
	if ((!is_on && !invert) || (is_on && invert)):
		var size = target_containers.size()
		for index in range(0, size):
			if (target_containers[index].has_node(targets[index].get_name())):
				target_containers[index].remove_child(targets[index])
			activated = true
	elif ((is_on && !invert) || (!is_on && invert)):
		var size = target_containers.size()
		for index in range(0, size):
			if (!target_containers[index].has_node(targets[index].get_name())):
				target_containers[index].add_child(targets[index])
				activated = true

func enable(value):
	enabled = value
	if (enabled && onscreen):
		set_physics_process(true)
	else:
		set_physics_process(false)

func _physics_process(delta):
	var size = target_containers.size()
	var previous_is_on = is_on
	var cycle = delta*(1.0/4)*PI*2.0
	# display the switch targets
	if (targetspy.get("camera_progress") > 0):
		targetspy.step_camera(cycle, targets)
	elif ((once && !activated) || !once):
		var update = false
		if (!checked):
			update = check_activation()
		if (update):
			# only display the switch targets once when switch state changes
			if (size > 0 && show_target && is_on != default_on && previous_is_on != is_on):
				targetspy.start_spy(cycle, targets, target_pos)
			else:
				activate()
	checked = false

func check_activation():
	return false
