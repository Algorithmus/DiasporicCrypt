extends Node2D

# Member variables
export var motion = Vector2()
export var cycle = 1.0
var accum = 0.0
var lOffset = 0
var rOffset = 0
var previousPos_blockR = Vector2()
var previousPos_blockL = Vector2()

func _fixed_process(delta):
	previousPos_blockR = get_node("blockR").get_global_pos()
	previousPos_blockL = get_node("blockL").get_global_pos()
	accum += delta*(1.0/cycle)*PI*2.0
	accum = fmod(accum, PI*2.0)
	var d = sin(accum)
	var xfR = Matrix32()
	var xfL = Matrix32()
	xfR[2]= Vector2(motion.x*d + lOffset, motion.y*d)
	xfL[2]= Vector2(motion.x*d + rOffset, motion.y*d)
	get_node("blockR").set_transform(xfR)
	get_node("blockL").set_transform(xfL)

func _ready():
	lOffset = get_node("blockL").get_pos().x
	rOffset = get_node("blockR").get_pos().x

	set_fixed_process(true)
