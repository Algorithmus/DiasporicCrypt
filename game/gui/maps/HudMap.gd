
extends Polygon2D

# Displays an HUD minimap.

var unit_class = preload("res://gui/maps/unit.tscn")
const MAP_SCALE = 0.05
var objects
var current_teleport
var previous_id
var camera
var offset
var current_map
var rooms = {}
#256, 176
func _ready():
	if (!Globals.has("mapid")):
		Globals.set("mapid", "LVL_START")
	objects = get_node("objects")
	set_fixed_process(true)
	offset = Vector2(get_polygon()[1].x/2.0, get_polygon()[2].y/2.0)

func _fixed_process(delta):
	# update map position when player moves
	if (current_map != null):
		var map = rooms[current_map]
		objects.set_pos(Vector2(round(offset.x - map.get_pos().x - camera.get_camera_pos().x*MAP_SCALE), round(offset.y - map.get_pos().y - camera.get_camera_pos().y*MAP_SCALE)))

func reset():
	rooms = {}
	current_map = null
	Globals.set("mapobjects", {})
	Globals.set("mapindex", {})

func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
	draw_circle(offset, 2, Color(1, 0, 0))

func clear_objects():
	for i in objects.get_children():
		objects.remove_child(i)

func load_map(root_node):
	current_map = root_node.get_filename()
	if (!rooms.has(root_node.get_filename())):
		create_map(root_node)

func load_cached_map(root_node):
	if (Globals.has("mapindex")):
		rooms = Globals.get("mapindex")
	var mapid = Globals.get("mapid")
	if (Globals.has("mapobjects") && Globals.get("mapobjects").has(mapid)):
		var cache = Globals.get("mapobjects")[mapid]
		remove_child(objects)
		objects.queue_free()
		add_child(cache)
		objects = cache
	elif(rooms.has(root_node.get_filename())):
		objects.add_child(rooms[root_node.get_filename()])
	load_map(root_node)

func cache_map():
	print("cache map")
	print(Globals.get("mapid"))
	if (!Globals.has("mapobjects")):
		Globals.set("mapobjects", {})
	Globals.get("mapobjects")[Globals.get("mapid")] = objects.duplicate()
	Globals.set("mapindex", rooms)

func create_map(root_node):
	# create room
	var unit = unit_class.instance()
	var nw = root_node.get_node("tilemap/boundaries/NW").get_global_pos()
	var se = root_node.get_node("tilemap/boundaries/SE").get_global_pos()
	var boundaries = [Vector2(nw.x*MAP_SCALE, nw.y*MAP_SCALE), Vector2(se.x*MAP_SCALE, nw.y*MAP_SCALE), Vector2(se.x*MAP_SCALE, se.y*MAP_SCALE), Vector2(nw.x*MAP_SCALE, se.y*MAP_SCALE)]
	unit.get_node("area").set_polygon(boundaries)
	unit.get_node("border").set_polygon(boundaries)
	var previous_node
	var current_node
	# position room relative to previous room if there is one
	if (current_teleport != null):
		previous_node = previous_id
	# mark exits in room
	var teleports = root_node.get_node("tilemap/TeleportGroup")
	for teleport in teleports.get_children():
		if (previous_node != null && teleport.get("target_level") == previous_node):
			current_node = teleport
		var gate = Polygon2D.new()
		gate.set_color(Color(1, 0, 0))
		var scale = teleport.get_node("teleport").get_scale()
		var boundaries = []
		if (teleport.get("is_horizontal")):
			boundaries = [Vector2(0, -scale.y*16*MAP_SCALE), Vector2(1, -scale.y*16*MAP_SCALE), Vector2(1, scale.y*16*MAP_SCALE), Vector2(0, scale.y*16*MAP_SCALE)]
			gate.set_pos(teleport.get_global_pos()*MAP_SCALE)
		else:
			boundaries = [Vector2(-scale.x*16*MAP_SCALE, 0), Vector2(scale.x*16*MAP_SCALE, 0), Vector2(scale.x*16*MAP_SCALE, 1), Vector2(-scale.x*16*MAP_SCALE, 1)]
			gate.set_pos(Vector2(teleport.get_global_pos().x*MAP_SCALE, teleport.get_global_pos().y*MAP_SCALE - 1))
		gate.set_polygon(boundaries)
		unit.add_child(gate)
	if (previous_node != null && rooms.has(previous_node) && current_node != null):
		var previous_node_pos = rooms[previous_node].get_pos()
		var previous_node_teleport = current_teleport.get_global_pos()*MAP_SCALE
		var current_node_teleport = current_node.get_global_pos()*MAP_SCALE
		unit.set_pos(Vector2(previous_node_pos.x + previous_node_teleport.x - current_node_teleport.x, previous_node_pos.y + previous_node_teleport.y - current_node_teleport.y))
	objects.add_child(unit)
	rooms[root_node.get_filename()] = unit
	print("save room to")
	print(root_node.get_filename())
