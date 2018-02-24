extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

static func scale_to_db(value):
	return 10 * log(value) / log(10)