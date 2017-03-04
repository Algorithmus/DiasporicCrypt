extends Node2D

# Member variables
export var motion = Vector2()
export var cycle = 1.0
export var offset = 0.0
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
	# circular motion
	var d = sin(accum)
	# uncomment for linear motion
	#var d = fposmod(accum * sign(cos(accum)*sin(accum)), PI / 2.0) / (PI / 2.0)
	#if (cos(accum) == 0):
	#	d = 1
	#d = sign(sin(accum)) * d
	
	get_node("blockR").set_pos(Vector2(motion.x*d + rOffset, motion.y*d))
	get_node("blockL").set_pos(Vector2(motion.x*d + lOffset, motion.y*d))

func _ready():
	lOffset = get_node("blockL").get_pos().x
	rOffset = get_node("blockR").get_pos().x
	var scalex = motion.x / 32.0
	var scaley = motion.y / 32.0
	accum = offset * PI / 180
	set_fixed_process(true)

