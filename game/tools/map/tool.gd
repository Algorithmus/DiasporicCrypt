extends Control

# Displays various statistics about discovery tiles in the rooms in each level.

# This tool is used externally from the rest of the game, and is not included in
# exported releases.
# You can use this tool to figure out how many tiles to use for discovery tile total count
# for each level.

# Level statistics
# Total Tiles - total number of pixels in the map that this level consists of. This value
# is just taken from the sum of all the rooms in this level (ie, every room in the corresponding 
# folder for this level)

# Room statistics
# Grid - dimensions of the discovery grid
# Total Tiles - total number of pixels in the map that this room covers
# Tile Size - pixel size of each regular tile

# The following statistics are provided because there is no restriction on
# the size of each room that prevents it from not being divisible by the size
# of the discovery grid
# There are possible situations (quite likely) where tiles at the bottom or right
# side of the grid are smaller than the normal tile size.

# Horizontal Tile Size - pixel size of each tile in the bottom row of the 
# discovery grid for this room
# Vertical Tile Size - pixel size of each tile in the right column of the
# discovery grid for this room
# Corner Tile Size - pixel size of the tile in the bottom right corner of the
# discovery grid for this room

# List of all the levels for which statistics should be displayed
var list = [
"res://levels/aquaduct", 
"res://levels/bergfortress", 
"res://levels/crypt", 
"res://levels/dungeon", 
"res://levels/holyruins", 
"res://levels/icecave", 
"res://levels/lavacave", 
"res://levels/marblecastle", 
"res://levels/mausoleum", 
"res://levels/roomoftrials", 
"res://levels/springislandcastle", 
"res://levels/waterway", 
"res://levels/winterislandcastle"
]

var HudMap = preload("res://gui/maps/HudMap.gd")
var Grid = preload("res://gui/maps/grid.gd")
var roomobj = preload("res://tools/map/room.tscn")
var levelobj = preload("res://tools/map/level.tscn")
var container

func _ready():
	container = get_node("statistics/container")
	var normal_size = round(Grid.GRID_SIZE.x * Grid.GRID_SIZE.y * pow(HudMap.MAP_SCALE, 2))
	var size = list.size()
	for i in range(0, size):
		var leveldir = list[i]
		var level = levelobj.instance()
		level.get_node("title/value").set_text(leveldir)
		var dir = Directory.new()
		var file = File.new()
		var level_total = 0
		container.add_child(level)
		if (dir.dir_exists(leveldir)):
			if(dir.open(leveldir) == 0):
				dir.list_dir_begin()
				var filename = dir.get_next()
				while (filename != ""):
					if (!dir.current_is_dir()):
						var room = load(leveldir + "/" + filename).instance()
						var boundaries = room.get_node("tilemap/boundaries")
						var nw = boundaries.get_node("NW").get_global_pos()
						var se = boundaries.get_node("SE").get_global_pos()
						var total_range = (se - nw) * HudMap.MAP_SCALE
						var total = round(total_range.x * total_range.y)
						level_total += total
						var imagewidth = se.x - nw.x
						var imageheight = se.y - nw.y
						var gridy = ceil(float(imageheight) / Grid.GRID_SIZE.y)
						var gridx = ceil(float(imagewidth) / Grid.GRID_SIZE.x)
						var gridx_size = floor(float(imagewidth) * HudMap.MAP_SCALE / gridx)
						var gridy_size = floor(float(imageheight) * HudMap.MAP_SCALE / gridy)
						var vertical_size = round((imagewidth - (Grid.GRID_SIZE.x * (gridx - 1))) * HudMap.MAP_SCALE)
						var horizontal_size = round((imageheight - (Grid.GRID_SIZE.y * (gridy - 1))) * HudMap.MAP_SCALE)
						var room_node = roomobj.instance()
						room_node.get_node("title/value").set_text(filename)
						room_node.get_node("grid/value").set_text(str(gridx) + "x" + str(gridy))
						room_node.get_node("total/value").set_text(str(total))
						room_node.get_node("size/value").set_text(str(normal_size))
						room_node.get_node("horizontal/value").set_text(str(horizontal_size * round(Grid.GRID_SIZE.x * HudMap.MAP_SCALE)))
						room_node.get_node("vertical/value").set_text(str(vertical_size * round(Grid.GRID_SIZE.y * HudMap.MAP_SCALE)))
						room_node.get_node("corner/value").set_text(str(vertical_size * horizontal_size))
						container.add_child(room_node)
					filename = dir.get_next()
				dir.list_dir_end()
		level.get_node("total/value").set_text(str(level_total))