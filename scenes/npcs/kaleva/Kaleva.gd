
extends "res://scenes/npcs/BaseNPC.gd"

# Main NPC for catacomb functions

var chargeclass = preload("res://scenes/animations/magiccircle/charge.tscn")
var charge

func _ready():
	dialogues = [[-1, "Kaleva", "DIAG_KALEVA0", null, [["CHOICE_MAP", "map", null, false], ["CHOICE_SHOP", "shop", "SHOP_KALEVA"], ["CHOICE_TIP", "random", [[[-1, "Kaleva", "DIAG_KALEVA_TIP1"]], [[-1, "Kaleva", "DIAG_KALEVA_TIP2"]], [[-1, "Kaleva", "DIAG_KALEVA_TIP3"]], [[-1, "Kaleva", "DIAG_KALEVA_TIP4"]], [[-1, "Kaleva", "DIAG_KALEVA_TIP5"]]], false], ["CHOICE_NOTHING", "end"]]]]

func warp_animation():
	charge = chargeclass.instance()
	charge.set_position(Vector2(0, 80))
	add_child(charge)
	charge.get_node("AnimationPlayer").play("charge")

func end_warp_animation():
	if (has_node("charge")):
		var charge = get_node("charge")
		remove_child(charge)
		charge.queue_free()
