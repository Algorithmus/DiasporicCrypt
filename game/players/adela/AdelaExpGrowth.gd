
extends "res://players/BaseExpGrowth.gd"

func update_exp_required(level):
	if (level < 100):
		exp_required = pow(level, 2) * 100
	else:
		exp_required = 0

func atk_growth(level):
	return round(255 * level / 99.0 + 4200 / 99.0)

func def_growth(level):
	return round(171 * level / 99.0 + 1116/99.0)

func mag_growth(level):
	return round(357 * level / 99.0 + 1425/99.0)

func luck_growth(level):
	return round(15 * level / 99.0 + 1470/99.0)

func hp_growth(level):
	return round(0.8 * pow(level, 2) + 199.2)

func mp_growth(level):
	return round(780 * level / 99.0 + 11100/99.0)