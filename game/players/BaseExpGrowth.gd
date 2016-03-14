
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
	if (exp_required > 0):
		current_exp += value
		total_exp += value
		if (current_exp >= exp_required):
			current_exp = 0
			update_exp_required(level)
			return true
	return false

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