
extends Path2D

var neck
var head
var offset
var index

func _ready():
	neck = get_curve()
	head = get_parent().get_parent().get_node("head")
	index = neck.get_point_count() - 1
	var point = neck.get_point_position(index)
	offset = Vector2(point.x - head.get_global_position().x, point.y - head.get_global_position().y)
	var segments = get_parent().get_node("segments")
	for segment in segments.get_children():
		segment.set_curve(neck)
	set_physics_process(true)

func _physics_process(delta):
	var point = head.get_global_position()
	point.x = point.x + offset.x
	point.y = point.y + offset.y
	neck.set_point_position(index, point)
	set_curve(neck)