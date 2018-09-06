extends "res://scenes/common/damagables/skeleton/Skeleton.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	atk = 40
	ep = 4000
	gold = 100
	elemental_protection = ["fire", "thunder", "ice", "hex", "magicmine", "shield", "earth", "wind", "void"]

