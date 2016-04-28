
extends Path2D

var curve
var head
var offset
var index

func _ready():
	curve = get_curve()
	head = get_parent().get_parent().get_node("head")
	index = curve.get_point_count() - 1
	var point = curve.get_point_pos(index)
	offset = Vector2(point.x - head.get_global_pos().x, point.y - head.get_global_pos().y)
	var segments = get_parent().get_node("segments")
	for segment in segments.get_children():
		segment.set_curve(curve)
	set_fixed_process(true)

func _fixed_process(delta):
	var point = head.get_global_pos()
	point.x = point.x + offset.x
	point.y = point.y + offset.y
	curve.set_point_pos(index, point)
	set_curve(curve)