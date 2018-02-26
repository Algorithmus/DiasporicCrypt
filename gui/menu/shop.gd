
extends Control

# Displays user interface for shopping

const DISABLED_ALPHA = 0.5

var itemclass = preload("res://gui/menu/shoppingitem.tscn")
var itemfactory

var selecteditem
var echo = false

var buy
var sell
var currenttype = "buy"

var itemcontainer

var info
var transaction
var amount
var total
var currentamount
var amounttotal

var shopid
var sellrate
var inventory

var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	sfx = sfxclass.instance()
	add_child(sfx)
	itemfactory = ProjectSettings.get("itemfactory")
	itemcontainer = get_node("panel/itemcontainer/VBoxContainer")
	info = get_node("panel/info")
	transaction = info.get_node("transaction")
	transaction.hide()
	buy = get_node("panel/types/buy")
	buy.grab_focus()
	sell = get_node("panel/types/sell")
	set_process_input(true)
	amount = transaction.get_node("amountvalue")
	total = transaction.get_node("totalvalue")
	var shop = preload("res://scenes/ShopFactory.gd").new()
	sellrate = shop.shops[shopid].sellrate
	inventory = shop.shops[shopid].inventory
	get_node("title").set_text(shopid)
	get_node("gold").set_text(str(ProjectSettings.get("gold")) + "G")
	get_node("back").set_key("ui_cancel")
	get_node("back/input").set_text(tr("MAP_BACK"))
	info.hide()
	#Obtain saved inventory stock
	if (ProjectSettings.get("shops").has(shopid)):
		inventory = ProjectSettings.get("shops")[shopid]
	update_inventory()

func find_magic(key):
	var magic = ProjectSettings.get("available_spells")
	for i in range(0, magic.size()):
		if (magic[i].id == key):
			return magic[i]
	return null

func update_inventory():
	set_type_colors()
	var list = inventory
	if (currenttype == "sell"):
		list = ProjectSettings.get("inventory").generate_list("item")
	for item in list:
		# only display magic or scrolls if they're not already obtained
		if (!item.has("type") || item.type == "item" || (item.type == "scroll" && !ProjectSettings.get("scrolls").has(item.id)) || (item.type == "magic" && find_magic(itemfactory.items[item.id].value) == null)):
			var data
			var rate = 1
			var gold = ProjectSettings.get("gold")
			if (currenttype == "buy"):
				data = itemfactory.items[item["id"]]
			else:
				data = item["item"]
				rate = sellrate
			if (!itemcontainer.has_node(data.title)):
				var item_obj = itemclass.instance()
				item_obj.set_name(data.title)
				item_obj.get_node("title").set_text(data.title)
				item_obj.get_node("cost").set_text(str(round(data.cost * rate)) + "G")
				# disable items that are too expensive
				if (data.cost > gold && currenttype == "buy"):
					item_obj.modulate.a = DISABLED_ALPHA
				item_obj.get_node("quantity").set_text(str(item["quantity"]))
				if (item["quantity"] <= 0):
					item_obj.get_node("quantity").hide()
				var player_inventory = ProjectSettings.get("inventory").inventory
				if (player_inventory.has(data.title) && !player_inventory[data.title].item.new):
					item_obj.get_node("new").hide()
				if (item.has("type")):
					var icon = preload("res://gui/hud/potion.png")
					if (item.type == "scroll"):
						icon = preload("res://gui/menu/icons/scroll.png")
					elif (item.type == "magic"):
						icon = preload("res://gui/menu/icons/magic.png")
					item_obj.get_node("Sprite").set_texture(icon)
				# don't lose focus on irrelevant inputs
				item_obj.set_focus_neighbour(MARGIN_LEFT, ".")
				item_obj.set_focus_neighbour(MARGIN_RIGHT, ".")
				item_obj.set_focus_neighbour(MARGIN_BOTTOM, ".")
				item_obj.connect("focus_entered", self, "focus_item_enter")
				item_obj.connect("focus_exited", self, "focus_item_exit")
				# previous item should focus the next item properly
				if (itemcontainer.get_child_count() > 0):
					var lastitem = itemcontainer.get_child(itemcontainer.get_child_count() - 1)
					lastitem.set_focus_neighbour(MARGIN_BOTTOM, "")
				itemcontainer.add_child(item_obj)
			else:
				var item_obj = itemcontainer.get_node(data.title)
				item_obj.get_node("quantity").set_text(str(item["quantity"]))
				if (data.cost > gold && currenttype == "buy"):
					item_obj.modulate.a = DISABLED_ALPHA
	if (itemcontainer.get_child_count() > 0):
		get_node("panel/noitems").hide()
	else:
		get_node("panel/noitems").show()

