
extends Node

var teleportto # coordinates in the level the player starts in when first entering the level
var id
var node # level the catacombs should connect to
var bgm
var discovered_tiles = 0 # tiles already discovered
var tiles # total number of discovery tiles (in pixels)
# We could calculate the total number of discovery tiles dynamically instead of
# using a hardcoded value (and this requires loading every single room at runtime at the beginning, 
# which we should avoid for performance reasons anyways), but we also want to leave the possibility
# of "blacklisting" some tiles because they might not be reachable by the player
# Since it doesn't really matter exactly which tiles are blacklisted for
# total count, the total count for "accepted" tiles is sufficient here.
# We leave the heavylifting for finding out how many tiles are in an entire level up to the map tool.
# See map tool in res://tools/map folder for more details on how these numbers might be obtained

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func tile_percent():
	if (tiles != null && tiles > 0):
		return float(round((float(discovered_tiles) / tiles) * 10000) / 100)
	return 0
