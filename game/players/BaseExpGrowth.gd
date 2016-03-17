
extends Node

# Exp and stats growth functions for each level

var exp_required = 0
var current_exp = 0
var total_exp = 0

func _ready():
	pass

func setup(level):
	update_exp_required(level)

func check_exp(level, value):
	var levels = 0
	if (exp_required > 0):
		total_exp += value
		current_exp += value
		while (current_exp >= exp_required && exp_required > 0):
			current_exp = current_exp - exp_required
			update_exp_required(level)
			level += 1
			levels += 1
	return levels

func update_exp_required(level):
	pass

func atk_growth(level):
	pass

func def_growth(level):
	pass

func mag_growth(level):
	pass

func luck_growth(level):
	pass

func hp_growth(level):
	pass

func mp_growth(level):
	pass