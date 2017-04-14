extends Control

# Background loader for loading scenes dynamically

var loader
var wait_frames
var resource_id

signal complete
signal failed

func _ready():
	pass

func load_resource(resource):
	loader = ResourceLoader.load_interactive(resource)
	if (loader == null):
		print("error loading resource: " + resource)
		return
	resource_id = resource
	set_process(true)
	
	if (Globals.get("player") == "friederich"):
		get_node("bat").show()
		get_node("cat").hide()
	else:
		get_node("cat").show()
		get_node("bat").hide()
	get_node("AnimationPlayer").play("loading")
	
	get_tree().set_pause(true)
	
	wait_frames = 1

func _process(delta):
	if (loader == null):
		get_node("AnimationPlayer").stop()
		set_process(false)
		emit_signal("failed")
		get_tree().set_pause(false)
		return
	
	if (wait_frames > 0):
		wait_frames -= 1
		return
	
	var t = OS.get_ticks_msec()
	while (OS.get_ticks_msec() < t + 100 && loader != null):
		var err = loader.poll()
		
		if (err == ERR_FILE_EOF):
			var resource = loader.get_resource()
			loader = null
			get_tree().set_pause(false)
			emit_signal("complete", resource)
		elif (err == OK):
			update_progress()
		else:
			print("error loading resource: " + resource_id)
			loader = null
			get_tree().set_pause(false)
			emit_signal("failed")
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	get_node("text").set_text(tr("KEY_LOADING") + " " + str(int(progress * 100)) + "%")