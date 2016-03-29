
extends Control

var selectedtab = "stats"
var tabs
var panels

const TAB_START = Color(20/225.0, 20/255.0, 20/255.0, 162/255.0)
const TAB_STOP = Color(112/225.0, 112/255.0, 112/255.0, 125/255.0)

const TAB_FOCUS_START = Color(80/225.0, 0, 0, 228/255.0)
const TAB_FOCUS_STOP = Color(1, 0, 0, 162/255.0)

func _ready():
	tabs = get_node("tabs/HBoxContainer")
	for tab in tabs.get_children():
		tab.connect("tab_changed", self, "change_tab")
		tab.connect("unfocus_tab", self, "unfocus_tab")
	panels = get_node("panels")
	hide_panels()
	set_fixed_process(true)

func _draw():
	#VisualServer.canvas_item_set_clip(get_canvas_item(), true)
	pass

func hide_panels():
	for panel in panels.get_children():
		panel.hide()

func _fixed_process(delta):
	pass
	
func focus_tab():
	tabs.get_node(selectedtab).grab_focus()
	tabs.get_node(selectedtab).set("is_unfocused", false)
	set_process_input(true)
	if (Globals.get("player") == "friederich"):
		tabs.get_node("stats").set_normal_texture(preload("res://gui/menu/tabs/friederich.png"))
	else:
		tabs.get_node("stats").set_normal_texture(preload("res://gui/menu/tabs/adela.png"))

func change_tab(tab):
	panels.get_node(selectedtab).hide()
	selectedtab = tab
	if (panels.get_node(selectedtab).has_method("update_container")):
		panels.get_node(selectedtab).update_container()
	panels.get_node(selectedtab).show()
	tabs.set_opacity(1)

func unfocus_tab():
	var tab = panels.get_node(selectedtab)
	if (tab.get("has_content")):
		tabs.set_opacity(0.5)
	else:
		focus_tab()

func can_unpause():
	return (panels.get_node(selectedtab).has_method("block_pause") && !panels.get_node(selectedtab).block_pause()) || !panels.get_node(selectedtab).has_method("block_pause")

func reset():
	set_process_input(false)
	clear_panels()

func clear_panels():
	for panel in panels.get_children():
		panel.unfocus_all()

func _input(event):
	if (event.is_action_pressed("ui_cancel") && !event.is_echo() && event.is_pressed()):
		if (!panels.get_node(selectedtab).block_cancel()):
			clear_panels()
			focus_tab()