func change_type():
	if (get_focus_owner() != null && get_focus_owner().get_name() != currenttype):
		set_type(get_focus_owner().get_name())

func set_type(value):
	currenttype = value
	clear_items()
	update_inventory()
	info.hide()
	set_type_colors()

func clear_items():
	for i in itemcontainer.get_children():
		itemcontainer.remove_child(i)
		i.queue_free()

func focus_item_enter():
	info.show()
	var scrollcontainer = get_node("panel/itemcontainer")
	var item = get_focus_owner()
	var item_obj = itemfactory.items[item.get_name()]
	var player_inventory = ProjectSettings.get("inventory").inventory
	var owned = 0
	if (player_inventory.has(item.get_name())):
		item_obj = player_inventory[item.get_name()]["item"]
		item_obj.new = false
		player_inventory[item_obj.title]["item"] = item_obj
		owned = player_inventory[item_obj.title]["quantity"]
	var title = item_obj.title
	# display short title for scrolls
	var index = find_item(item_obj.title)
	if (index >= 0 && inventory[index].type == "scroll"):
		title = item_obj.display
	item.get_node("new").hide()
	info.get_node("image").set_texture(load(item_obj.image))
	info.get_node("title").set_text(title)
	info.get_node("description").set_bbcode("[fill]" + tr(item_obj.description) + "[/fill]")
	info.get_node("cost").set_text(str(item_obj.cost) + "G")
	info.get_node("amount").set_text("x" + str(owned))
	if (scrollcontainer.get_v_scroll() + scrollcontainer.get_size().y < item.get_position().y + item.get_size().y || scrollcontainer.get_v_scroll() > item.get_position().y):
		scrollcontainer.set_v_scroll(item.get_position().y)

func focus_item_exit():
	info.hide()

