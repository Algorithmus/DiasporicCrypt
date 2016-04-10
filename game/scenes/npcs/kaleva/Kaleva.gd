
extends "res://scenes/npcs/BaseNPC.gd"

# Main NPC for catacomb functions

func _ready():
	dialogues = [[-1, "Kaleva", "DIAG_KALEVA0", null, [["CHOICE_MAP", "map", null, false], ["CHOICE_SHOP", "shop", "SHOP_KALEVA"], ["CHOICE_TIP", "dialog", [[-1, "Kaleva", "DIAG_KALEVA1"]], false], ["CHOICE_NOTHING", "end"]]]]
