extends RefCounted
class_name BattleOccupancyRules

## Shared footprint math for combat placement and pathfinding.


static func footprint_tiles(position: Vector2, size: Vector2) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	var anchor := Vector2i(position)
	var footprint := Vector2i(maxi(1, int(size.x)), maxi(1, int(size.y)))
	for x: int in range(footprint.x):
		for y: int in range(footprint.y):
			tiles.append(anchor + Vector2i(x, y))
	return tiles


static func blocked_anchors_for(
	occupant_position: Vector2,
	occupant_size: Vector2,
	mover_size: Vector2,
	bounds: Rect2i
) -> Array[Vector2i]:
	var blocked: Dictionary = {}
	var mover_footprint := Vector2i(
		maxi(1, int(mover_size.x)),
		maxi(1, int(mover_size.y))
	)
	for occupied_tile: Vector2i in footprint_tiles(occupant_position, occupant_size):
		for x: int in range(mover_footprint.x):
			for y: int in range(mover_footprint.y):
				var anchor := occupied_tile - Vector2i(x, y)
				if bounds.has_point(anchor):
					blocked[anchor] = true
	var result: Array[Vector2i] = []
	for anchor: Vector2i in blocked:
		result.append(anchor)
	return result