func set_type_colors():
	var tab = get_node("panel/types/" + currenttype)
	tab.set("custom_colors/font_color", Color(1, 1, 0))
	if (currenttype == "buy"):
		get_node("panel/types/sell").set("custom_colors/font_color", null)
	else:
		get_node("panel/types/buy").set("custom_colors/font_color", null)

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		var player_inventory = ProjectSettings.get("inventory").inventory
		var focus = get_focus_owner()
		if (!transaction.visible):
			var type = get_node("panel/types/" + currenttype)
			var newtype
			if (event.is_action_pressed("ui_left") && type.get_index() > 0):
				newtype = get_node("panel/types").get_child(type.get_index() - 1)
				set_type(newtype.get_name())
				newtype.grab_focus()
			elif (event.is_action_pressed("ui_right") && type.get_index() < get_node("panel/types").get_child_count() - 1):
				newtype = get_node("panel/types").get_child(type.get_index() + 1)
				set_type(newtype.get_name())
				newtype.grab_focus()
			elif (event.is_action_pressed("ui_accept") && focus.get_name() != "buy" && focus.get_name() != "sell"):
				selecteditem = focus
				if(selecteditem.get_modulate().a > DISABLED_ALPHA):
					var item = itemfactory.items[selecteditem.get_name()]
					currentamount = 1
					amounttotal = int(selecteditem.get_node("quantity").get_text())
					var totalvalue = item.cost
					if (currenttype == "sell"):
						amounttotal = player_inventory[selecteditem.get_name()].quantity
						totalvalue = totalvalue * sellrate
					update_transaction(totalvalue)
					transaction.show()
					transaction.get_node("amount").grab_focus()
					info.show()
		else:
			var gold = ProjectSettings.get("gold")
			var basecost = itemfactory.items[selecteditem.get_name()].cost
			if (currenttype == "sell"):
				basecost = basecost * sellrate
			if (event.is_action_pressed("ui_cancel")):
				clear_transaction()
				echo = true
			elif (event.is_action_pressed("ui_right")):
				if (currentamount < amounttotal || amounttotal < 0):
					if (!player_inventory.has(selecteditem.get_name()) || (player_inventory.has(selecteditem.get_name()) && player_inventory[selecteditem.get_name()].quantity + currentamount < 99)):
						if (currenttype == "sell" || (currenttype == "buy" && basecost * (1+currentamount) <= gold)):
							currentamount += 1
							update_transaction(basecost)
			elif (event.is_action_pressed("ui_left")):
				if (currentamount > 1):
					currentamount -= 1
					update_transaction(basecost)
			elif (event.is_action_pressed("ui_accept")):
				var currentitem = itemfactory.items[selecteditem.get_name()]
				if (currenttype == "sell"):
					ProjectSettings.get("inventory").remove_item(currentitem, currentamount)
					ProjectSettings.set("gold", gold + basecost * currentamount)
				else:
					var index = find_item(currentitem.title)
					if (index >= 0):
						if (inventory[index].type == "item"):
							ProjectSettings.get("inventory").add_item(currentitem, currentamount)
						elif (inventory[index].type == "scroll"):
							ProjectSettings.get("scrolls")[currentitem.title] = currentitem
						elif (inventory[index].type == "magic"):
							var magic_spells = ProjectSettings.get("magic_spells")
							var spell
							for i in range(0, magic_spells.size()):
								if (magic_spells[i].id == currentitem.value):
									spell = magic_spells[i]
							ProjectSettings.get("available_spells").append(spell)
						if (inventory[index].quantity > 0):
							inventory[index].quantity -= currentamount
						if (inventory[index].quantity == 0):
							inventory.erase(inventory[index])
					ProjectSettings.get("shops")[shopid] = inventory
					ProjectSettings.set("gold", gold - basecost * currentamount)
				transaction.hide()
				selecteditem = null
				get_node("gold").set_text(str(ProjectSettings.get("gold")) + "G")
				update_inventory()
				if (currentamount - amounttotal == 0 && amounttotal > 0):
					clear_selection(currentitem)
				else:
					itemcontainer.get_node(currentitem.title).grab_focus()
				sfx.get_node("confirm").play()

func clear_selection(item):
	if (itemcontainer.has_node(item.title)):
		var item_obj = itemcontainer.get_node(item.title)
		itemcontainer.remove_child(item_obj)
		item_obj.queue_free()
	var type = currenttype
	info.hide()
	selecteditem = null
	currenttype = type
	if (itemcontainer.get_child_count() > 0):
		itemcontainer.get_child(0).grab_focus()
	else:
		get_node("panel/noitems").show()
		get_node("panel/types/" + currenttype).grab_focus()

func find_item(key):
	for i in range(0, inventory.size()):
		if (inventory[i].id == key):
			return i
	return -1

func clear_transaction():
	transaction.hide()
	selecteditem.grab_focus()
	selecteditem = null

func block_cancel():
	# transaction is already unfocused, so check echo flag instead
	var result = transaction.is_visible() || echo
	echo = false
	return result

func update_transaction(basecost):
	var totalvalue = ""
	if (amounttotal > 0):
		totalvalue = " / " + str(amounttotal)
	amount.set_text(str(currentamount) + totalvalue)
	total.set_text(str(basecost * currentamount) + "G")
