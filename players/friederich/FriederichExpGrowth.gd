
extends "res://players/BaseExpGrowth.gd"

func update_exp_required(level):
	if (level < 100):
		exp_required = pow(level, 2) * 200
	else:
		exp_required = 0

func atk_growth(level):
	if (level < 30):
		return round(40*level/29.0 + 250/29.0)
	else:
		return round(pow(level, 2)/25.0 + 249/25.0)

func def_growth(level):
	return round(177 * level / 99.0 + 1308/99.0)

func mag_growth(level):
	return round(238 * level / 99.0 + 948/99.0)

func luck_growth(level):
	return round(15 * level / 99.0 + 1470/99.0)

func hp_growth(level):
	return round(0.9 * pow(level, 2) + 249.1)

func mp_growth(level):
	return round(670 * level / 99.0 + 7250 / 99.0)
