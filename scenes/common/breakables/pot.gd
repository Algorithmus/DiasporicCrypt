
extends "res://scenes/common/breakables/BaseBreakable.gd"

# possible values: NONE, ITEM, SWITCH
export var type = "NONE"
# ITEM: class name of the item
# SWITCH: path from tilemap to the switch
export var reward = ""
export var value = 0

var reward_obj
var tilemap
var animation_player
var current_animation = "idle"

func _ready():
	crumble_delay = 100
	tilemap = get_parent().get_parent()
	animation_player = get_node("AnimationPlayer")
	if (type == "ITEM"):
		reward_obj = load(reward).instance()
		reward_obj.set("value", value)
		reward_obj.set_position(Vector2(get_position().x, get_position().y + 32))
	elif (type == "SWITCH"):
		reward_obj = tilemap.get_node(reward)
	set_physics_process(false)

func _physics_process(delta):
	if (is_crumbling && current_animation == "idle"):
		current_animation = "break"
	update_animation()

func update_animation():
	if (animation_player.get_assigned_animation() != current_animation):
		animation_player.play(current_animation)

func crumble():
	if (type == "ITEM"):
		get_parent().add_child(reward_obj)
	elif (type == "SWITCH"):
		reward_obj.enable(true)
		reward_obj.set_physics_process(true)
