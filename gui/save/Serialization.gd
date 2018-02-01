extends Node

# Helper class that does all the heavy lifting required to convert
# data for saving and loading games

func _ready():
	pass

func serialize_stats(player):
	var exp_obj = player.get("exp_growth_obj")
	var ep = exp_obj.get("total_exp")
	var required_exp = exp_obj.get("exp_required")
	var current_exp = exp_obj.get("current_exp")
	var stats = {}
	stats.ep = ep
	stats.requiredEp = required_exp
	stats.currentEp = current_exp
	stats.level = player.get("level")
	stats.hp = player.get("base_hp")
	stats.currentHp = min(player.get("current_hp"), player.get("base_hp"))
	stats.mp = player.get("base_mp")
	stats.currentMp = min(player.get("current_mp"), player.get("base_mp"))
	stats.atk = player.get("base_atk")
	stats.def = player.get("base_def")
	stats.mag = player.get("base_mag")
	stats.luck = player.get("base_luck")
	return stats

func unserialize_stats(player, data):
	var exp_obj = player.get("exp_growth_obj")
	exp_obj.set("total_exp", data.ep)
	exp_obj.set("exp_required", data.requiredEp)
	exp_obj.set("current_exp", data.currentEp)
	player.set("level", data.level)
	player.set("base_hp", data.hp)
	player.set("hp", data.hp)
	player.set("current_hp", data.currentHp)
	player.set("base_mp", data.mp)
	player.set("mp", data.mp)
	player.set("current_mp", data.currentMp)
	player.set("base_atk", data.atk)
	player.set("base_def", data.def)
	player.set("base_mag", data.mag)
	player.set("base_luck", data.luck)

func serialize_scrolls(data):
	var scrolls = {}
	for scroll in data:
		scrolls[scroll] = data[scroll].new
	return scrolls

func unserialize_scrolls(data):
	var scrolls = {}
	for scroll in data:
		var newscroll = Globals.get("itemfactory").items[scroll]
		newscroll.new = data[scroll]
		scrolls[scroll] = newscroll
	return scrolls

func serialize_items(data):
	var inventory = {}
	for id in data:
		var newitem = {}
		var item = data[id]
		newitem.id = id
		newitem.quantity = item.quantity
		newitem.new = item.item.new
		inventory[id] = newitem
	return inventory

func unserialize_items(data):
	var inventory = {}
	for id in data:
		var item = data[id]
		var newitem = {}
		newitem.item = Globals.get("itemfactory").items[id]
		newitem.item.new = item.new
		newitem.quantity = item.quantity
		inventory[id] = newitem
	return inventory

func serialize_spells(data):
	var spells = []
	for i in range(0, data.size()):
		var spell = data[i]
		spells.push_back(spell.id)
	return spells

func unserialize_spells(data):
	var spells = []
	var magic_spells = Globals.get("magic_spells")
	for i in range(0, data.size()):
		var id = data[i]
		for j in range(0, magic_spells.size()):
			if (id == magic_spells[j].id):
				spells.push_back(magic_spells[j])
	return spells

func serialize_levels(data):
	var leveldata = {}
	for id in data:
		var level = data[id]
		var newlevel = {}
		newlevel.new = level.get("new")
		newlevel.tags = level.get("tags")
		newlevel.complete = level.get("complete")
		newlevel.tiles = level.get("location").discovered_tiles
		leveldata[id] = newlevel
	return leveldata

func unserialize_levels(data, levels):
	for id in data:
		var level = data[id]
		var newlevel = levels[id]
		newlevel.new = level.new
		newlevel.tags = level.tags
		newlevel.complete = level.complete
		newlevel.location.discovered_tiles = level.tiles
	return levels

func serialize_mapindex(hudmap, data):
	var mapindex = {}
	for mapid in data:
		var map = hudmap.serialize_room(data[mapid])
		map.grid = Globals.get("grids")[mapid]
		mapindex[mapid] = map
	return mapindex

func serialize_mapobjects(hudmap, data):
	var mapobjects = {}
	for mapid in data:
		var map = data[mapid]
		var newmap = []
		for room in map.get_children():
			var newroom = hudmap.serialize_room(room)
			newroom.id = room.level
			newmap.push_back(newroom)
		mapobjects[mapid] = newmap
	return mapobjects

func unserialize_mapindex(hudmap, data):
	var mapindex = {}
	for mapid in data:
		var map = data[mapid]
		var newmap = []
		for room in map.get_children():
			# The map index and objects must be the same or else the correct discovery grid will not be displayed
			# This unfortunately breaks older saves.
			room.get_node("grid").render_grid(Globals.get("grids")[room.level])
			mapindex[room.level] = room
	return mapindex

func unserialize_grids(data):
	var grids = {}
	for roomid in data:
		var map = data[roomid]
		if (map.has("grid") && map.grid != null && map.grid.size() > 0):
			grids[roomid] = data[roomid].grid
	return grids

func unserialize_mapobjects(hudmap, data):
	var mapobjects = {}
	for obj in hudmap.get_node("objects").get_children():
		hudmap.get_node("objects").remove_child(obj)
	for mapid in data:
		var objectsnode = hudmap.get_node("objects").duplicate()
		var mapobj = data[mapid]
		for i in range(0, mapobj.size()):
			var room = mapobj[i]
			var newroom = hudmap.unserialize_room(room)
			newroom.level = room.id
			objectsnode.add_child(newroom)
		mapobjects[mapid] = objectsnode
	return mapobjects

func clearInputs(actionid, is_keyboard):
	var mappedlist = InputMap.get_action_list(actionid)
	for e in mappedlist:
		if ((e is InputEventKey && is_keyboard) || (e is InputEventJoypadButton && !is_keyboard)):
			InputMap.action_erase_event(actionid, e)

func unserialize_controls(data, is_keyboard):
	var shared_actions = []
	var jumpevent
	for actionid in data:
		var list = InputMap.get_action_list(actionid)
		for e in list:
			var inputvalue = ""
			if (e is InputEventKey && is_keyboard):
				inputvalue = "scancode"
			elif (e is InputEventJoypadButton && !is_keyboard):
				inputvalue = "button_index"
			else:
				break
			InputMap.action_erase_event(actionid, e)
			var event = InputEvent()
			event.type = e.type
			event[inputvalue] = data[actionid]
			InputMap.action_add_event(actionid, event)
			if (actionid == "ui_blood" || actionid == "ui_attack" || actionid == "ui_magic"):
				shared_actions.push_back(event)
			elif (actionid == "ui_jump"):
				jumpevent = event
	clearInputs("ui_accept", is_keyboard)
	for e in shared_actions:
		InputMap.action_add_event("ui_accept", e)
	clearInputs("ui_cancel", is_keyboard)
	InputMap.action_add_event("ui_cancel", jumpevent)
