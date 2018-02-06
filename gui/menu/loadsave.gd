
extends Control

# Displays user interface for shopping

var itemclass = preload("res://gui/menu/gamesave.tscn")
var itemfactory

var selecteditem
var echo = false
var optionsvisible = false

var itemcontainer
var scrollrange

var savepos
var savelocation

var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

var loadonly = false

signal empty
signal loadgame

func _ready():
	sfx = sfxclass.instance()
	add_child(sfx)
	scrollrange = get_node("saves").get_size()
	itemcontainer = get_node("saves/container")
	set_process_input(true)
	var back = get_node("back")
	back.get_node("input").set_text(tr("MAP_BACK"))
	back.set_key("ui_cancel")
	if (loadonly):
		get_node("title").set_text(tr("KEY_LOADGAME"))
	load_menu()

func load_menu():
	var dir = Directory.new()
	var file = File.new()
	var savedir = ProjectSettings.get("savedir")
	var regex = RegEx.new()
	regex.compile("^save\\d+.save$")
	if (dir.dir_exists(savedir)):
		if(dir.open(savedir) == 0):
			dir.list_dir_begin()
			var filename = dir.get_next()
			while (filename != ""):
				if (!dir.current_is_dir() && regex.search(filename).strings.size() > 0):
					var game = {}
					file.open(savedir + "/" + filename, File.READ)
					while (!file.eof_reached()):
						# unfortunately, it's not safe to assume Directory returns back the
						# list of filenames in alphabetical order (eg, 10 can show up before 2 just because of the 1)
						# so we rely on the save number for its id and position in the list
						var index = filename.get_basename().split("save")[1]
						var string = file.get_line()
						game = parse_json(string)
						var save = itemclass.instance()
						save.set("loadonly", loadonly)
						itemcontainer.add_child(save)
						save.setState(save.SAVE)
						save.hideSavedRecently()
						save.set("savepos", savepos)
						save.set("savelocation", savelocation)
						save.set_id(str(index))
						save.connect("focus_enter", self, "check_scroll")
						save.connect("options_visible", self, "set_optionsvisible")
						save.connect("delete", self, "shift_files")
						save.connect("clone", self, "clone")
						save.connect("echo", self, "set_echo")
						if (loadonly):
							save.connect("loadgame", self, "load_game")
						save.displayGameData(game)
						save.set("filename", filename)
					file.close()
				filename = dir.get_next()
			dir.list_dir_end()
	sort_list()
	if (!loadonly):
		create_newsave()
	itemcontainer.get_child(0).grab_focus()

# sort list of game saves by id number
func sort_list():
	for item in itemcontainer.get_children():
		itemcontainer.move_child(item, item.get("idnr") - 1)

func set_optionsvisible(value):
	optionsvisible = value

func create_newsave():
	var newsave = itemclass.instance()
	newsave.set("loadonly", loadonly)
	itemcontainer.add_child(newsave)
	newsave.setState(newsave.NEW)
	newsave.set("savepos", savepos)
	newsave.set("savelocation", savelocation)
	newsave.set_id(str(itemcontainer.get_child_count()))
	newsave.set("filename", "save" + str(itemcontainer.get_child_count()) + ".save")
	if (!loadonly):
		newsave.connect("newsave", self, "check_newsave")
	newsave.connect("focus_enter", self, "check_scroll")
	newsave.connect("delete", self, "shift_files")
	newsave.connect("clone", self, "clone")
	if (loadonly):
		newsave.connect("loadgame", self, "load_game")
	newsave.connect("options_visible", self, "set_optionsvisible")
	newsave.connect("echo", self, "set_echo")

func load_game():
	emit_signal("loadgame")

func check_newsave():
	var save = itemcontainer.get_child(itemcontainer.get_child_count() - 1)
	if (save.get("state") != save.NEW):
		create_newsave()

func clone(data):
	if (loadonly):
		create_newsave()
		# Unfortunately, the scroll position isn't correct even though the element position is.
		# In the regular mode, this doesn't happen because the new empty save is already there, and we just save the
		# clone in that slot and create a new one (which doesn't need to be targeted anyways and ensures there's more than
		# enough space to scroll there).
		# Hopefully, this might be fixed in later versions of GodotEngine since there is a bug report about it anyways,
		# and check_scroll() is maybe just a hack.
		# See https://github.com/godotengine/godot/issues/5637
		call_deferred("check_scroll")
	var save = itemcontainer.get_child(itemcontainer.get_child_count() - 1)
	save.save_from_data(data)
	if (!loadonly):
		create_newsave()
	optionsvisible = false
	save.grab_focus()

func shift_files(index, filename):
	itemcontainer.remove_child(itemcontainer.get_child(index))
	var savedir = ProjectSettings.get("savedir")
	var dir = Directory.new()
	for i in range(index, itemcontainer.get_child_count()):
		var item = itemcontainer.get_child(i)
		item.set_id(str(i+1))
		var old_filename = item.get("filename")
		item.set("filename", filename)
		if (item.get("state") == item.SAVE):
			dir.rename(savedir + "/" + old_filename, savedir + "/" + filename)
		elif (item.get("state") == item.NEW):
			dir.remove(savedir + "/" + filename)
		filename = old_filename
	optionsvisible = false
	if (loadonly):
		dir.remove(savedir + "/" + filename)
	var size = itemcontainer.get_child_count()
	if (size > 0):
		var item = itemcontainer.get_child(min(index, size - 1))
		item.set("echo", true)
		item.grab_focus()
	elif (loadonly):
		emit_signal("empty")

func check_scroll():
	var item = get_focus_owner()
	var vscroll = get_node("saves").get_v_scroll()
	var itempos = item.get_position().y
	var itemsize = item.get_size().y
	if (vscroll > itempos || vscroll + scrollrange.y < itempos + itemsize):
		get_node("saves").set_v_scroll(itempos)

func clear_items():
	for i in itemcontainer.get_children():
		itemcontainer.remove_child(i)
		i.queue_free()

func focus_item_enter():
	# do stuff when a save game is selected
	pass

func focus_item_exit():
	# do stuff when a save game is deselected
	pass

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		var focus = get_focus_owner()

func set_echo():
	echo = true

func block_cancel():
	var result = optionsvisible || echo
	echo = false
	return result
