
extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"
var MOVESPEED = 3
var collision_rect
var accel = 1
var TILESIZE = 32
var sprite_offset
var direction = 1
var falling = false

func _fixed_process(delta):
	var space = get_world_2d().get_space()
	var space_state = Physics2DServer.space_get_direct_state(space)

	var damageTiles = collision_rect.get_overlapping_areas()
	for i in damageTiles:
		if (i.get_node("weapon") != null):
			queue_free()

	var frontX = get_global_pos().x + direction * sprite_offset.x

	var frontTile = space_state.intersect_ray(Vector2(frontX, get_global_pos().y - sprite_offset.y), Vector2(frontX, get_global_pos().y + sprite_offset.y - 1))

	if (frontTile != null && frontTile.has("position")):
		direction = direction * -1
	
	frontTile = space_state.intersect_ray(Vector2(frontX + direction*MOVESPEED, get_global_pos().y + sprite_offset.y), Vector2(frontX + direction*MOVESPEED, get_global_pos().y + sprite_offset.y + TILESIZE))
	if (frontTile == null || !frontTile.has("position")):
		direction = direction * -1
	if (frontTile != null && frontTile.has("collider")):
		var collider = frontTile["collider"]
		if (collider.get_name() == "player" && collider.get_global_pos().y - collider["sprite_offset"].y > get_global_pos().y + sprite_offset.y):
			direction = direction * -1
	
	move(Vector2(MOVESPEED * direction, 0))

	var desiredY = accel

	var floorTile = space_state.intersect_ray(Vector2(frontX, get_global_pos().y + sprite_offset.y), Vector2(frontX, get_global_pos().y + sprite_offset.y + desiredY))
	
	falling = true
	
	if (floorTile != null && floorTile.has("position")):
		if (floorTile["position"].y <= get_global_pos().y + sprite_offset.y && floorTile["position"].y > get_global_pos().y - sprite_offset.y):
			desiredY = get_global_pos().y + sprite_offset.y - floorTile["position"].y - 1
			falling = false
			accel = 1
	
	if (falling):
		accel += 1
	
	move(Vector2(0, desiredY))

func _ready():
	collision_rect = get_node("damagable")
	sprite_offset = get_node("damagable/CollisionShape2D").get_shape().get_extents()

	set_fixed_process(true)


