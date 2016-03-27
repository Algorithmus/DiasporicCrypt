
extends "res://scenes/items/BaseItem.gd"

var default_color = Color(1, 1, 1)
var full_color = Color(65/255.0, 65/255.0, 65/255.0)
var value

func _ready():
	title = "exp"
	item = itemfactory_obj.items[title]
	item["value"] = value

func set_value(amount):
	value = amount
	var scale = float(max(min(amount, 2000), 50) - 50) / 1950
	var size = 0.75 * scale + 0.25
	var color = default_color.linear_interpolate(full_color, scale)
	set_scale(Vector2(size, size))
	get_node("Sprite").get_material().set_shader_param("modulate_color", color)

func take_item(i):
	i.get_exp_orb(value)
	.take_item(i)

func add_to_inventory():
	pass