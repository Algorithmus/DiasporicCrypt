
extends Control

# manage user interface for map screen

var pincontainer
var title
var filters
var currentlevel
var list
var listcontainer
var pinclass = preload("res://gui/worldmap/pin.scn")
var listitemclass = preload("res://gui/worldmap/listitem.scn")
var levelfactory = preload("res://levels/LevelFactory.gd").new()
var keyboardmap = preload("res://gui/KeyboardCharacters.gd").new()
const RED = Color(146/255.0, 0, 0)
var filteractive = false
var leveldisplay = false
var islist = false
var selectedlevel
var tagsdisabled = true
var content
var animation
var echo = false
var tagfilters = {"red": false, "green": false, "blue": false, "purple": false}
var typefilters = {"quest": true, "boss": true, "bonus": true, "colosseum": true}
var typeicons = {"quest": preload("res://gui/worldmap/icons/quest.png"), 
				"boss": preload("res://gui/worldmap/icons/boss.png"), 
				"bonus": preload("res://gui/worldmap/icons/bonus.png"),
				"colosseum": preload("res://gui/worldmap/icons/colosseum.png")}
var sfxclass = preload("res://gui/menu/sfx.scn")
var sfx

func _ready():
	set_process_input(true)
	sfx = sfxclass.instance()
	add_child(sfx)
	var filterkey = "ui_select"
	var listkey = "ui_pause"
	var filterkeystring = "[center]Filter:  [code]" + keyboardmap.map_action(filterkey) + "[/code][/center]"
	get_node("filters/key").set_bbcode(filterkeystring)
	get_node("list/filters/key").set_bbcode(filterkeystring)
	get_node("listinfo").set_bbcode("[right]List:  [code]" + keyboardmap.map_action(listkey) + "[/code][/right]")
	pincontainer = get_node("pins")
	list = get_node("list")
	listcontainer = list.get_node("listcontainer/VBoxContainer")
	toggle_list(true)
	title = get_node("title")
	content = title.get_node("content")
	filters = get_node("filters")
	filters.get_node("tagcontainer").set_opacity(0.5)
	list.get_node("filters/tags").set_opacity(0.5)
	animation = get_node("AnimationPlayer")
	animation.play("hidden")
	var levels = Globals.get("available_levels")
	currentlevel = Globals.get("current_level")
	var groups = {}
	var groupindex
	# add pins to map and list
	for i in range(0, levels.size()):
		var level = levelfactory.levels[levels[i]]
		var pin = pinclass.instance()
		var listitem = listitemclass.instance()
		pin.set_name(level.title)
		listitem.set_name(level.title)
		pin.set_pos(level.position)
		pin.get_node("icon").set_texture(typeicons[level.type])
		listitem.get_node("type").set_texture(typeicons[level.type])
		listitem.get_node("title").set_text(level.title)
		if (level.complete):
			listitem.get_node("complete").show()
		else:
			listitem.get_node("complete").hide()
		if (level.new):
			listitem.get_node("new").show()
		else:
			listitem.get_node("new").hide()
		listitem.get_node("map").set_text(str(level.map * 100) + "%")
		pin.connect("focus_enter", self, "focus_pin")
		listitem.connect("focus_enter", self, "focus_list")
		for tag in level.tags:
			var tagitem = listitem.get_node("tags/" + tag)
			if (level.tags[tag]):
				tagitem.show()
			else:
				tagitem.hide()
		if (!groups.has(level.position)):
			groups[level.position] = [level.title]
		else:
			groups[level.position].append(level.title)
		if (level.title == currentlevel):
			pin.get_node("icon").set_modulate(RED)
			listitem.get_node("type").set_modulate(RED)
			pin.get_node("overlap").set_modulate(RED)
			groupindex = groups[level.position].size()-1
		pincontainer.add_child(pin)
		listcontainer.add_child(listitem)
	var currentpin = pincontainer.get_node(currentlevel)
	# overlapping levels of the same type should be marked
	for group in groups:
		if (groups[group].size() > 1):
			var index = 0
			if (group == levelfactory.levels[currentlevel].position):
				index = groupindex
			var level = groups[group][index]
			pincontainer.get_node(level + "/overlap").show()
	get_node("current").set_text(currentlevel)
	get_node("current/icon").set_texture(typeicons[levelfactory.levels[currentlevel].type])
	for type in filters.get_node("typecontainer").get_children():
		type.select(true)
	update_filters()
	selectedlevel = null
	currentpin.raise()
	currentpin.grab_focus()

