
extends Control

var container
var itemclass = preload("res://gui/hud/item.tscn")
var itemicon = preload("res://gui/hud/potion.png")
var specialicon = preload("res://gui/hud/special.png")
var goldicon = preload("res://gui/hud/gold.png")
var exporbicon = preload("res://gui/hud/exporb.png")
var scrollicon = preload("res://gui/hud/scroll.png")
var magicicon = preload("res://gui/hud/magic.png")
var keyboardmap = preload("res://gui/InputCharacters.gd").new()

var lastitemtype

func _ready():
	container = get_node("container")
	set_physics_process(true)

func display_item(title, item_obj):
	var item = itemclass.instance()
	var icon = itemicon
	if (item_obj.type == "exp"):
		title = str(item_obj.value) + tr("ITEM_EXP")
		icon = exporbicon
	if (item_obj.type == "gold"):
		title = str(item_obj.value) + "G"
		icon = goldicon
	if (item_obj.type == "special"):
		icon = specialicon
	if (item_obj.type == "magic"):
		icon = magicicon

	item.get_node("text").set_text(title)
	if (item_obj.type == "scroll"):
		icon = scrollicon
	lastitemtype = item_obj.type
	item.get_node("icon").set_texture(icon)
	item.set_position(Vector2(0, 84-container.get_position().y))
	container.add_child(item)
	container.set_position(Vector2(container.get_position().x, container.get_position().y - 20))

func _physics_process(delta):
	while (container.get_child_count() > 5):
		container.remove_child(container.get_child(0))
	for i in container.get_children():
		if (i.get("expired")):
			container.remove_child(i)
	if (container.get_child_count() == 0):
		container.set_position(Vector2(container.get_position().x, 84))
		get_node("input").hide()
		lastitemtype = null
	else:
		keyboardmap.update_keys()
		get_node("input").set_text(keyboardmap.map_action("ui_pause"))
		get_node("input").show()
