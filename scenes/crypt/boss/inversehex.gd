
extends "res://players/magic/BaseVertical.gd"

var is_release = false
var beam
var swirl
var finish_counter = 0
const finish_delay = 60
var soundid
var length

func _ready():
	collision = get_node("beam")
	collision_blacklist = collision.get_node("collision")
	collision_blacklist.set_name("damagable")
	remove_child(collision)
	beam = get_node("light")
	beam.hide()
	swirl = get_node("swirl")
	sampleplayer = get_node("SamplePlayer")
	soundid = sampleplayer.play("charge")
	direction = -1

func step_spell():
	if (is_release):
		if (!is_finish):
			# detect platforms above current position
			# tiles directly on the same position don't count
			# also check special tiles
			print("beam")
			print(beam.get_scale().y)
			print(collision.get_scale().y)
			print(beam.get_scale().y * 32)
			if (beam.get_scale().y * get_scale().y >= length):
				fix_scale(beam.get_scale().y, length)
				final_animation()
			if (!is_finish):
				set_process_scale()
		else:
			step_finish_animation()
	elif (!sampleplayer.is_active()):
		soundid = sampleplayer.play("charge")
		
func fix_scale(top_check, top_y):
	beam.set_scale(Vector2(beam.get_scale().x, length / get_scale().y))

func get_direction_check():
	return get_global_position().y + 32 * collision.get_scale().y * get_scale().y

func set_process_scale():
	var scale = collision.get_scale().y + 1.0/get_scale().y
	collision.set_scale(Vector2(collision.get_scale().x, scale))
	beam.set_scale(Vector2(beam.get_scale().x, scale))
	swirl.set_param(Particles2D.PARAM_GRAVITY_STRENGTH, swirl.get_param(Particles2D.PARAM_GRAVITY_STRENGTH) + 16)

func step_finish_animation():
	finish_counter += 1
	if (finish_counter >= finish_delay):
		remove_self()

func change_scale(scale):
	set_scale(Vector2(scale, scale))
	collision.set_scale(Vector2(1, 1/scale))
	sampleplayer.set_volume_db(soundid, (scale - 1) * 10)

func release():
	is_release = true
	beam.show()
	add_child(collision)
	var volume = sampleplayer.get_volume_db(soundid)
	soundid = sampleplayer.play("hex")
	sampleplayer.set_volume_db(soundid, volume)
