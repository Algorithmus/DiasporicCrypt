
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var taken = false
var sound

func _fixed_process(delta):
	if (!taken):
		var collisions = get_node("potion").get_overlapping_bodies()
		for i in collisions:
			if (i.get_name() == "player"):
				sound.play("potion")
				taken = true
				remove_child(get_node("Sprite"))
	elif (!sound.is_active()):
		queue_free()

func _ready():
	# Initialization here
	sound = get_node("sound")
	
	set_fixed_process(true)


