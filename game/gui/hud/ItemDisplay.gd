
extends Control

var container
var itemclass = preload("res://gui/hud/item.scn")
var itemicon = preload("res://gui/hud/potion.png")
var goldicon = preload("res://gui/hud/gold.png")
var exporbicon = preload("res://gui/hud/exporb.png")
var scrollicon = preload("res://gui/hud/scroll.png")

func _ready():
	container = get_node("container")
	set_fixed_process(true)

func display_item(title, item_obj):
	print(item_obj)
	var item = itemclass.instance()
	var icon = itemicon
	if (item_obj.type == "exp"):
		title = str(item_obj.value) + tr("ITEM_EXP")
		icon = exporbicon
	if (item_obj.type == "gold"):
		title = str(item_obj.value) + "G"
		icon = goldicon

	item.get_node("text").set_text(title)
	if (item_obj.type == "scroll"):
		icon = scrollicon
	item.get_node("icon").set_texture(icon)
	item.set_pos(Vector2(0, 84-container.get_pos().y))
	container.add_child(item)
	container.set_pos(Vector2(container.get_pos().x, container.get_pos().y - 20))

func _fixed_process(delta):
	while (container.get_child_count() > 5):
		container.remove_child(container.get_child(0))
	for i in container.get_children():
		if (i.get("expired")):
			container.remove_child(i)
	if (container.get_child_count() == 0):
		container.set_pos(Vector2(container.get_pos().x, 84))