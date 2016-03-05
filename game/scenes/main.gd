
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var original_size
var pause
var select
var sequences
var root
var is_paused = false
var music

var select_f_size
var select_a_size
var fscale
var ascale
var fOffset
var aOffset

var fspriteOffset
var aspriteOffset

var friederich = preload("res://players/friederich/friederich.xml")
var adela = preload("res://players/adela/adela.xml")

func _ready():
	# Initialization here
	root = get_tree().get_root()
	original_size = root.get_rect().size
	root.connect("size_changed", self, "_on_resolution_changed")
	pause = get_node("gui/CanvasLayer/pause")
	sequences = get_node("gui/CanvasLayer/sequences")
	sequences.get_node("demonic/sprite/friederich").hide()
	sequences.get_node("demonic/sprite/adela").hide()
	sequences.get_node("demonic").hide()
	sequences.hide()
	music = get_node("music")
	pause.hide()
	get_node("gui/CanvasLayer/chain/chaintext").hide()
	get_node("gui/CanvasLayer/chain/newattack").hide()
	get_node("gui/CanvasLayer/chain").hide()
	
	for spell in get_node("gui/CanvasLayer/hud/SpellIcons").get_children():
		spell.hide()
	select = get_node("gui/CanvasLayer/select")
	var selectf = select.get_node("friederich")
	var selecta = select.get_node("adela")
	select_f_size = selectf.get_rect().size
	select_a_size = selecta.get_rect().size
	fscale = selectf.get_scale()
	ascale = selecta.get_scale()
	fOffset = Vector2(select_f_size.x/2+selectf.get_pos().x - 0.25*original_size.x, select_f_size.y+selectf.get_pos().y - original_size.y)
	aOffset = Vector2(select_a_size.x/2+selecta.get_pos().x - 0.75*original_size.x, select_a_size.y+selecta.get_pos().y - original_size.y)
	select.get_node("friederich_sprite/AnimationPlayer").play("idle")
	select.get_node("adela_sprite/AnimationPlayer").play("idle")
	fspriteOffset = Vector2(select.get_node("friederich_sprite").get_pos().x, original_size.y - select.get_node("friederich_sprite").get_pos().y)
	aspriteOffset = Vector2(original_size.x - select.get_node("adela_sprite").get_pos().x, original_size.y - select.get_node("adela_sprite").get_pos().y)
	select.show()
	is_paused = true
	get_tree().set_pause(is_paused)
	set_process_input(true)
	#enable for keyboard input
	#selectf.grab_focus()

func _on_resolution_changed():
	var new_size = root.get_rect().size
	var scaleX = new_size.x/original_size.x
	var scaleY = new_size.y/original_size.y
	pause.get_node("shield").set_scale(Vector2(scaleX, scaleY))
	var charscale = min(scaleX, scaleY)
	select.get_node("friederich").set_scale(Vector2(charscale*fscale.x, charscale*fscale.y))
	select.get_node("adela").set_scale(Vector2(charscale*ascale.x, charscale*ascale.y))
	select.get_node("friederich").set_pos(Vector2(new_size.x*0.25-select_f_size.x*charscale/2+fOffset.x*charscale, new_size.y-select_f_size.y*charscale+fOffset.y*charscale))
	select.get_node("adela").set_pos(Vector2(new_size.x*0.75-select_a_size.x*charscale/2+aOffset.x*charscale, new_size.y-select_a_size.y*charscale+aOffset.y*charscale))
	select.get_node("friederich_sprite").set_pos(Vector2(fspriteOffset.x*scaleX, new_size.y - fspriteOffset.y))
	select.get_node("adela_sprite").set_pos(Vector2(new_size.x - aspriteOffset.x*scaleX, new_size.y - aspriteOffset.y))
	
func _input(event):
	if (event.is_action("ui_pause") && event.is_pressed() && !event.is_echo() && get_node("playercontainer").has_node("player") && !get_node("playercontainer/player").get("is_transforming")):
		if (is_paused):
			pause.hide()
			is_paused = false
			music.set_volume_db(0)
		else:
			pause.show()
			pause.get_node("Label").show()
			is_paused = true
			music.set_volume_db(-20)
		get_tree().set_pause(is_paused)

func _select_friederich():
	var player = friederich.instance()
	start(player)

func _select_adela():
	var player = adela.instance()
	start(player)

func start(player):
	get_node("gui/sound").play("confirm")
	player.set_global_pos(Vector2(-80, -416))
	get_node("playercontainer").add_child(player)
	player.load_tilemap(get_node("level/sandbox"))
	select.hide()
	is_paused = false
	get_tree().set_pause(is_paused)

func sequence_finished():
	sequences.get_node("demonic").hide()
	sequences.hide()
	pause.hide()
	get_tree().set_pause(false)

func _select_hover():
	get_node("gui/sound").play("cursor")


func _friederich_hover():
	select.get_node("friederich_sprite/AnimationPlayer").play("run")
	_select_hover()


func _adela_hover():
	select.get_node("adela_sprite/AnimationPlayer").play("run")
	_select_hover()


func _friederich_exit():
	select.get_node("friederich_sprite/AnimationPlayer").play("idle")


func _adela_exit():
	select.get_node("adela_sprite/AnimationPlayer").play("idle")
