
extends Control

# Displays user interface for shopping

var itemclass = preload("res://gui/menu/gamesave.tscn")
var itemfactory

var selecteditem
var echo = false

var itemcontainer

var savepos
var savelocation

var sfxclass = preload("res://gui/menu/sfx.tscn")
var sfx

func _ready():
	sfx = sfxclass.instance()
	add_child(sfx)
	#itemfactory = Globals.get("itemfactory")
	itemcontainer = get_node("saves/container")
	set_process_input(true)
	load_menu()

func load_menu():
	# check save folder for save files
	# display data accordingly
	# after loading saves:
	var newsave = itemclass.instance()
	itemcontainer.add_child(newsave)
	newsave.setState(newsave.NEW)
	newsave.set("savepos", savepos)
	newsave.set("savelocation", savelocation)
	newsave.set_id(str(itemcontainer.get_child_count()))
	itemcontainer.get_child(0).grab_focus()

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
		"""
		if (transaction.is_hidden()):
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
				if(selecteditem.get_opacity() > 0.5):
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
			var gold = Globals.get("gold")
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
					Globals.get("inventory").remove_item(currentitem, currentamount)
					Globals.set("gold", gold + basecost * currentamount)
				else:
					var index = find_item(currentitem.title)
					if (index >= 0):
						if (inventory[index].type == "item"):
							Globals.get("inventory").add_item(currentitem, currentamount)
						elif (inventory[index].type == "scroll"):
							Globals.get("scrolls")[currentitem.title] = currentitem
						elif (inventory[index].type == "magic"):
							var magic_spells = Globals.get("magic_spells")
							var spell
							for i in range(0, magic_spells.size()):
								if (magic_spells[i].id == currentitem.value):
									spell = magic_spells[i]
							Globals.get("available_spells").append(spell)
						if (inventory[index].quantity > 0):
							inventory[index].quantity -= currentamount
						if (inventory[index].quantity == 0):
							inventory.erase(inventory[index])
					Globals.get("shops")[shopid] = inventory
					Globals.set("gold", gold - basecost * currentamount)
				transaction.hide()
				selecteditem = null
				get_node("gold").set_text(str(Globals.get("gold")) + "G")
				update_inventory()
				if (currentamount - amounttotal == 0 && amounttotal > 0):
					clear_selection(currentitem)
				else:
					itemcontainer.get_node(currentitem.title).grab_focus()
				sfx.play("confirm")
		"""

func block_cancel():
	# transaction is already unfocused, so check echo flag instead
	var result = echo
	echo = false
	return result