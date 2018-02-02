
# Watch current room for certain conditions (usually the existence of certain objects in a group)
# If there are no more of those objects left, a reward item is revealed.

# Eg, kill all enemies in a room to make a platform appear.

extends Node

export var reward = ""
export var target_container = ""
export var watch_class = ""
export var invert = false

export var show_target = false
export var target_pos = Vector2()

var targets = []
var target_containers = []
var switches = []
var onscreen = false

var target
var reward_obj
var reward_container
var tilemap
var class_obj

var targetspy = preload("res://scenes/common/TargetSpy.gd").new()

func _ready():
	class_obj = load(watch_class)
	tilemap = get_parent()
	var camera = get_tree().get_root().get_node("world/playercontainer/player/Camera2D")
	targetspy.set("camera", camera)
	targetspy.set("target", self)
	target = tilemap.get_node(target_container)
	reward_obj = tilemap.get_node(reward)
	reward_container = reward_obj.get_parent()
	if (!invert):
		reward_container.remove_child(reward_obj)
	set_physics_process(true)

func activate():
	if (invert):
		reward_container.remove_child(reward_obj)
	else:
		reward_container.add_child(reward_obj)

func _physics_process(delta):
	var cleared = true
	for watch_obj in target.get_children():
		if (watch_obj is class_obj):
			cleared = false
	var cycle = delta*(1.0/4)*PI*2.0
	if (cleared && !show_target):
		activate()
		set_physics_process(false)
	elif (cleared && targetspy.get("camera_progress") == 0):
		# only display the switch targets once when switch state changes
		targetspy.start_spy(cycle, targets, target_pos)
	# display the switch targets
	if (targetspy.get("camera_progress") > 0):
		if (!targetspy.step_camera(cycle, targets)):
			set_physics_process(false)
