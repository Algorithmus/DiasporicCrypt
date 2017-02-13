extends Node

# Continuously spawn objects (mostly enemies) until a certain amount has been reached

export var spawn_object = "res://scenes/common/damagables/sorcerer/sorcerer.tscn"
export var spawn_amount = 3
export var spawn_delay = 100
export var spawn_radius = 1
export var spawn_container = "EnemiesGroup"
var spawn_class
var spawn_group
var current_delay = 0
var spawning = false
var spawn_index = 0
var spawn_angle

func _ready():
	spawn_class = load(spawn_object)
	spawn_group = get_parent().get_parent().get_node(spawn_container)
	spawn_angle = PI/(spawn_amount - 1)

func _fixed_process(delta):
	if (spawn_group.get_child_count() == 0):
		spawning = true
		current_delay = 0
		spawn_index = 0
	if (spawning):
		if (spawn_index < spawn_amount && current_delay == 0):
			var spawn = spawn_class.instance()
			spawn.set_global_pos(Vector2(get_global_pos().x + spawn_radius * 32 * cos(spawn_index * spawn_angle), get_global_pos().y + spawn_radius * 32 * -sin(spawn_index * spawn_angle)))
			spawn_group.add_child(spawn)
			spawn_index += 1
			if (spawn_index >= spawn_amount):
				spawning = false
		current_delay += 1
		if (current_delay >= spawn_delay):
			current_delay = 0

func enter_screen():
	set_fixed_process(true)

func exit_screen():
	set_fixed_process(false)