func focus_list():
	var item = get_focus_owner()
	set_content(item.get_name())
	var scrollcontainer = list.get_node("listcontainer")
	if (scrollcontainer.get_v_scroll() + scrollcontainer.get_size().y < item.get_pos().y + item.get_size().y || scrollcontainer.get_v_scroll() > item.get_pos().y):
		scrollcontainer.set_v_scroll(item.get_pos().y)
	unfocus_pins()
	pincontainer.get_node(item.get_name() + "/AnimationPlayer").play("active")

func select_list():
	selectedlevel = pincontainer.get_node(get_focus_owner().get_name())
	toggle_list(true)
	do_select()

func unfocus_pins():
	for pin in pincontainer.get_children():
		pin.get_node("AnimationPlayer").play("inactive")

func focus_pin():
	var pin = get_focus_owner()
	set_content(pin.get_name())
	sfx.play("cursor")

func select_pin():
	selectedlevel = get_focus_owner()
	toggle_pins(true)
	do_select()

func do_select():
	animation.play("show")
	leveldisplay = true
	sfx.play("confirm")

func focus_warp():
	content.get_node("warp").grab_focus()

func toggle_pins(state):
	for pin in pincontainer.get_children():
		pin.set_disabled(state)

func toggle_list(state):
	for item in listcontainer.get_children():
		item.set_disabled(state)

# update and display selected level information
func set_content(id):
	var level = Globals.get("levels")[id]
	title.get_node("level").set_text(level.title)
	title.get_node("percent").set_text(str(level.map * 100) + "%")
	title.get_node("icon").set_texture(typeicons[level.type])
	if (level.complete):
		title.get_node("complete").show()
	else:
		title.get_node("complete").hide()
	if (level.new):
		title.get_node("new").show()
	else:
		title.get_node("new").hide()
	content.get_node("description").set_bbcode(tr(level.description))
	content.get_node("reward").set_text(tr("MAP_REWARD") + ": " + str(level.reward) + "G")
	for tag in level.tags:
		var flag = title.get_node("tags/" + tag)
		var filter = content.get_node("tags/" + tag)
		if (level.tags[tag]):
			flag.show()
			filter.get_node("tag").set_invert(false)
		else:
			flag.hide()
			filter.get_node("tag").set_invert(true)

func toggle_filters(state):
	if (islist):
		list.get_node("filters/tagtitle").set_disabled(state)
		for tag in list.get_node("filters/tags").get_children():
			tag.set_disabled(state || tagsdisabled)
		for type in list.get_node("filters/type").get_children():
			type.set_disabled(state)
	else:
		filters.get_node("tags").set_disabled(state)
		for tag in filters.get_node("tagcontainer").get_children():
			tag.set_disabled(state || tagsdisabled)
		for type in filters.get_node("typecontainer").get_children():
			type.set_disabled(state)

