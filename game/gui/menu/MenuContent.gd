
extends Control

# Basic menu content control
# Override functions to block unfocusing on some functions or manage unfocusing

# update_container() function will be called everytime the content is shown

# If the content is display only, you can prevent the control from
# ever receiving focus
var has_content = false

func _ready():
	pass

func unfocus_all():
	pass

func block_cancel():
	return false