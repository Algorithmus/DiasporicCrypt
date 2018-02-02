
extends Polygon2D

# Displays an HUD minimap.

var unit_class = preload("res://gui/maps/unit.tscn")
const MAP_SCALE = 0.05
var objects
var current_teleport
var previous_id
var camera
var map_offset
var current_map
var rooms = {}
var grids = {}

# discoverability
# See more details for discoverability in grid.tscn
var gridobj = preload("res://gui/maps/grid.tscn")
var gridclass = preload("res://gui/maps/grid.gd")
var current_grid

#256, 176
func _ready():
	if (!ProjectSettings.has("mapid")):
		ProjectSettings.set("mapid", "LVL_START")
	objects = get_node("objects")
	set_physics_process(true)
	map_offset = Vector2(get_polygon()[1].x/2.0, get_polygon()[2].y/2.0)

func _physics_process(delta):
	# update map position when player moves
	if (current_map != null):
		var map = rooms[current_map]
		objects.set_position(Vector2(round(map_offset.x - map.get_position().x - camera.get_camera_position().x*MAP_SCALE), round(map_offset.y - map.get_position().y - camera.get_camera_position().y*MAP_SCALE)))
		discover_tiles()

# check for map tiles player has already been in
func discover_tiles():
	var pos = camera.get_camera_position()
	var map_offset = camera.get_offset() * MAP_SCALE
	var boundaries = rooms[current_map].get_node("area").get_polygon()
	var grid = rooms[current_map].get_node("grid")
	var start = boundaries[0]
	var end = boundaries[2]
	var grid_range = end - start
	pos = pos*MAP_SCALE - start
	var startx = max(floor(float(pos.x + map_offset.x) / (gridclass.GRID_SIZE.x * MAP_SCALE)), 0)
	var endx = min(ceil(float(pos.x - map_offset.x) / (gridclass.GRID_SIZE.x * MAP_SCALE)), current_grid[0].size() - 1)
	var starty = max(floor(float(pos.y + map_offset.y) / (gridclass.GRID_SIZE.y * MAP_SCALE)), 0)
	var endy = min(ceil(float(pos.y - map_offset.y) / (gridclass.GRID_SIZE.y * MAP_SCALE)), current_grid.size() - 1)
	grid.mark_grid(Vector2(startx, endx), Vector2(starty, endy), current_grid)

func reset():
	rooms = {}
	grids = {}
	current_map = null
	ProjectSettings.set("mapobjects", {})
	ProjectSettings.set("mapindex", {})
	ProjectSettings.set("grids", {})

func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
	draw_circle(map_offset, 2, Color(1, 0, 0))

func clear_objects():
	for i in objects.get_children():
		objects.remove_child(i)

func load_map(root_node):
	current_map = root_node.get_filename()
	if (!rooms.has(root_node.get_filename())):
		create_map(root_node)
	current_grid = grids[current_map]

func load_cached_map(root_node):
	if (ProjectSettings.has("mapindex")):
		rooms = ProjectSettings.get("mapindex")
	if (ProjectSettings.has("grids")):
		grids = ProjectSettings.get("grids")
	var mapid = ProjectSettings.get("mapid")
	if (ProjectSettings.has("mapobjects") && ProjectSettings.get("mapobjects").has(mapid)):
		var cache = ProjectSettings.get("mapobjects")[mapid]
		for map in cache.get_children():
			rooms[map.level] = map
		remove_child(objects)
		objects.queue_free()
		add_child(cache)
		objects = cache
	elif(rooms.has(root_node.get_filename())):
		objects.add_child(rooms[root_node.get_filename()])
	load_map(root_node)

func cache_map():
	if (!ProjectSettings.has("mapobjects")):
		ProjectSettings.set("mapobjects", {})
	ProjectSettings.get("mapobjects")[ProjectSettings.get("mapid")] = objects.duplicate()
	ProjectSettings.set("mapindex", rooms)
	ProjectSettings.set("grids", grids)

