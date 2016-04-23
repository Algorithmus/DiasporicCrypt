
extends Sprite

var night = [Color(7/255.0, 8/255.0, 17/255.0), Color(7/255.0, 34/255.0, 58/255.0)]
var sunrise = [Color(49/255.0, 69/255.0, 116/255.0), Color(1, 160/255.0, 69/255.0)]
var color
var timer
var limit

func _ready():
	Globals.set("blood_count", 0)
	Globals.set("show_blood_counter", true)
	color = get_material()
	color.set_shader_param("start", night[0])
	color.set_shader_param("stop", night[1])
	var level = Globals.get("levels")[Globals.get("current_level")]
	timer = level.time
	limit = timer * 1.0
	set_fixed_process(true)

func _fixed_process(delta):
	timer -= 1
	var start = sunrise[0].linear_interpolate(night[0], timer/limit)
	var stop = sunrise[1].linear_interpolate(night[1], timer/limit)
	color.set_shader_param("start", start)
	color.set_shader_param("stop", stop)
	if (timer <= 0):
		Globals.set("sun", true)
		set_fixed_process(false)