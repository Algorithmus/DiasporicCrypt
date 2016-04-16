
extends "res://scenes/npcs/BaseNPC.gd"

# Main NPC for catacomb functions

var chargeclass = preload("res://scenes/animations/magiccircle/charge.tscn")
var charge

func _ready():
	dialogues = [[-1, "Kaleva", "DIAG_KALEVA0", null, [["CHOICE_MAP", "map", null, false], ["CHOICE_SHOP", "shop", "SHOP_KALEVA"], ["CHOICE_TIP", "dialog", [[-1, "Kaleva", "DIAG_KALEVA1"]], false], ["CHOICE_NOTHING", "end"]]]]

func warp_animation():
	charge = chargeclass.instance()
	charge.set_pos(Vector2(0, 80))
	add_child(charge)
	charge.get_node("AnimationPlayer").play("charge")

func end_warp_animation():
	if (has_node("charge")):
		var charge = get_node("charge")
		remove_child(charge)
		charge.queue_free()