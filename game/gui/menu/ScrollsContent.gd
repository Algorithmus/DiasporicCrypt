
extends "res://gui/menu/MenuContent.gd"

# Displays all scrolls collected

var index
var itemclass = preload("res://gui/menu/scrollitem.scn")
var scrollcontainer
var scrollcontent
var scrolltitle
var isreading = false
var scrollcontainerwidth
var focusup
var currentline = 0
var sfxclass = preload("res://gui/menu/sfx.scn")
var sfx

func _ready():
	scrolltitle = get_node("title")
	scrollcontent = get_node("content")
	scrollcontainer = get_node("scrollselection/Control/HBoxContainer")
	scrollcontainerwidth = get_node("scrollselection").get_size().x
	focusup = get_node("icon").get_focus_neighbour(MARGIN_TOP)
	has_content = true
	sfx = sfxclass.instance()
	add_child(sfx)

func update_container():
	var scrolls = Globals.get("scrolls")
	for scroll in scrolls:
		if (!scrollcontainer.has_node(scroll)):
			var scroll_obj = scrolls[scroll]
			var scrollitem = itemclass.instance()
			scrollitem.set_name(scroll)
			scrollitem.set_text(scroll_obj.display)
			if (!scroll_obj.new):
				scrollitem.get_node("new").hide()
			scrollcontainer.add_child(scrollitem)
			scrollitem.connect("resized", self, "center_scroll")
	var scrolllist = []
	for scroll in scrollcontainer.get_children():
		scrolllist.append(scrolls[scroll.get_name()])
		scroll.set_opacity(0.5)
		scroll.set("custom_colors/font_color", null)
	if (scrolllist.size() > 0):
		scrolllist.sort_custom(preload("res://scenes/items/scroll/ScrollItem.gd"), "sort_scrolls")
	for i in range(0, scrolllist.size()-1):
		var scrollitem = scrollcontainer.get_node(scrolllist[i].title)
		scrollcontainer.move_child(scrollitem, i)
	
	show_scroll()

func unfocus_all():
	get_node("icon").release_focus()

func center_scroll():
	var scrollitem = scrollcontainer.get_node(index)
	scrollcontainer.set_pos(Vector2(-scrollitem.get_pos().x - scrollitem.get_size().x / 2 + 24 + scrollcontainerwidth / 2, scrollcontainer.get_pos().y))

func show_scroll():
	if (scrollcontainer.get_child_count() > 0):
		if (index == null):
			index = scrollcontainer.get_child(0).get_name()
		var scrolls = Globals.get("scrolls")
		var scroll = scrolls[index]
		scroll.new = false
		scrolls[index] = scroll
		Globals.set("scrolls", scrolls)
		var content = scroll.parse_content()
		var scrollitem = scrollcontainer.get_node(index)
		scrollitem.set_opacity(1)
		scrollitem.set("custom_colors/font_color", Color(1, 1, 0))
		scrollitem.get_node("new").hide()
		scrolltitle.set_text(scroll.display)
		scrollcontent.set_bbcode(content)
		scrollcontent.scroll_to_line(0)
		get_node("empty").hide()
		center_scroll()
		currentline = 0
		scrollcontent.scroll_to_line(currentline)
		has_content = true
		get_parent().get_parent().get_node("tabs/HBoxContainer/scrolls").set_focus_neighbour(MARGIN_BOTTOM, "")
	else:
		scrolltitle.set_text("SCROLL_NONE")
		scrollcontent.set_bbcode("")
		get_node("empty").show()
		get_parent().get_parent().get_node("tabs/HBoxContainer/scrolls").set_focus_neighbour(MARGIN_BOTTOM, ".")
		has_content = false

func _on_scroll_focus_enter():
	if (has_content):
		set_process_input(true)

func _on_scroll_focus_exit():
	if (has_content):
		set_process_input(false)

func _input(event):
	if (event.is_pressed() && !event.is_echo()):
		# prevent focusing on tabs while scrolling unless at the top
		var focus = focusup
		if (scrollcontent.get_v_scroll().get_val() > 0):
			focus = "."
		get_node("icon").set_focus_neighbour(MARGIN_TOP, focus)
		var oldscroll = scrollcontainer.get_node(index)
		var currentindex = oldscroll.get_index()
		if (event.is_action_pressed("ui_down") && scrollcontent.get_v_scroll().get_val() < scrollcontent.get_v_scroll().get_max() - scrollcontent.get_size().y):
			currentline += 1
		elif (event.is_action_pressed("ui_up")):
			currentline -= 1
		elif (event.is_action_pressed("ui_right") && currentindex < scrollcontainer.get_child_count() - 1):
			currentline = 0
			currentindex += 1
			oldscroll.set_opacity(0.5)
			oldscroll.set("custom_colors/font_color", null)
			index = scrollcontainer.get_child(currentindex).get_name()
			show_scroll()
			sfx.play("cursor")
		elif (event.is_action_pressed("ui_left") && currentindex > 0):
			currentline = 0
			currentindex -= 1
			oldscroll.set_opacity(0.5)
			oldscroll.set("custom_colors/font_color", null)
			index = scrollcontainer.get_child(currentindex).get_name()
			show_scroll()
			sfx.play("cursor")
		scrollcontent.scroll_to_line(currentline)
		