
extends Node

var title
var complete = false
var tags = {"red": false, "green": false, "blue": false, "purple": false}
var type # quest, boss, bonus or colosseum
var position = Vector2() # position on the world map
var new = true
var node # level the catacombs should connect to
var teleportto # coordinates in the level the player starts in when first entering the level
var description
var mapid # map layout to use
var reward = 0
var item # goal item for quest type levels
var waves # array of enemy groups that will be fighting if it's a colosseum level
var time # time limit for bonus levels
var mincounter # minimum number of enemies required for bonus level
var location # location level takes place in
var require # levels required to be completed before this level becomes available
var character # character the level is for
var sealevel # level underwhich sunbeams have no effect
var tint # tint value to provide the entire level

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
