extends Sprite

# Tracks map tiles player has already been in

# This information is stored in a 2D boolean array and rendered in an image texture
# Unfortunately, other algorithms that involve displaying the discovered tiles as a set of
# rectangles is NP Complete if you need there to be as few rectangles as possible and you allow
# for the possibility of holes in between the rectangles, so we put pixels in an image texture
# instead.

# We don't have the NP Complete problem anymore because we can completely avoid drawing every tile as a separate
# object and just rely on draw_rect(). We will have to render all the rectangles everytime a new tile is discovered,
# instead of only on loading the game, but only for the current room, and the performance is better than calling
# put_pixels O(n^2) times.

# Discoverability Tiles
# Every room has a discoverability grid that tracks where players have and haven't been.
# If the player touches a tile in the grid, the tile is marked as "discovered" and we update
# and render that tile in the map.
# For consistency, all the tiles in the grid are exactly the same size (GRID_SIZE).
# In HudMap.gd, we check the player's position against the position in the room and determine
# which tiles in the grid this correspond to. They're then marked as discovered, and if they
# weren't previously discovered, we render the new discovered tiles on the map.

const GRID_SIZE = Vector2(800 / 2, 592 / 2)
const GRIDFORMAT = Image.FORMAT_RGBA
const GRIDCOLOR = Color(79.69/255, 0, 1, 0.5)

var texture
var image
var HudMap = preload("res://gui/maps/HudMap.gd")
export var current_grid = []

func _ready():
	if (get_texture() != null):
		texture = get_texture()
		image = texture.get_data()

func init(pos, width, height, grid):
	set_offset(pos)
	texture = ImageTexture.new()
	texture.create(floor(width), floor(height), GRIDFORMAT)
	image = Image(texture.get_width(), texture.get_height(), false, GRIDFORMAT)
	texture.set_data(image)
	set_texture(texture)
	current_grid = grid

# set a specified range of tiles as discovered
# range consists of indexes in the grid
func mark_grid(indexx, indexy, grid):
	current_grid = grid
	var new_tiles = false
	for i in range(indexy.x, indexy.y + 1):
		var row = grid[i]
		var row_size = row.size()
		for j in range(indexx.x, indexx.y + 1):
			var cell = row[j]
			if (!cell):
				grid[i][j] = true
				new_tiles = true
				count_grid(j, i)
	if (new_tiles):
		update()
		texture.set_data(image)

func _draw():
	update_grid()

func update_grid():
	render_grid(current_grid)

# Render all discovered tiles at once
func render_grid(grid):
	current_grid = grid
	var col_size = grid.size()
	for y in range(0, col_size):
		var row = grid[y]
		var row_size = row.size()
		for x in range(0, row_size):
			var cell = row[x]
			if (cell):
				draw_grid(x, y)
	texture.set_data(image)

# Helper method to get affected regions
# Position is given in grid indexes.
func get_grid_positions(x, y):
	var startx = max(round(GRID_SIZE.x * HudMap.MAP_SCALE) * x, 0)
	var starty = max(round(GRID_SIZE.y * HudMap.MAP_SCALE) * y, 0)
	var endx = min(round(GRID_SIZE.x * HudMap.MAP_SCALE) * (x + 1), round(image.get_width()))
	var endy = min(round(GRID_SIZE.y * HudMap.MAP_SCALE) * (y + 1), round(image.get_height()))
	return [Vector2(startx, starty), Vector2(endx, endy)]

# update discovery tile count
# Position is given in grid indexes.
func count_grid(x, y):
	var boundaries = get_grid_positions(x, y)
	var rangex = boundaries[1].x - boundaries[0].x
	var rangey = boundaries[1].y - boundaries[0].y

	# Due to choosing floor for image texture sizes (it looks prettier), comparing with grid sizes
	# can cause edges to have negative values. Don't count those.
	var area = rangex * rangey
	if (area > 0):
		# count catacombs differently for map completion
		if (get_parent().get("level") != "res://levels/common/catacombs.tscn"):
			Globals.get("levels")[Globals.get("current_level")].location.discovered_tiles += area
		else:
			Globals.set("special_tiles", Globals.get("special_tiles") + area)

# Draw discovered tile at the specified position
# Position is given in grid indexes.
func draw_grid(x, y):
	var boundaries = get_grid_positions(x, y)
	var rangex = boundaries[1].x - boundaries[0].x
	var rangey = boundaries[1].y - boundaries[0].y

	var offset = Vector2()
	if (get_parent() != null):
		offset = get_parent().get_node("area").get_polygon()[0]
	draw_rect(Rect2(boundaries[0] + offset, Vector2(rangex, rangey)), GRIDCOLOR)