func _input(event):
	if (event.is_pressed() && !event.is_echo() && !animation.is_playing()):
		if (event.is_action_pressed("ui_select") && !leveldisplay):
			if (!filteractive || (filteractive && selectedlevel != null)):
				toggle_filters(filteractive)
				if (filteractive):
					if (islist):
						toggle_list(false)
						listcontainer.get_node(selectedlevel.get_name()).grab_focus()
					else:
						toggle_pins(false)
						filters.get_node("bg").hide()
						selectedlevel.grab_focus()
				else:
					if (islist):
						if (get_focus_owner() != null):
							selectedlevel = pincontainer.get_node(get_focus_owner().get_name())
						else:
							selectedlevel = null
						toggle_list(true)
						list.get_node("filters/tagtitle").grab_focus()
					else:
						filters.get_node("bg").show()
						selectedlevel = get_focus_owner()
						filters.get_node("tags").grab_focus()
				filteractive = !filteractive
		if (event.is_action_pressed("ui_pause") && !leveldisplay):
			if (islist):
				animation.get_animation("show").track_set_key_value(0, 0, Vector2(0, 520))
				animation.get_animation("hide").track_set_key_value(0, 1, Vector2(0, 520))
				if (!filteractive):
					selectedlevel = pincontainer.get_node(get_focus_owner().get_name())
				toggle_list(true)
				toggle_filters(true)
				islist = false
				animation.play("hidelist")
			else:
				animation.get_animation("show").track_set_key_value(0, 0, Vector2(0, 592))
				animation.get_animation("hide").track_set_key_value(0, 1, Vector2(0, 592))
				if (!filteractive):
					selectedlevel = get_focus_owner()
				toggle_pins(true)
				toggle_filters(true)
				islist = true
				animation.play("showlist")
		if (event.is_action_pressed("ui_accept") && !leveldisplay && !filteractive):
			if (islist):
				select_list()
			else:
				select_pin()
		if (event.is_action_pressed("ui_cancel") && leveldisplay):
			leveldisplay = false
			animation.play("hide")
			if (islist):
				toggle_list(false)
			else:
				toggle_pins(false)
			update_filters()
			# if tagging causes the level to disappear from the map, 
			# and there's nothing else to select, select the filters instead
			if (selectedlevel == null):
				filteractive = true
				toggle_filters(false)
				if (islist):
					list.get_node("filters/tagtitle").grab_focus()
				else:
					filters.get_node("bg").show()
					filters.get_node("tags").grab_focus()
			else:
				if (islist):
					listcontainer.get_node(selectedlevel.get_name()).grab_focus()
				else:
					selectedlevel.grab_focus()
				selectedlevel = null
			echo = true

func end_list_animation():
	if (islist):
		toggle_list(false)
		if (!filteractive):
			if (selectedlevel == null):
				listcontainer.get_child(0).grab_focus()
			else:
				listcontainer.get_node(selectedlevel.get_name()).grab_focus()
			selectedlevel = null
		else:
			toggle_filters(false)
			filteractive = true
			list.get_node("filters/tagtitle").grab_focus()
		get_node("listinfo").set_bbcode("[right]" + tr("MAP_MAP") + ":  [code]" + keyboardmap.map_action("ui_pause") + "[/code][/right]")
	else:
		if (filteractive):
			toggle_filters(false)
			filters.get_node("tags").grab_focus()
			filters.get_node("bg").show()
		else:
			toggle_pins(false)
			selectedlevel.grab_focus()
			selectedlevel = null
		get_node("listinfo").set_bbcode("[right]List:  [code]" + keyboardmap.map_action("ui_pause") + "[/code][/right]")

func block_cancel():
	# info panel is already unfocused, so check echo flag instead
	var result = leveldisplay || echo
	echo = false
	return result

func set_typefilter():
	var focus = get_focus_owner()
	var filter = focus.get_name()
	typefilters[filter] = !typefilters[filter]
	if (islist):
		filters.get_node("typecontainer/" + filter).select(typefilters[filter])
	else:
		list.get_node("filters/type/" + filter).select(typefilters[filter])
	update_filters()
	sfx.play("confirm")

