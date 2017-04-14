extends Node

var time_start = 0
var time_now = 0
var elapsed = 0
var elapsed_offset = 0
var str_elapsed = "00:00:00"
var idle_timer = Timer.new()
const IDLETIMEOUT = 120
var shield
var gui
var music
var animation
var previously_paused = false

func _ready():
	gui = get_tree().get_root().get_node("world/gui")
	music = get_tree().get_root().get_node("world/music")
	animation = get_tree().get_root().get_node("world/AnimationPlayer")
	shield = gui.get_node("CanvasLayer/nofocus")
	shield.hide()
	time_start =OS.get_unix_time()
	idle_timer.set_wait_time(IDLETIMEOUT)
	idle_timer.connect("timeout", self, "idle")
	add_child(idle_timer)
	idle_timer.start()
	set_process(true)
	set_process_input(true)

func idle():
	idle_timer.stop()
	elapsed_offset = elapsed
	set_process(false)

func _input(event):
	if (event.is_pressed()):
		resume()

func resume():
	idle_timer.stop()
	idle_timer.start()
	elapsed_offset = elapsed
	time_start = OS.get_unix_time()
	set_process(true)

func _process(delta):
	time_now = OS.get_unix_time()
	elapsed = time_now - time_start + elapsed_offset
	str_elapsed = display_time(elapsed)

static func display_time(time):
	var hours = time / 3600
	var minutes = time % 3600 / 60
	var seconds = time % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_FOCUS_IN):
		gui.set_pause_mode(Node.PAUSE_MODE_PROCESS)
		animation.set_pause_mode(Node.PAUSE_MODE_INHERIT)
		music.set_paused(false)
		shield.hide()
		get_tree().set_pause(previously_paused)
		resume()
	elif (what == MainLoop.NOTIFICATION_WM_FOCUS_OUT):
		shield.show()
		gui.set_pause_mode(Node.PAUSE_MODE_STOP)
		animation.set_pause_mode(Node.PAUSE_MODE_STOP)
		music.set_paused(true)
		previously_paused = get_tree().is_paused()
		get_tree().set_pause(true)
		idle()