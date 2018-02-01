
extends "res://players/magic/BaseVertical.gd"

var sprite
var animation_player
var splash
var volume

# The pattern of this attack is to start at the top of the screen
# and move downwards until hitting a solid block (eg, regular collisions, one way
# tiles, slopes, etc.)

func _ready():
	collision = get_node("collision")
	collision_blacklist = collision.get_node("Area2D")
	sprite = get_node("attack")
	splash = get_node("splash")
	splash.hide()
	animation_player = get_node("AnimationPlayer")
	sampleplayer = get_node("SamplePlayer")
	var soundid = sampleplayer.play("thunder")
	sampleplayer.set_volume_db(soundid, volume)
	direction = -1

func get_direction_check():
	return get_global_position().y + 32 * collision.get_scale().y

func fix_scale(bottom_check, bottom_y):
	sprite.set_position(Vector2(0, sprite.get_position().y - bottom_check + bottom_y))

func set_process_scale():
	collision.set_scale(Vector2(collision.get_scale().x, collision.get_scale().y + 1))
	sprite.set_position(Vector2(0, sprite.get_position().y + 32))

func step_finish_animation():
	if (animation_player.get_current_animation_position() == animation_player.get_current_animation_length()):
		remove_self()

func final_animation():
	.final_animation()
	var bottomY = sprite.get_position().y + 32
	var sparks = get_node("sparks")
	splash.set_scale(Vector2(splash.get_scale().x, get_scale().x / 3.0))
	splash.set_position(Vector2(0, bottomY - splash.get_texture().get_height() * splash.get_scale().y/2))
	sparks.set_scale(Vector2(sparks.get_scale().x, get_scale().x))
	sparks.set_position(Vector2(0, bottomY - sparks.get_scale().y * 32))
	animation_player.play("finish")

func set_width(scale):
	set_scale(Vector2(scale, 1))
	volume = (scale - 1) * 5

