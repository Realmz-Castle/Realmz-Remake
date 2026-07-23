class_name ClassicPlayerMapRenderer
extends RefCounted

const MAP_SIZE := 320
const X_MARKER_ID := 137
const SECRET_MARKER_ID := 139


static func render(
	map_record: Dictionary,
	map_data: Array,
	current_position: Dictionary = {}
) -> ImageTexture:
	if int(map_record.get("show", 0)) < 0 or int(map_record.get("pictId", 0)) != 0:
		return null
	var icon_size := int(map_record.get("iconSize", 0))
	if icon_size <= 0 or map_data.is_empty():
		return null

	var image := Image.create(MAP_SIZE, MAP_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(Color.BLACK)
	var tile_count := ceili(float(MAP_SIZE) / float(icon_size))
	var start_x := int(map_record.get("startX", 0))
	var start_y := int(map_record.get("startY", 0))
	var scaled_tiles: Dictionary = {}
	for map_y: int in tile_count:
		var source_y := start_y + map_y
		for map_x: int in tile_count:
			var source_x := start_x + map_x
			if source_x < 0 or source_x >= map_data.size():
				continue
			var column: Variant = map_data[source_x]
			if not (column is Array) or source_y < 0 or source_y >= column.size():
				continue
			var tile_stack: Variant = column[source_y]
			if not (tile_stack is Array):
				continue
			for tile_value: Variant in tile_stack:
				if not (tile_value is Dictionary):
					continue
				var texture_value: Variant = tile_value.get("texture")
				if not (texture_value is Texture2D):
					continue
				var tile_image := _scaled_tile(texture_value, icon_size, scaled_tiles)
				if tile_image == null:
					continue
				image.blend_rect(
					tile_image,
					Rect2i(Vector2i.ZERO, tile_image.get_size()),
					Vector2i(map_x * icon_size, map_y * icon_size)
				)

	_draw_authored_markers(image, map_record, icon_size)
	_draw_party_marker(image, map_record, current_position, icon_size)
	return ImageTexture.create_from_image(image)


static func _scaled_tile(
	texture: Texture2D,
	icon_size: int,
	cache: Dictionary
) -> Image:
	var key := "%d:%d" % [texture.get_instance_id(), icon_size]
	if cache.has(key):
		return cache[key]
	var tile_image := texture.get_image()
	if tile_image == null or tile_image.is_empty():
		return null
	if tile_image.get_width() != icon_size or tile_image.get_height() != icon_size:
		tile_image.resize(icon_size, icon_size, Image.INTERPOLATE_NEAREST)
	cache[key] = tile_image
	return tile_image


static func _draw_authored_markers(image: Image, map_record: Dictionary, icon_size: int) -> void:
	var markers: Variant = map_record.get("markers", [])
	if not (markers is Array):
		return
	for marker_value: Variant in markers:
		if not (marker_value is Dictionary):
			continue
		var marker_id := int(marker_value.get("iconId", 0))
		if marker_id == 0:
			continue
		var center := Vector2i(
			int(marker_value.get("x", 0)) * icon_size + int(icon_size / 2),
			int(marker_value.get("y", 0)) * icon_size + int(icon_size / 2)
		)
		if marker_id == X_MARKER_ID:
			_draw_x(image, center, maxi(5, int(icon_size / 2)), Color(1.0, 0.12, 0.08))
		elif marker_id == SECRET_MARKER_ID:
			_draw_box(image, center, maxi(4, int(icon_size / 2)), Color(1.0, 0.85, 0.0))
		else:
			_draw_box(image, center, maxi(4, int(icon_size / 2)), Color(0.1, 0.9, 1.0))


static func _draw_party_marker(
	image: Image,
	map_record: Dictionary,
	current_position: Dictionary,
	icon_size: int
) -> void:
	if current_position.is_empty():
		return
	var record_is_dungeon := bool(map_record.get("isDungeon", false))
	var current_is_dungeon := str(current_position.get("levelType", "land")) == "dungeon"
	if record_is_dungeon != current_is_dungeon \
			or int(map_record.get("level", -1)) != int(current_position.get("levelIndex", -2)):
		return
	var map_x := int(current_position.get("x", 0)) - int(map_record.get("startX", 0))
	var map_y := int(current_position.get("y", 0)) - int(map_record.get("startY", 0))
	var center := Vector2i(
		map_x * icon_size + int(icon_size / 2),
		map_y * icon_size + int(icon_size / 2)
	)
	_draw_plus(image, center, maxi(4, int(icon_size / 2)), Color(0.1, 1.0, 0.2))


static func _draw_x(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for offset: int in range(-radius, radius + 1):
		_set_marker_pixel(image, center + Vector2i(offset, offset), color)
		_set_marker_pixel(image, center + Vector2i(offset, -offset), color)
		_set_marker_pixel(image, center + Vector2i(offset + 1, offset), color)
		_set_marker_pixel(image, center + Vector2i(offset + 1, -offset), color)


static func _draw_box(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for offset: int in range(-radius, radius + 1):
		_set_marker_pixel(image, center + Vector2i(offset, -radius), color)
		_set_marker_pixel(image, center + Vector2i(offset, radius), color)
		_set_marker_pixel(image, center + Vector2i(-radius, offset), color)
		_set_marker_pixel(image, center + Vector2i(radius, offset), color)


static func _draw_plus(image: Image, center: Vector2i, radius: int, color: Color) -> void:
	for offset: int in range(-radius, radius + 1):
		_set_marker_pixel(image, center + Vector2i(offset, 0), color)
		_set_marker_pixel(image, center + Vector2i(0, offset), color)
		_set_marker_pixel(image, center + Vector2i(offset, 1), color)
		_set_marker_pixel(image, center + Vector2i(1, offset), color)


static func _set_marker_pixel(image: Image, point: Vector2i, color: Color) -> void:
	if point.x >= 0 and point.y >= 0 \
			and point.x < image.get_width() and point.y < image.get_height():
		image.set_pixelv(point, color)