func create_map(root_node):
	# create room
	var unit = unit_class.instance()
	unit.level = root_node.get_filename()
	var nw = root_node.get_node("tilemap/boundaries/NW").get_global_position()
	var se = root_node.get_node("tilemap/boundaries/SE").get_global_position()
	var boundaries = [Vector2(nw.x*MAP_SCALE, nw.y*MAP_SCALE), Vector2(se.x*MAP_SCALE, nw.y*MAP_SCALE), Vector2(se.x*MAP_SCALE, se.y*MAP_SCALE), Vector2(nw.x*MAP_SCALE, se.y*MAP_SCALE)]
	unit.get_node("area").set_polygon(boundaries)
	unit.get_node("border").set_polygon(boundaries)
	var imagewidth = se.x - nw.x
	var imageheight = se.y - nw.y
	current_grid = []
	var gridy = ceil(float(imageheight) / gridclass.GRID_SIZE.y)
	var gridx = ceil(float(imagewidth) / gridclass.GRID_SIZE.x)
	for i in range(0, gridy):
		var row = []
		for j in range(0, gridx):
			row.append(false)
		current_grid.append(row)
	var grid = gridobj.instance()
	grid.init(nw * MAP_SCALE, imagewidth * MAP_SCALE, imageheight * MAP_SCALE, current_grid)
	unit.add_child(grid)
	var previous_node
	var current_node
	# position room relative to previous room if there is one
	if (current_teleport != null):
		previous_node = previous_id
	# mark exits in room
	var teleports = root_node.get_node("tilemap/TeleportGroup")
	for teleport in teleports.get_children():
		# check if the exit links to the previous room
		if (previous_node != null && teleport.get("target_level") == previous_node):
			var isCorrectTeleport = false
			# there may be multiple exits linking to the previous room
			# so check position as well
			if (teleport.get("is_horizontal")):
				isCorrectTeleport = current_teleport.get("teleport_to").y == teleport.get_global_position().y
			else:
				isCorrectTeleport = current_teleport.get("teleport_to").x == teleport.get_global_position().x
			if (isCorrectTeleport):
				current_node = teleport
		var gate = Polygon2D.new()
		gate.set_color(Color(1, 0, 0))
		var scale = teleport.get_node("teleport").get_scale()
		var teleport_boundaries = []
		if (teleport.get("is_horizontal")):
			teleport_boundaries = [Vector2(0, -scale.y*16*MAP_SCALE), Vector2(1, -scale.y*16*MAP_SCALE), Vector2(1, scale.y*16*MAP_SCALE), Vector2(0, scale.y*16*MAP_SCALE)]
			gate.set_position(teleport.get_global_position()*MAP_SCALE)
		else:
			teleport_boundaries = [Vector2(-scale.x*16*MAP_SCALE, 0), Vector2(scale.x*16*MAP_SCALE, 0), Vector2(scale.x*16*MAP_SCALE, 1), Vector2(-scale.x*16*MAP_SCALE, 1)]
			gate.set_position(Vector2(teleport.get_global_position().x*MAP_SCALE, teleport.get_global_position().y*MAP_SCALE - 1))
		gate.set_polygon(teleport_boundaries)
		unit.add_child(gate)
	if (previous_node != null && rooms.has(previous_node) && current_node != null):
		var previous_node_pos = rooms[previous_node].get_position()
		var previous_node_teleport = current_teleport.get_global_position()*MAP_SCALE
		var current_node_teleport = current_node.get_global_position()*MAP_SCALE
		unit.set_position(Vector2(previous_node_pos.x + previous_node_teleport.x - current_node_teleport.x, previous_node_pos.y + previous_node_teleport.y - current_node_teleport.y))
	objects.add_child(unit)
	rooms[root_node.get_filename()] = unit
	grids[root_node.get_filename()] = current_grid

func serializeVector2Array(array):
	var serialized = []
	for i in range(0, array.size()):
		var vector = array[i]
		serialized.push_back([vector.x, vector.y])
	return serialized

# Convert map data to JSON compatible format for saving
func serialize_room(map):
	var newmap = {}
	newmap.boundaries = serializeVector2Array(map.get_node("area").get_polygon())
	newmap.pos = [map.get_position().x, map.get_position().y]
	var gates = []
	for gate in map.get_children():
		if (gate.get_name() != "area" && gate.get_name() != "border" && gate.get_name() != "grid"):
			var newgate = {}
			newgate.boundaries = serializeVector2Array(gate.get_polygon())
			newgate.pos = [gate.get_position().x, gate.get_position().y]
			gates.push_back(newgate)
	newmap.gates = gates
	return newmap

# load room objects from JSON data
func unserialize_room(map):
	var unit = unit_class.instance()
	var boundaries = [Vector2(map.boundaries[0][0], map.boundaries[0][1]), Vector2(map.boundaries[1][0], map.boundaries[1][1]), Vector2(map.boundaries[2][0], map.boundaries[2][1]), Vector2(map.boundaries[3][0], map.boundaries[3][1])]
	unit.get_node("area").set_polygon(boundaries)
	unit.get_node("border").set_polygon(boundaries)
	var grid = gridobj.instance()
	var imagewidth = boundaries[2].x - boundaries[0].x
	var imageheight = boundaries[2].y - boundaries[0].y
	grid.init(boundaries[0], imagewidth, imageheight, ProjectSettings.get("grids")[map.id])
	unit.add_child(grid)
	# mark exits in room
	var teleports = map.gates
	for i in range(0, teleports.size()):
		var teleport = teleports[i]
		var gate = Polygon2D.new()
		gate.set_color(Color(1, 0, 0))
		var teleport_boundaries = [Vector2(teleport.boundaries[0][0], teleport.boundaries[0][1]), Vector2(teleport.boundaries[1][0], teleport.boundaries[1][1]), Vector2(teleport.boundaries[2][0], teleport.boundaries[2][1]), Vector2(teleport.boundaries[3][0], teleport.boundaries[3][1])]
		gate.set_position(Vector2(teleport.pos[0], teleport.pos[1]))
		gate.set_polygon(teleport_boundaries)
		unit.add_child(gate)
	unit.set_position(Vector2(map.pos[0], map.pos[1]))
	return unit
