extends Node

# Moves camera to a specific position to show the effect of pressing a switch or clearing certain objects

# camera variables for showing switch targets when far away
var camera
var camera_progress = 0
var camera_pause = 0
var camera_pos = Vector2()
var final_camera_pos = Vector2()
const CAMERA_PAUSE_LENGTH = 75
var target

func _ready():
	pass

func start_spy(cycle, targets, target_pos):
	target.set_pause_mode(PAUSE_MODE_PROCESS)
	if (typeof(targets) == TYPE_ARRAY):
		var size = targets.size()
		for index in range(0, size):
			targets[index].set_pause_mode(PAUSE_MODE_PROCESS)
	else:
		targets.set_pause_mode(PAUSE_MODE_PROCESS)
	target.get_tree().set_pause(true)
	camera_pos = camera.get_offset()
	final_camera_pos = target_pos - camera.get_parent().get_position()
	camera_progress = cycle
	Globals.set("show_switch", true)

func step_camera(cycle, targets):
	# pause to display the effects of activating the switch/clearing all objects
	if (abs(camera_progress - PI/2) < cycle):
		camera_pause += 1
		camera.set_offset(final_camera_pos)
		if (camera_pause == CAMERA_PAUSE_LENGTH/2):
			target.activate()
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
			target.set_pause_mode(PAUSE_MODE_INHERIT)
			if (typeof(targets) == TYPE_ARRAY):
				var size = targets.size()
				for index in range(0, size):
					targets[index].set_pause_mode(PAUSE_MODE_INHERIT)
			else:
				targets.set_pause_mode(PAUSE_MODE_INHERIT)
			target.get_tree().set_pause(false)
			Globals.set("show_switch", false)
			return false
	return true
