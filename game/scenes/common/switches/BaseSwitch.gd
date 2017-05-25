
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
var tilemap
var onscreen = false
var default_on = is_on

# camera variables for showing switch targets when far away
var camera
var camera_progress = 0
var camera_pause = 0
var camera_pos = Vector2()
var final_camera_pos = Vector2()
const CAMERA_PAUSE_LENGTH = 75

func _ready():
	tilemap = get_parent().get_parent()
	camera = get_tree().get_root().get_node("world/playercontainer/player/Camera2D")
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
		set_fixed_process(true)

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
		set_fixed_process(true)
	else:
		set_fixed_process(false)

func step_camera(cycle):
	# pause to display the effects of activating the switch
	if (abs(camera_progress - PI/2) < cycle):
		camera_pause += 1
		camera.set_offset(final_camera_pos)
		if (camera_pause == CAMERA_PAUSE_LENGTH/2):
			activate()
		if (camera_pause >= CAMERA_PAUSE_LENGTH):
			camera_progress += cycle
	else:
		var offset = Vector2(lerp(camera_pos.x, final_camera_pos.x, sin(camera_progress)), lerp(camera_pos.y, final_camera_pos.y, sin(camera_progress)))
		camera.set_offset(offset)
		camera_progress += cycle
		if (abs(camera_progress - PI) < cycle):
			camera_progress = 0
			camera_pause = 0
			camera.set_offset(camera_pos)
			set_pause_mode(PAUSE_MODE_INHERIT)
			var size = target_containers.size()
			for index in range(0, size):
				targets[index].set_pause_mode(PAUSE_MODE_INHERIT)
			get_tree().set_pause(false)
			Globals.set("show_switch", false)

func _fixed_process(delta):
	var size = target_containers.size()
	var previous_is_on = is_on
	var cycle = delta*(1.0/4)*PI*2.0
	# display the switch targets
	if (camera_progress > 0):
		step_camera(cycle)
	elif ((once && !activated) || !once):
		var update = check_activation()
		if (update):
			# only display the switch targets once when switch state changes
			if (size > 0 && show_target && is_on != default_on && previous_is_on != is_on):
				set_pause_mode(PAUSE_MODE_PROCESS)
				for index in range(0, size):
					targets[index].set_pause_mode(PAUSE_MODE_PROCESS)
				get_tree().set_pause(true)
				camera_pos = camera.get_offset()
				final_camera_pos = target_pos - camera.get_parent().get_pos()
				camera_progress = cycle
				Globals.set("show_switch", true)
			else:
				activate()

func check_activation():
	return false