func update_filters():
	var filteredlevels = {}
	var levels = Globals.get("levels")
	for pin in pincontainer.get_children():
		pin.hide()
		pin.set_disabled(true)
	for listitem in listcontainer.get_children():
		listitem.hide()
		listitem.set_disabled(true)
	# filter by type
	for type in typefilters:
		if (typefilters[type]):
			for pin in pincontainer.get_children():
				var level = levels[pin.get_name()]
				if (level.type == type):
					filteredlevels[level.title] = pin
	# filter by tags if enabled
	var taggedlevels = {}
	if (!tagsdisabled):
		var untaggedlevels = {}
		var untaggedcounter = {}
		var tagselected = false
		for tag in tagfilters:
			for filteredlevel in filteredlevels:
				var level = levels[filteredlevels[filteredlevel].get_name()]
				if (level.tags[tag] == tagfilters[tag]):
					if (tagfilters[tag]):
						tagselected = true
						taggedlevels[level.title] = filteredlevels[filteredlevel]
					else:
						# keep track of untagged levels in case no tags are selected
						if (!untaggedcounter.has(level.title)):
							untaggedcounter[level.title] = 0
						untaggedcounter[level.title] += 1
						if (untaggedcounter[level.title] == tagfilters.size()):
							untaggedlevels[level.title] = filteredlevels[filteredlevel]
		if (!tagselected):
			taggedlevels = untaggedlevels
	else:
		taggedlevels = filteredlevels
	var old_selectedlevel = selectedlevel
	selectedlevel = null
	var backup_pin = null
	# try to select previously selected level if at all possible
	# fall back to selecting another pin
	for pin in taggedlevels:
		backup_pin = taggedlevels[pin]
		backup_pin.show()
		backup_pin.set_disabled(islist)
		var list = listcontainer.get_node(pin)
		list.show()
		list.set_disabled(!islist)
		if (backup_pin == old_selectedlevel):
			selectedlevel = backup_pin
	if (selectedlevel == null):
		selectedlevel = backup_pin
	if (selectedlevel != null):
		set_content(selectedlevel.get_name())
		title.show()
	else:
		title.hide()

# toggle tag for a level
func set_tag():
	var tag = get_focus_owner().get_name()
	var level = Globals.get("levels")[selectedlevel.get_name()]
	level.tags[tag] = !level.tags[tag]
	Globals.get("levels")[selectedlevel.get_name()] = level
	var flag = title.get_node("tags/" + tag)
	var listflag = listcontainer.get_node(selectedlevel.get_name() + "/tags/" + tag)
	if (level.tags[tag]):
		flag.show()
		listflag.show()
	else:
		flag.hide()
		listflag.hide()

func _on_tags_focus_enter():
	var focus = filters.get_node("tags")
	if (islist):
		focus = list.get_node("filters/tagtitle")
	focus.set("custom_colors/font_color", Color(1, 215/255.0, 0))
	sfx.play("cursor")

func _on_tags_focus_exit():
	var focus = filters.get_node("tags")
	if (islist):
		focus = list.get_node("filters/tagtitle")
	focus.set("custom_colors/font_color", null)

# change tag filter
func set_tagfilter():
	var tag = get_focus_owner().get_name()
	tagfilters[tag] = !tagfilters[tag]
	if (islist):
		filters.get_node("tagcontainer/" + tag + "/tag").set_invert(!tagfilters[tag])
	else:
		list.get_node("filters/tags/" + tag + "/tag").set_invert(!tagfilters[tag])
	update_filters()
	sfx.play("confirm")

# enable or disable tag filter
func toggle_tags():
	tagsdisabled = !tagsdisabled
	if (tagsdisabled):
		filters.get_node("tagcontainer").set_opacity(0.5)
		list.get_node("filters/tags").set_opacity(0.5)
		list.get_node("filters/type/quest").set_focus_neighbour(MARGIN_LEFT, list.get_node("filters/tagtitle").get_path())
	else:
		filters.get_node("tagcontainer").set_opacity(1)
		list.get_node("filters/tags").set_opacity(1)
		list.get_node("filters/type/quest").set_focus_neighbour(MARGIN_LEFT, list.get_node("filters/tags/purple").get_path())
	toggle_filters(false)
	update_filters()
	sfx.play("confirm")
