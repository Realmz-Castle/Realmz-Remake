class_name ClassicDungeonBattleTerrain
extends RefCounted

const TILESET_KEY := "ClassicDungeonBattle.json"
const SOURCE_ATLAS := "res://shared_assets/tiles/The Family Jewels.rsf_PICT_302.png"
const SOURCE_COLUMNS := 20
const TILE_SIZE := 32

const FLOOR_SOURCE_TILE_ID := 232
const WALL_SOURCE_TILE_ID := 234
const RUBBLE_FIRST_SOURCE_TILE_ID := 341
const RUBBLE_LAST_SOURCE_TILE_ID := 358

const FLOOR_TILE_INDEX := 0
const WALL_TILE_INDEX := 1
const RUBBLE_FIRST_TILE_INDEX := 2

const DUNGEON_WALL_MASK := 0x0001
const DUNGEON_MARKED_PATH_MASK := 0x2000
const DUNGEON_OPENING_MASK := 0x4f0e
const RUBBLE_MOVEMENT_COSTS := [
	4, 4, 1, 1, 1, 1, 1, 4, 4, 4, 6, 6, 6, 4, 6, 8, 8, 4,
]
const RUBBLE_SOUND_IDS := [
	88, 87, 85, 85, 85, 85, 87, 86, 82, 86, 89, 89, 82, 89, 86, 87, 87, 87,
]


static func is_classic_dungeon_tile(tile: Variant) -> bool:
	return tile is Dictionary and tile.has("classicDungeonField")


static func source_tile_id_for_field(field_value: int) -> int:
	var field := field_value & 0xffff
	field &= ~DUNGEON_MARKED_PATH_MASK
	if field & DUNGEON_WALL_MASK and not field & DUNGEON_OPENING_MASK:
		return WALL_SOURCE_TILE_ID
	return FLOOR_SOURCE_TILE_ID


static func ensure_tileset(tiles_book: Dictionary) -> Array:
	var existing: Variant = tiles_book.get(TILESET_KEY, [])
	if existing is Array and existing.size() == _source_tile_ids().size():
		return existing

	var atlas_texture: Texture2D = load(SOURCE_ATLAS)
	if atlas_texture == null:
		push_error("Classic dungeon battle atlas is unavailable")
		return []
	var atlas := atlas_texture.get_image()
	if (
		atlas == null
		or atlas.is_empty()
		or atlas.get_width() < SOURCE_COLUMNS * TILE_SIZE
		or atlas.get_height() < SOURCE_COLUMNS * TILE_SIZE
	):
		push_error("Classic dungeon battle atlas is malformed")
		return []

	var tiles: Array = []
	var source_tile_ids := _source_tile_ids()
	for tile_index: int in range(source_tile_ids.size()):
		var source_tile_id := int(source_tile_ids[tile_index])
		var source_index := source_tile_id - 1
		var region := Rect2i(
			(source_index % SOURCE_COLUMNS) * TILE_SIZE,
			(source_index / SOURCE_COLUMNS) * TILE_SIZE,
			TILE_SIZE,
			TILE_SIZE
		)
		var image := atlas.get_region(region)
		var blocks_movement := source_tile_id == WALL_SOURCE_TILE_ID
		var movement_cost := _movement_cost(source_tile_id)
		var sound_id := _sound_id(source_tile_id)
		tiles.append({
			"texture": ImageTexture.create_from_image(image),
			"name": "classic_dungeon_battle_%03d" % source_tile_id,
			"tileset_name": TILESET_KEY.trim_suffix(".json"),
			"id": tile_index,
			"expansion": [],
			"time": 999 if blocks_movement else movement_cost,
			"wall": int(blocks_movement),
			"swall": int(blocks_movement),
			"blkproj": int(blocks_movement),
			"blkview": int(blocks_movement),
			"water": 0,
			"dock": 0,
			"sound": [],
			"classicDungeonBattleSourceTileId": source_tile_id,
			"classicMovementCost": movement_cost,
			"classicSoundId": sound_id,
			"classicSolid": 2 if blocks_movement else 0,
			"classicLos": int(blocks_movement),
		})
	tiles_book[TILESET_KEY] = tiles
	return tiles


static func battle_tile_for_field(
	tiles: Array,
	field_value: int,
	rubble_roll := -1,
	rubble_choice := -1,
) -> Dictionary:
	if tiles.size() != _source_tile_ids().size():
		return {}
	if source_tile_id_for_field(field_value) == WALL_SOURCE_TILE_ID:
		return tiles[WALL_TILE_INDEX]

	var resolved_roll := int(rubble_roll)
	if resolved_roll < 1:
		resolved_roll = randi_range(1, 100)
	# Realmz Rand(100) returns 1 through 100, then tests for a value below 10.
	if resolved_roll >= 10:
		return tiles[FLOOR_TILE_INDEX]
	var resolved_choice := int(rubble_choice)
	if resolved_choice < 1:
		resolved_choice = randi_range(1, RUBBLE_LAST_SOURCE_TILE_ID - RUBBLE_FIRST_SOURCE_TILE_ID + 1)
	var rubble_offset := clampi(
		resolved_choice - 1,
		0,
		RUBBLE_LAST_SOURCE_TILE_ID - RUBBLE_FIRST_SOURCE_TILE_ID
	)
	return tiles[RUBBLE_FIRST_TILE_INDEX + rubble_offset]


static func _source_tile_ids() -> Array[int]:
	var source_tile_ids: Array[int] = [
		FLOOR_SOURCE_TILE_ID,
		WALL_SOURCE_TILE_ID,
	]
	for source_tile_id: int in range(
		RUBBLE_FIRST_SOURCE_TILE_ID,
		RUBBLE_LAST_SOURCE_TILE_ID + 1
	):
		source_tile_ids.append(source_tile_id)
	return source_tile_ids


static func _movement_cost(source_tile_id: int) -> int:
	if source_tile_id == FLOOR_SOURCE_TILE_ID:
		return 1
	if source_tile_id == WALL_SOURCE_TILE_ID:
		return 0
	return RUBBLE_MOVEMENT_COSTS[source_tile_id - RUBBLE_FIRST_SOURCE_TILE_ID]


static func _sound_id(source_tile_id: int) -> int:
	if source_tile_id == FLOOR_SOURCE_TILE_ID:
		return 82
	if source_tile_id == WALL_SOURCE_TILE_ID:
		return 0
	return RUBBLE_SOUND_IDS[source_tile_id - RUBBLE_FIRST_SOURCE_TILE_ID]
