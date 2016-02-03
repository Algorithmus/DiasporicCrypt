
extends Node2D

func _ready():
	pass

func display_damage(point, damage):
	get_node("hptext").set_text(str(damage))
	set_global_pos(point)
	get_node("AnimationPlayer").play("appear")

func calculate_hitpos(colliderpos, collidersize, targetpos, targetsize):
	return Vector2(get_hitpos_coord(colliderpos.x, collidersize.x, targetpos.x, targetsize.x), get_hitpos_coord(colliderpos.y, collidersize.y, targetpos.y, targetsize.y))

func get_hitpos_coord(colliderpos, collidersize, targetpos, targetsize):
	var hitpos = 0
	# collision from below/right
	if (colliderpos - collidersize > targetpos - targetsize && colliderpos + collidersize > targetpos + targetsize):
		hitpos = colliderpos - collidersize

	# collision from above/left
	elif (colliderpos - collidersize < targetpos - targetsize && colliderpos + collidersize < targetpos + targetsize):
		hitpos = colliderpos + collidersize
		
	# collision shorter/narrower than target
	elif (colliderpos - collidersize > targetpos - targetsize && colliderpos + collidersize < targetpos + targetsize):
		hitpos = colliderpos
	# collision taller/wider than target
	else:
		hitpos = targetpos
	return hitpos
