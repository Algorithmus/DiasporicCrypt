
extends Polygon2D

# Container that clips children inside polygon

func _ready():
	pass

func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
