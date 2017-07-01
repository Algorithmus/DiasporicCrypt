extends Sprite

# Tracks map tiles player has already been in

# This information is stored in a 2D boolean array and rendered in an image texture
# Unfortunately, other algorithms that involve displaying the discovered tiles as a set of
# rectangles is NP Complete if you need there to be as few rectangles as possible and you allow
# for the possibility of holes in between the rectangles, so we put pixels in an image texture
# instead.

# It's unfortunately hard to avoid O(n^2) or worse here though...

# Discoverability Tiles
# Every room has a discoverability grid that tracks where players have and haven't been.
# If the player touches a tile in the grid, the tile is marked as "discovered" and we update
# and render that tile in the map.
# For consistency, all the tiles in the grid are exactly the same size (GRID_SIZE).
# In HudMap.gd, we check the player's position against the position in the room and determine
# which tiles in the grid this correspond to. They're then marked as discovered, and if they
# weren't previously discovered, we render the new discovered tiles on the map.
# To save on performance, we only re-render the entire grid while loading the game.

const GRID_SIZE = Vector2(800 / 2, 592 / 2)
const GRIDFORMAT = Image.FORMAT_RGBA
const GRIDCOLOR = Color(79.69/255, 0, 1, 0.5)

var texture
var image
var HudMap = preload("res://gui/maps/HudMap.gd")

func _ready():
	pass

func init(pos, width, height):
	set_offset(pos)
	texture = ImageTexture.new()
	texture.create(width, height, GRIDFORMAT)
	image = Image(texture.get_width(), texture.get_height(), false, GRIDFORMAT)
	texture.set_data(image)
	set_texture(texture)

# set a specified range of tiles as discovered
# range consists of indexes in the grid
func mark_grid(indexx, indexy, grid):
	var new_tiles = false
	for i in range(indexy.x, indexy.y + 1):
		var row = grid[i]
		var row_size = row.size()
		for j in range(indexx.x, indexx.y + 1):
			var cell = row[j]
			if (!cell):
				grid[i][j] = true
				new_tiles = true
				draw_grid(j, i)
	if (new_tiles):
		texture.set_data(image)

# Render all discovered tiles at once
func render_grid(grid):
	var col_size = grid.size()
	for y in range(0, col_size):
		var row = grid[y]
		var row_size = row.size()
		for x in range(0, row_size):
			var cell = row[x]
			if (cell):
				draw_grid(x, y)
	texture.set_data(image)

# Draw discovered tile at the specified position
# Position is given in grid indexes.
func draw_grid(x, y):
	var startx = max(round(GRID_SIZE.x * HudMap.MAP_SCALE * x), 0)
	var starty = max(round(GRID_SIZE.y * HudMap.MAP_SCALE * y), 0)
	var endx = round(min(GRID_SIZE.x * HudMap.MAP_SCALE * (x + 1), image.get_width())) + 1
	var endy = round(min(GRID_SIZE.y * HudMap.MAP_SCALE * (y + 1), image.get_height())) + 1

	for i in range(starty, endy):
		for j in range(startx, endx):
			image.put_pixel(j, i, GRIDCOLOR)