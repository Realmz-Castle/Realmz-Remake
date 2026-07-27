class_name ClassicMapBridge
extends RefCounted

const RandomRectangleScript = preload(
	"res://scripts/classic_runtime/classic_random_rectangle.gd"
)
# Classic landlooks 1 and 2 are obsolete; custom looks 6-8 resolve through
# producer-installed tilesets named by their catalog IDs.
const STOCK_LANDLOOK_TILESETS := {
	0: "landlook-0",
	3: "landlook-3",
	4: "landlook-4",
	5: "landlook-5",
	9: "landlook-9",
	10: "landlook-10",
}
const NATIVE_LANDLOOK_TILESETS := [
	"ForestDay",
	"ForestNight",
	"Cave",
	"Castle",
	"DesertDay",
	"Swamp",
	"SnowDay",
	"SnowNight",
	"landlook-0",
	"landlook-3",
	"landlook-4",
	"landlook-5",
	"landlook-9",
	"landlook-10",
]
# Boarding a boat replaces its map cell with this water tile in the Classic engine.
const CLASSIC_BOAT_WATER_TILE := 60
const LAND_SECRET_NONE := 0
const LAND_SECRET_HIDDEN := 1
const LAND_SECRET_REVEALED := 2
const DUNGEON_WALL_MASK := 0x0001
const DUNGEON_DOOR_MASK := 0x0006
const DUNGEON_NOTE_MASK := 0x0020
const DUNGEON_REVEALED_SECRET_MASK := 0x0040
const DUNGEON_HIDDEN_MASK := 0x0080
const DUNGEON_SECRET_DIRECTION_MASK := 0x0f00
const DUNGEON_ACTION_POINT_MASK := 0x1000
const DUNGEON_DIRECTION_BY_DELTA := {
	Vector2i(0, -1): 0x0100,
	Vector2i(1, 0): 0x0200,
	Vector2i(0, 1): 0x0400,
	Vector2i(-1, 0): 0x0800,
}
const DUNGEON_SECRET_BLOCKED_MESSAGE := \
	"Something prevents you from passing through in that direction."

var classic_bundle: Object
var native_tile_stacks: Dictionary = {}


static func select_tile_stack_sound(stack: Array) -> Dictionary:
	var classic_sound_id := 0
	for index in range(stack.size() - 1, -1, -1):
		var tile: Variant = stack[index]
		if not (tile is Dictionary):
			continue
		var native_sounds: Variant = tile.get("sound", [])
		if native_sounds is Array and not native_sounds.is_empty():
			return {"nativeSounds": native_sounds}
		if classic_sound_id == 0:
			classic_sound_id = int(tile.get("classicSoundId", 0))
	if classic_sound_id != 0:
		return {"classicSoundId": classic_sound_id}
	return {}


static func normalize_land_tile(value: int, base_tile: int) -> int:
	# Classic combines high-bit flags and 1000-offsets with a one-based tile ID.
	var tile := value
	# A source-authored base tile of zero means no underlying atlas tile.
	var fallback_tile := base_tile if base_tile >= 0 else 1
	if tile > 999:
		tile = _clear_classic_short_bit(tile, 1)
		tile = _clear_classic_short_bit(tile, 2)
		for _attempt: int in range(3):
			if tile <= 999:
				break
			tile -= 1000
	if tile > 200:
		tile = fallback_tile
	while tile > 999:
		tile -= 1000
	return maxi(0, tile)


static func land_overlay_icon_id(value: int) -> Variant:
	var icon_id := value
	if icon_id >= 0:
		icon_id = _clear_classic_short_bit(icon_id, 1)
		icon_id = _clear_classic_short_bit(icon_id, 2)
		for _attempt: int in range(3):
			if icon_id <= 999:
				break
			icon_id -= 1000
		return icon_id if icon_id > 200 and icon_id < 1000 else null
	while icon_id < -999:
		icon_id += 1000
	return icon_id


static func normalize_tile_parameter_id(value: int) -> int:
	# newland.c opcode 78 removes the path/note bits and up to three
	# action-point/secret marker bands without applying atlas fallbacks.
	var tile := _clear_classic_short_bit(value, 2)
	tile = _clear_classic_short_bit(tile, 1)
	for _attempt: int in range(3):
		if tile > 999:
			tile -= 1000
		elif tile < -999:
			tile += 1000
		else:
			break
	return tile


static func land_secret_state(value: int) -> int:
	var field := absi(value)
	field = _clear_classic_short_bit(field, 1)
	field = _clear_classic_short_bit(field, 2)
	if field > 2999:
		return LAND_SECRET_HIDDEN
	if field > 1999:
		return LAND_SECRET_REVEALED
	return LAND_SECRET_NONE


static func land_action_point_allows_entry(value: int) -> bool:
	# buttonchoice.c resolves an outdoor Action Point marker before consulting
	# the underlying land tile's solid flag. Hidden secrets first shed their
	# 3000 offset, so they do not gain this exception until discovered.
	var field := value
	if field > 0:
		field = _clear_classic_short_bit(field, 1)
		field = _clear_classic_short_bit(field, 2)
	if field > 2999:
		field -= 3000
	elif field < -2999:
		field += 3000
	return absi(field) > 999


static func native_darkness(is_dark: bool) -> int:
	return 0 if is_dark else -1


func configure(bundle: Object) -> void:
	classic_bundle = bundle
	native_tile_stacks.clear()


func classic_boat_plan(map_record: Dictionary, tileset_name: String) -> Dictionary:
	var empty_plan := {
		"status": "ok",
		"placements": {},
		"terrainByCell": {},
	}
	if str(map_record.get("levelType", "")) != "land":
		return empty_plan
	var render: Variant = map_record.get("render", {})
	if not (render is Dictionary) or str(render.get("mode", "")) != "outdoor-landlook":
		return empty_plan
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var tiles: Variant = map_record.get("tiles", [])
	if width <= 0 or height <= 0 or not (tiles is Array) or tiles.size() != width * height:
		return _error("Classic boat placement needs a complete land map")

	var landlook := int(render.get("landlook", -1))
	var attributes := _land_tile_attributes(landlook)
	if attributes.is_empty():
		return empty_plan
	var placements: Dictionary = {}
	var terrain_by_cell: Dictionary = {}
	for cell_index: int in range(tiles.size()):
		var tile_id := normalize_land_tile(int(tiles[cell_index]), 1)
		var attribute: Variant = attributes.get(tile_id)
		if not (attribute is Dictionary):
			continue
		var boat_requirement := int(attribute.get(
			"boatRequirement",
			attribute.get("needBoat", 0)
		))
		if boat_requirement != 1 or int(attribute.get("baseScale", 0)) != 0:
			continue
		# Realmz stores land fields by column, unlike Remake's row-major map data.
		var coordinate := "%d,%d" % [int(cell_index / height), cell_index % height]
		placements[coordinate] = "%s%d" % [tileset_name, tile_id - 1]
		terrain_by_cell[cell_index] = CLASSIC_BOAT_WATER_TILE
	return {
		"status": "ok",
		"placements": placements,
		"terrainByCell": terrain_by_cell,
	}


func seed_classic_boats(game_global: Object, resources: Object) -> Dictionary:
	if game_global == null or resources == null:
		return _error("Classic boat state is unavailable")
	var map_boats_value: Variant = game_global.get("map_boats_dict")
	if not (map_boats_value is Dictionary):
		return _error("Realmz boat state is unavailable")
	var map_info_value: Variant = resources.get("map_info_book")
	if not (map_info_value is Dictionary):
		return _error("Realmz map metadata is unavailable")

	var seeded_maps := 0
	var seeded_boats := 0
	for map_name_value: Variant in map_info_value:
		var map_name := str(map_name_value)
		var map_info: Variant = map_info_value[map_name_value]
		if not (map_info is Dictionary):
			continue
		var map_info_record: Dictionary = map_info
		if (
			str(map_info_record.get("map_type", "")) != "Outdoor"
			or not map_info_record.has("classic_boats")
		):
			continue
		if map_boats_value.has(map_name):
			continue
		var placements_value: Variant = map_info_record.get("classic_boats", {})
		if not (placements_value is Dictionary):
			return _error("Classic map %s has malformed boat metadata" % map_name)
		var placements: Dictionary = placements_value
		map_boats_value[map_name] = placements.duplicate(true)
		seeded_maps += 1
		seeded_boats += placements.size()
	return {
		"status": "ok",
		"seededMaps": seeded_maps,
		"seededBoats": seeded_boats,
	}


func reapply_persistent_state(
	runtime_state: Object,
	game_global: Object,
	resources: Object
) -> Dictionary:
	if runtime_state == null or not runtime_state.has_method("persistent_map_mutations"):
		return _error("Classic map state is unavailable for native replay")
	var mutations_value: Variant = runtime_state.call("persistent_map_mutations")
	if not (mutations_value is Dictionary):
		return _error("Classic map state returned malformed persistent mutations")
	var mutations: Dictionary = mutations_value
	var report := {
		"status": "ok",
		"applied": {
			"darkness": 0,
			"landLooks": 0,
			"randomRectangles": 0,
			"actionPoints": 0,
			"triggerPercents": 0,
			"tiles": 0,
		},
		"skipped": [],
		"errors": [],
	}
	var darkness_by_map: Dictionary = {}
	for darkness_value: Variant in mutations.get("darkness", []):
		if not (darkness_value is Dictionary):
			continue
		var darkness: Dictionary = darkness_value.duplicate(true)
		darkness["dark"] = int(darkness.get("darkness", 0)) != 0
		darkness_by_map[_payload_map_key(darkness)] = bool(darkness["dark"])
		_record_replay_result(
			"darkness",
			set_darkness(darkness, game_global, resources),
			report
		)
	for landlook_value: Variant in mutations.get("landLooks", []):
		if not (landlook_value is Dictionary):
			continue
		var landlook: Dictionary = landlook_value.duplicate(true)
		var landlook_map_key := _payload_map_key(landlook)
		if darkness_by_map.has(landlook_map_key):
			landlook["dark"] = bool(darkness_by_map[landlook_map_key])
		else:
			var landlook_map_name := native_map_name(
				str(landlook.get("levelType", "")),
				int(landlook.get("levelIndex", -1))
			)
			_ensure_native_map(resources, landlook_map_name, game_global)
			var landlook_map := _native_map_entry(
				resources,
				landlook_map_name
			)
			landlook["dark"] = not landlook_map.is_empty() and int(landlook_map[6]) == 0
		_record_replay_result(
			"landLooks",
			set_land_look(landlook, game_global, resources),
			report
		)
	for rectangle_value: Variant in mutations.get("randomRectangles", []):
		if not (rectangle_value is Dictionary):
			continue
		var rectangle: Dictionary = rectangle_value.duplicate(true)
		rectangle["rectangle"] = rectangle.duplicate(true)
		_record_replay_result(
			"randomRectangles",
			set_random_rectangle(rectangle, game_global, resources),
			report
		)
	for action_point_value: Variant in mutations.get("actionPoints", []):
		if action_point_value is Dictionary:
			_record_replay_result(
				"actionPoints",
				set_action_point(action_point_value, game_global, resources),
				report
			)
	for percent_value: Variant in mutations.get("triggerPercents", []):
		if not (percent_value is Dictionary):
			continue
		var percent: Dictionary = percent_value.duplicate(true)
		percent["triggerIds"] = [int(percent.get("triggerId", -1))]
		_record_replay_result(
			"triggerPercents",
			set_trigger_percent(percent, game_global, resources),
			report
		)
	# The palette deliberately outlives a maps_book reload. Reusing those deep
	# copies keeps repeated replay independent of cells changed by earlier runs.
	for tile_value: Variant in mutations.get("tiles", []):
		if tile_value is Dictionary:
			_record_replay_result(
				"tiles",
				set_tile(tile_value, game_global, resources),
				report
			)
	if not report["errors"].is_empty():
		report["status"] = "error"
		report["message"] = "One or more Classic map mutations could not be reapplied"
	return report


func native_map_name(level_type: String, level_index: int) -> String:
	match level_type:
		"land":
			return "map_%d" % level_index
		"dungeon":
			return "mapd_%d" % level_index
		_:
			return ""


func transition(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var level_type := str(payload.get("levelType", ""))
	var level_index := int(payload.get("levelIndex", -1))
	var map_name := native_map_name(level_type, level_index)
	if map_name.is_empty() or level_index < 0:
		return _error("Classic map transition has an invalid destination")
	if not _ensure_native_map(resources, map_name, game_global):
		return _error("Classic map %s has no loaded native map resource" % map_name)
	seed_classic_boats(game_global, resources)
	if game_global == null:
		return _error("Realmz map state is unavailable")

	var x := int(payload.get("x", -1))
	var y := int(payload.get("y", -1))
	if x < 0 or y < 0:
		return _error("Classic map transition has invalid coordinates")

	var changed_map := (
		bool(payload.get("forceReload", false))
		or str(game_global.get("currentmap_name")) != map_name
	)
	if changed_map:
		if not game_global.has_method("change_map"):
			return _error("Realmz map transition helper is unavailable")
		game_global.call("change_map", map_name, x, y)
	else:
		_set_current_position(game_global.get("map"), x, y)

	var map: Variant = game_global.get("map")
	if map is Object and map.has_method("queue_redraw"):
		map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"mapChanged": changed_map,
		"position": Vector2i(x, y),
		"recheckDestination": bool(payload.get("recheckDestination", false)),
	}


func redraw_view(payload: Dictionary, game_global: Object) -> Dictionary:
	if game_global == null:
		return _error("Realmz map state is unavailable")
	var map: Variant = game_global.get("map")
	if not (map is Object) or not map.has_method("queue_redraw"):
		return _error("Realmz map display is unavailable")
	map.queue_redraw()
	return {
		"heading": int(payload.get("heading", 0)),
		"multiView": bool(payload.get("multiView", false)),
		"viewType": int(payload.get("viewType", 1)),
		"compassEnabled": bool(payload.get("compassEnabled", true)),
	}


func discover_map_secrets(
	runtime_state: Object,
	position: Vector2i,
	game_global: Object,
	resources: Object
) -> Dictionary:
	if runtime_state == null:
		return {"handled": false}
	var level_type := str(runtime_state.get("level_type"))
	if level_type not in ["land", "dungeon"]:
		return {"handled": false}
	var level_index := int(runtime_state.get("level_index"))
	var map_name := native_map_name(level_type, level_index)
	if game_global == null or str(game_global.get("currentmap_name")) != map_name:
		return {"handled": false}
	if classic_bundle == null or not classic_bundle.has_method("get_map"):
		return _secret_error("Classic map data is unavailable")
	var map_record: Variant = classic_bundle.get_map("%s:%d" % [level_type, level_index])
	if not (map_record is Dictionary):
		return _secret_error("Classic map %s is unavailable" % map_name)
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var tiles: Variant = map_record.get("tiles", [])
	if not (tiles is Array) or width <= 0 or height <= 0 or tiles.size() != width * height:
		return _secret_error("Classic map %s has invalid tile data" % map_name)
	if not game_global.has_method("roll_classic_secret_detection"):
		return _secret_error("Classic party secret-detection rules are unavailable")

	var discoveries: Array[Dictionary] = []
	for y: int in range(position.y - 1, position.y + 2):
		for x: int in range(position.x - 1, position.x + 2):
			if x < 0 or y < 0 or x >= width or y >= height:
				continue
			var tile_index := _classic_map_tile_index(level_type, width, height, x, y)
			var fallback_field := int(tiles[tile_index])
			var field := fallback_field
			if runtime_state.has_method("get_tile"):
				field = int(runtime_state.call(
					"get_tile",
					level_type,
					level_index,
					x,
					y,
					fallback_field
				))
			var hidden := land_secret_state(field) == LAND_SECRET_HIDDEN \
				if level_type == "land" else (
					field & DUNGEON_SECRET_DIRECTION_MASK != 0
					and field & DUNGEON_REVEALED_SECRET_MASK == 0
				)
			if not hidden or not bool(game_global.call("roll_classic_secret_detection")):
				continue
			var revealed_field := field - 1000 if field > 0 else field + 1000
			if level_type == "dungeon":
				var unsigned_field := field & 0xffff
				revealed_field = unsigned_field | DUNGEON_REVEALED_SECRET_MASK
				if revealed_field >= 0x8000:
					revealed_field -= 0x10000
			var projection := set_tile({
				"levelType": level_type,
				"levelIndex": level_index,
				"x": x,
				"y": y,
				"tileValue": revealed_field,
			}, game_global, resources)
			if str(projection.get("status", "")) in ["error", "skipped"]:
				return _secret_error(str(projection.get(
					"message",
					"Classic secret could not be revealed"
				)))
			if runtime_state.has_method("set_tile"):
				runtime_state.call(
					"set_tile",
					level_type,
					level_index,
					x,
					y,
					revealed_field
				)
			discoveries.append({
				"levelType": level_type,
				"levelIndex": level_index,
				"position": Vector2i(x, y),
				"field": revealed_field,
			})
			# checkforsecret.c stops after the first dungeon discovery.
			if level_type == "dungeon":
				return {
					"handled": true,
					"revealed": true,
					"discoveries": discoveries,
				}
	return {
		"handled": true,
		"revealed": not discoveries.is_empty(),
		"discoveries": discoveries,
	}


func reveal_dungeon_overhead(
	runtime_state: Object,
	position: Vector2i,
	game_global: Object,
	resources: Object
) -> Dictionary:
	if runtime_state == null or str(runtime_state.get("level_type")) != "dungeon":
		return {"handled": false}
	var level_index := int(runtime_state.get("level_index"))
	var map_name := native_map_name("dungeon", level_index)
	if game_global == null or str(game_global.get("currentmap_name")) != map_name:
		return {"handled": false}
	if classic_bundle == null or not classic_bundle.has_method("get_map"):
		return _error("Classic dungeon map data is unavailable")
	var map_record: Variant = classic_bundle.get_map("dungeon:%d" % level_index)
	if not (map_record is Dictionary):
		return _error("Classic dungeon %d is unavailable" % level_index)
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var tiles: Variant = map_record.get("tiles", [])
	if not (tiles is Array) or width <= 0 or height <= 0 or tiles.size() != width * height:
		return _error("Classic dungeon %d has invalid tile data" % level_index)

	var revealed_positions: Array[Vector2i] = []
	for y: int in range(position.y - 1, position.y + 2):
		for x: int in range(position.x - 1, position.x + 2):
			if x < 0 or y < 0 or x >= width or y >= height:
				continue
			var tile_index := _classic_map_tile_index("dungeon", width, height, x, y)
			var fallback_field := int(tiles[tile_index])
			var field := fallback_field
			if runtime_state.has_method("get_tile"):
				field = int(runtime_state.call(
					"get_tile",
					"dungeon",
					level_index,
					x,
					y,
					fallback_field
				))
			if not (field & DUNGEON_HIDDEN_MASK):
				continue
			var visible_field := _clear_classic_short_bit(field, 8)
			var projection := set_tile({
				"levelType": "dungeon",
				"levelIndex": level_index,
				"x": x,
				"y": y,
				"tileValue": visible_field,
			}, game_global, resources)
			if str(projection.get("status", "")) in ["error", "skipped"]:
				return _error(str(projection.get(
					"message",
					"Classic dungeon overhead tile could not be revealed"
				)))
			if runtime_state.has_method("set_tile"):
				runtime_state.call(
					"set_tile",
					"dungeon",
					level_index,
					x,
					y,
					visible_field
				)
			revealed_positions.append(Vector2i(x, y))
	return {
		"status": "ok",
		"handled": true,
		"revealedTiles": revealed_positions.size(),
		"positions": revealed_positions,
	}


func resolve_dungeon_movement(
	runtime_state: Object,
	from_position: Vector2i,
	to_position: Vector2i,
	game_global: Object,
	resources: Object
) -> Dictionary:
	if runtime_state == null or str(runtime_state.get("level_type")) != "dungeon":
		return {"handled": false}
	var level_index := int(runtime_state.get("level_index"))
	var map_name := native_map_name("dungeon", level_index)
	if game_global == null or str(game_global.get("currentmap_name")) != map_name:
		return {"handled": false}
	if classic_bundle == null or not classic_bundle.has_method("get_map"):
		return _movement_error("Classic dungeon map data is unavailable")
	var map_record: Variant = classic_bundle.get_map("dungeon:%d" % level_index)
	if not (map_record is Dictionary):
		return _movement_error("Classic dungeon %d is unavailable" % level_index)
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var tiles: Variant = map_record.get("tiles", [])
	if (
		not (tiles is Array)
		or width <= 0
		or height <= 0
		or tiles.size() != width * height
		or to_position.x < 0
		or to_position.y < 0
		or to_position.x >= width
		or to_position.y >= height
	):
		return _movement_error("Classic dungeon movement is outside map %s" % map_name)

	var tile_index := to_position.y * width + to_position.x
	var fallback_field := int(tiles[tile_index])
	var field := fallback_field
	if runtime_state.has_method("get_tile"):
		field = int(runtime_state.call(
			"get_tile",
			"dungeon",
			level_index,
			to_position.x,
			to_position.y,
			fallback_field
		))
	var unsigned_field := field & 0xffff
	var secret_directions := unsigned_field & DUNGEON_SECRET_DIRECTION_MASK
	if secret_directions == 0 or unsigned_field & DUNGEON_DOOR_MASK:
		return {"handled": false}

	var entry_direction := int(DUNGEON_DIRECTION_BY_DELTA.get(
		to_position - from_position,
		0
	))
	if entry_direction != 0 and secret_directions & entry_direction:
		var revealed_field := unsigned_field | DUNGEON_REVEALED_SECRET_MASK
		var newly_revealed := revealed_field != unsigned_field
		if newly_revealed:
			var signed_field := revealed_field - 0x10000 \
				if revealed_field >= 0x8000 else revealed_field
			var projection := set_tile({
				"levelType": "dungeon",
				"levelIndex": level_index,
				"x": to_position.x,
				"y": to_position.y,
				"tileValue": signed_field,
			}, game_global, resources)
			if str(projection.get("status", "")) in ["error", "skipped"]:
				return _movement_error(str(projection.get(
					"message",
					"Classic dungeon secret could not be revealed"
				)))
			if runtime_state.has_method("set_tile"):
				runtime_state.call(
					"set_tile",
					"dungeon",
					level_index,
					to_position.x,
					to_position.y,
					signed_field
				)
		return {
			"handled": true,
			"allowed": true,
			"revealed": newly_revealed,
			"field": revealed_field,
			"movementTime": 1,
		}

	# Classic still admits note and Action Point cells, and direction metadata
	# without a hard wall does not block movement.
	if (
		unsigned_field & (DUNGEON_NOTE_MASK | DUNGEON_ACTION_POINT_MASK)
		or not (unsigned_field & DUNGEON_WALL_MASK)
	):
		return {"handled": false}
	return {
		"handled": true,
		"allowed": false,
		"message": DUNGEON_SECRET_BLOCKED_MESSAGE,
		"field": unsigned_field,
	}


func resolve_land_movement(
	runtime_state: Object,
	from_position: Vector2i,
	to_position: Vector2i,
	game_global: Object,
	resources: Object = null
) -> Dictionary:
	if runtime_state == null or str(runtime_state.get("level_type")) != "land":
		return {"handled": false}
	var level_index := int(runtime_state.get("level_index"))
	var map_name := native_map_name("land", level_index)
	if game_global == null or str(game_global.get("currentmap_name")) != map_name:
		return {"handled": false}
	if classic_bundle == null or not classic_bundle.has_method("get_map"):
		return _movement_error("Classic land map data is unavailable")
	var map_record: Variant = classic_bundle.get_map("land:%d" % level_index)
	if not (map_record is Dictionary):
		return _movement_error("Classic land map %d is unavailable" % level_index)
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var tiles: Variant = map_record.get("tiles", [])
	if (
		not (tiles is Array)
		or width <= 0
		or height <= 0
		or tiles.size() != width * height
	):
		return _movement_error("Classic land map %s has invalid tile data" % map_name)
	if (
		to_position.x < 0
		or to_position.y < 0
		or to_position.x >= width
		or to_position.y >= height
	):
		return _resolve_land_edge_transition(
			runtime_state,
			level_index,
			from_position,
			to_position,
			Vector2i(width, height),
			game_global,
			resources
		)

	var tile_index := _classic_map_tile_index(
		"land",
		width,
		height,
		to_position.x,
		to_position.y
	)
	var fallback_field := int(tiles[tile_index])
	var field := fallback_field
	if runtime_state.has_method("get_tile"):
		field = int(runtime_state.call(
			"get_tile",
			"land",
			level_index,
			to_position.x,
			to_position.y,
			fallback_field
		))
	if not land_action_point_allows_entry(field):
		return {"handled": false}
	return {
		"handled": true,
		"allowed": true,
		"field": field,
	}


func resolve_movement(
	runtime_state: Object,
	from_position: Vector2i,
	to_position: Vector2i,
	game_global: Object,
	resources: Object
) -> Dictionary:
	if runtime_state != null and str(runtime_state.get("level_type")) == "land":
		return resolve_land_movement(
			runtime_state,
			from_position,
			to_position,
			game_global,
			resources
		)
	return resolve_dungeon_movement(
		runtime_state,
		from_position,
		to_position,
		game_global,
		resources
	)


func _resolve_land_edge_transition(
	runtime_state: Object,
	level_index: int,
	from_position: Vector2i,
	to_position: Vector2i,
	map_size: Vector2i,
	game_global: Object,
	resources: Object
) -> Dictionary:
	if not classic_bundle.has_method("get_land_layout"):
		return _blocked_land_edge()
	var layout: Variant = classic_bundle.call("get_land_layout")
	if not (layout is Dictionary):
		return _blocked_land_edge()
	var columns := int(layout.get("cols", 0))
	var rows := int(layout.get("rows", 0))
	var cells: Variant = layout.get("cells", [])
	if (
		not (cells is Array)
		or columns <= 0
		or rows <= 0
		or cells.size() != columns * rows
	):
		return _blocked_land_edge()

	var layout_level := -1 if level_index == 0 else level_index
	var current_cell := Vector2i(-1, -1)
	for cell_index: int in range(cells.size()):
		if int(cells[cell_index]) == layout_level:
			current_cell = Vector2i(cell_index % columns, int(cell_index / columns))
			break
	if current_cell.x < 0:
		return _blocked_land_edge()

	var layout_delta := Vector2i.ZERO
	if to_position.x < 0 and from_position.x == 0:
		layout_delta.x = -1
	elif to_position.x >= map_size.x and from_position.x == map_size.x - 1:
		layout_delta.x = 1
	if to_position.y < 0 and from_position.y == 0:
		layout_delta.y = -1
	elif to_position.y >= map_size.y and from_position.y == map_size.y - 1:
		layout_delta.y = 1
	if layout_delta == Vector2i.ZERO:
		return _blocked_land_edge()

	var destination_cell := current_cell + layout_delta
	if (
		destination_cell.x < 0
		or destination_cell.y < 0
		or destination_cell.x >= columns
		or destination_cell.y >= rows
	):
		return _blocked_land_edge()
	var destination_layout_level := int(
		cells[destination_cell.y * columns + destination_cell.x]
	)
	if destination_layout_level == 0 or destination_layout_level == layout_level:
		return _blocked_land_edge()
	var destination_level := 0 if destination_layout_level == -1 else destination_layout_level
	var destination_map: Variant = classic_bundle.get_map("land:%d" % destination_level)
	if not (destination_map is Dictionary):
		return _movement_error(
			"Classic land layout references unavailable map %d" % destination_level
		)
	var destination_size := Vector2i(
		int(destination_map.get("width", 0)),
		int(destination_map.get("height", 0))
	)
	if destination_size.x <= 0 or destination_size.y <= 0:
		return _movement_error(
			"Classic land layout destination %d has invalid dimensions" % destination_level
		)
	var destination_position := Vector2i(
		destination_size.x - 1 if to_position.x < 0 else (
			0 if to_position.x >= map_size.x else clampi(to_position.x, 0, destination_size.x - 1)
		),
		destination_size.y - 1 if to_position.y < 0 else (
			0 if to_position.y >= map_size.y else clampi(to_position.y, 0, destination_size.y - 1)
		)
	)
	var transition_result := transition({
		"levelType": "land",
		"levelIndex": destination_level,
		"x": destination_position.x,
		"y": destination_position.y,
	}, game_global, resources)
	if str(transition_result.get("status", "")) == "error":
		return _movement_error(str(transition_result.get(
			"message",
			"Classic land edge transition failed"
		)))
	runtime_state.call(
		"set_location",
		"land",
		destination_level,
		destination_position.x,
		destination_position.y
	)
	return {
		"handled": true,
		"allowed": true,
		"transitioned": true,
		"levelIndex": destination_level,
		"position": destination_position,
		"layoutCell": destination_cell,
		"transition": transition_result,
	}


func _blocked_land_edge() -> Dictionary:
	return {
		"handled": true,
		"allowed": false,
		"blockedByLayout": true,
	}


func set_darkness(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var map_name := native_map_name(
		str(payload.get("levelType", "")),
		int(payload.get("levelIndex", -1))
	)
	_ensure_native_map(resources, map_name, game_global)
	var map_entry := _native_map_entry(resources, map_name)
	if map_entry.is_empty():
		return _error("Classic map %s has no loaded native map resource" % map_name)

	var darkness_level := native_darkness(bool(payload.get("dark", false)))
	map_entry[6] = darkness_level
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null:
		current_map.set("darkness_level", darkness_level)
		if current_map.has_method("queue_redraw"):
			current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"nativeDarkness": darkness_level,
	}


func set_land_look(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var result := set_darkness(payload, game_global, resources)
	if str(result.get("status", "")) == "error":
		return result
	var landlook := int(payload.get("landlook", 0))
	result["landlook"] = landlook
	result["tilesetChanged"] = false
	var target_tileset := _native_landlook_tileset(landlook, resources)
	if target_tileset.is_empty():
		return _merge_result(
			result,
			_skipped("Classic landlook %d has no loaded native tileset" % landlook)
		)

	var map_name := native_map_name(
		str(payload.get("levelType", "")),
		int(payload.get("levelIndex", -1))
	)
	var map_entry := _native_map_entry(resources, map_name)
	var map_data: Variant = map_entry[0] if not map_entry.is_empty() else null
	if not (map_data is Array):
		return _merge_result(result, _error("Native map %s has malformed tile data" % map_name))

	var source_tilesets := _native_landlook_tilesets(resources)
	var target_tiles: Array = _native_tileset(resources, target_tileset)
	var scan := _scan_landlook_tiles(map_data, source_tilesets, target_tiles)
	if int(scan["matchedTiles"]) == 0:
		return _merge_result(
			result,
			_skipped("Classic map %s has no recognized native landlook tiles" % map_name)
		)
	if not scan["missingTileIds"].is_empty():
		return _merge_result(
			result,
			_skipped(
				"Native tileset %s cannot represent tile IDs %s" % [
					target_tileset,
					str(scan["missingTileIds"]),
				]
			)
		)

	var changed_tiles := _replace_landlook_tiles(
		map_data,
		source_tilesets,
		target_tileset,
		target_tiles
	)
	_replace_cached_landlook_tiles(
		map_name,
		source_tilesets,
		target_tileset,
		target_tiles
	)
	result["nativeTileset"] = target_tileset
	result["matchedTiles"] = int(scan["matchedTiles"])
	result["changedTiles"] = changed_tiles
	result["tilesetChanged"] = changed_tiles > 0
	return result


func set_tile(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var level_type := str(payload.get("levelType", ""))
	var level_index := int(payload.get("levelIndex", -1))
	var map_name := native_map_name(level_type, level_index)
	_ensure_native_map(resources, map_name, game_global)
	var map_entry := _native_map_entry(resources, map_name)
	if map_entry.is_empty():
		return _error("Classic map %s has no loaded native map resource" % map_name)
	if classic_bundle == null or not classic_bundle.has_method("get_map"):
		return _skipped("Classic map data is unavailable for tile projection")

	var map_record: Variant = classic_bundle.get_map("%s:%d" % [level_type, level_index])
	if not (map_record is Dictionary):
		return _skipped("Classic map %s has no compiled tile data" % map_name)
	var tiles: Variant = map_record.get("tiles", [])
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	if not (tiles is Array) or tiles.size() != width * height:
		return _skipped("Classic map %s has no compiled tile data" % map_name)

	var x := int(payload.get("x", -1))
	var y := int(payload.get("y", -1))
	if x < 0 or y < 0 or x >= width or y >= height:
		return _error("Classic tile mutation is outside map %s" % map_name)
	var native_map: Variant = map_entry[0]
	if not _has_native_cell(native_map, x, y):
		return _error("Native map %s does not match the compiled map dimensions" % map_name)

	var tile_value := int(payload.get("tileValue", -1))
	if level_type == "land" and land_secret_state(tile_value) == LAND_SECRET_REVEALED:
		_set_native_land_secret_state(
			map_entry,
			_current_map(game_global, map_name),
			Vector2i(x, y),
			true
		)
		var revealed_map: Variant = _current_map(game_global, map_name)
		if revealed_map != null and revealed_map.has_method("queue_redraw"):
			revealed_map.queue_redraw()
		return {
			"nativeMapName": map_name,
			"sourceCell": Vector2i(x, y),
			"targetCell": Vector2i(x, y),
			"tileValue": tile_value,
		}
	var native_tile: Dictionary = _native_tile_stack(
		map_name,
		map_record,
		native_map,
		tile_value,
		resources
	)
	if native_tile.is_empty():
		return _skipped(
			"Classic tile %d has no native reference cell on %s" % [tile_value, map_name]
		)

	var source_cell: Vector2i = native_tile["sourceCell"]
	native_map[x][y] = native_tile["stack"].duplicate(true)
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null and current_map.has_method("queue_redraw"):
		current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"sourceCell": source_cell,
		"targetCell": Vector2i(x, y),
		"tileValue": tile_value,
	}


func set_trigger_percent(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var level_type := str(payload.get("levelType", ""))
	var level_index := int(payload.get("levelIndex", -1))
	var map_name := native_map_name(
		level_type,
		level_index
	)
	_ensure_native_map(resources, map_name, game_global)
	var script_areas: Variant = _native_script_areas(resources, map_name)
	if script_areas == null:
		return _error("Classic map %s has no loaded native script areas" % map_name)

	var updated: Array = []
	for trigger_id_value: Variant in payload.get("triggerIds", []):
		var trigger_id := int(trigger_id_value)
		var stable_id := _stable_trigger_id(level_type, level_index, trigger_id)
		for area_name: Variant in script_areas:
			var area: Variant = script_areas[area_name]
			if area is Dictionary and _area_matches_trigger(
				str(area_name), area, trigger_id, stable_id
			):
				area["chance"] = maxf(0.0, float(payload.get("percent", 0)) / 100.0)
				updated.append(str(area_name))
	if updated.is_empty():
		return _skipped("Classic trigger mutation has no matching native Action Point area")
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null and current_map.has_method("queue_redraw"):
		current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"updatedAreas": updated,
	}


func set_action_point(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var level_type := str(payload.get("levelType", ""))
	var level_index := int(payload.get("levelIndex", -1))
	var record_index := int(payload.get("recordIndex", -1))
	var map_name := native_map_name(level_type, level_index)
	_ensure_native_map(resources, map_name, game_global)
	var script_areas: Variant = _native_script_areas(resources, map_name)
	if script_areas == null:
		return _error("Classic map %s has no loaded native script areas" % map_name)
	if record_index < 0:
		return _error("Classic Action Point override has no record index")

	var stable_id := str(payload.get(
		"id",
		_stable_trigger_id(level_type, level_index, record_index)
	))
	if stable_id.is_empty():
		stable_id = _stable_trigger_id(level_type, level_index, record_index)
	var projected_area: Dictionary = {}
	var replaced_areas: Array = []
	for area_name_value: Variant in script_areas.keys():
		var area_name := str(area_name_value)
		var area: Variant = script_areas[area_name_value]
		if not (area is Dictionary) or not _area_matches_trigger(
			area_name, area, record_index, stable_id
		):
			continue
		if projected_area.is_empty():
			projected_area = area.duplicate(true)
		replaced_areas.append(area_name)
		script_areas.erase(area_name_value)

	var coordinate: Variant = payload.get("coordinate")
	if not (coordinate is Dictionary):
		return {
			"nativeMapName": map_name,
			"disabled": true,
			"replacedAreas": replaced_areas,
		}
	var x := int(coordinate.get("x", -1))
	var y := int(coordinate.get("y", -1))
	if x < 0 or y < 0:
		return _error("Classic Action Point override has invalid coordinates")
	var area_name := "AP%dx%dy%d" % [record_index, x, y]
	projected_area["scriptRectangle"] = [[x, y], [x, y]]
	projected_area["scriptToLoad"] = stable_id
	projected_area["chance"] = maxf(0.0, float(payload.get("percent", 0)) / 100.0)
	script_areas[area_name] = projected_area
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null and current_map.has_method("queue_redraw"):
		current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"updatedArea": area_name,
		"replacedAreas": replaced_areas,
		"triggerId": stable_id,
	}


func set_random_rectangle(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var level_type := str(payload.get("levelType", ""))
	var level_index := int(payload.get("levelIndex", -1))
	var map_name := native_map_name(level_type, level_index)
	_ensure_native_map(resources, map_name, game_global)
	var script_areas: Variant = _native_script_areas(resources, map_name)
	if script_areas == null:
		return _error("Classic map %s has no loaded native script areas" % map_name)

	var prefix := "LRR" if level_type == "land" else "DRR"
	var area_name := "%s%d.%d" % [prefix, level_index, int(payload.get("rectIndex", -1))]
	if not script_areas.has(area_name):
		return _skipped("Classic random rectangle %s has no native map area" % area_name)
	var area: Variant = script_areas[area_name]
	var rectangle: Variant = payload.get("rectangle", {})
	if not (area is Dictionary) or not (rectangle is Dictionary):
		return _error("Classic random rectangle %s is malformed" % area_name)
	var message_text := ""
	var message_id := int(rectangle.get("text", 0))
	if (
		message_id != 0
		and classic_bundle != null
		and classic_bundle.has_method("get_message")
	):
		var message: Variant = classic_bundle.call("get_message", message_id)
		if message is Dictionary:
			message_text = str(message.get("text", ""))
	RandomRectangleScript.apply_rectangle(
		area,
		level_type,
		level_index,
		rectangle,
		message_text
	)
	script_areas[area_name] = area
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null and current_map.has_method("queue_redraw"):
		current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"updatedArea": area_name,
	}


func _native_landlook_tileset(landlook: int, resources: Object) -> String:
	var catalog_name := str(_catalog_landlook_tilesets(resources).get(landlook, ""))
	if not catalog_name.is_empty():
		return catalog_name
	var stock_name := str(STOCK_LANDLOOK_TILESETS.get(landlook, ""))
	if not stock_name.is_empty() and not _native_tileset(resources, stock_name).is_empty():
		return stock_name
	return ""


func _land_tile_attributes(landlook: int) -> Dictionary:
	var by_tile: Dictionary = {}
	if classic_bundle == null:
		return by_tile
	var documents: Variant = classic_bundle.get("documents")
	if not (documents is Dictionary):
		return by_tile
	var maps_document: Variant = documents.get("maps", {})
	if not (maps_document is Dictionary):
		return by_tile
	var attributes: Variant = maps_document.get("tileAttributes", [])
	if attributes is Array:
		for attribute_value: Variant in attributes:
			if typeof(attribute_value) != TYPE_DICTIONARY:
				continue
			var attribute: Dictionary = attribute_value
			var attribute_landlook: Variant = attribute.get("landlook")
			if attribute_landlook != null and int(attribute_landlook) == landlook:
				by_tile[int(attribute.get("tile", 0))] = attribute
	if not by_tile.is_empty():
		return by_tile

	var custom_landlooks: Variant = maps_document.get("customLandlooks", [])
	if not (custom_landlooks is Array):
		return by_tile
	for custom_value: Variant in custom_landlooks:
		if not (custom_value is Dictionary):
			continue
		var custom: Dictionary = custom_value
		if int(custom.get("landlook", -1)) != landlook:
			continue
		var base_scale := int(custom.get("baseScale", 1))
		var records: Variant = custom.get("records", [])
		if records is Array:
			for record_value: Variant in records:
				if not (record_value is Dictionary):
					continue
				var record: Dictionary = record_value.duplicate(true)
				record["baseScale"] = base_scale
				by_tile[int(record.get("tile", 0))] = record
		break
	return by_tile


func _native_landlook_tilesets(resources: Object) -> Dictionary:
	var names: Dictionary = {}
	for tileset_name: String in NATIVE_LANDLOOK_TILESETS:
		names[tileset_name] = true
	for tileset_name: Variant in _catalog_landlook_tilesets(resources).values():
		names[str(tileset_name)] = true
	return names


func _catalog_landlook_tilesets(resources: Object) -> Dictionary:
	var names: Dictionary = {}
	if classic_bundle == null:
		return names
	var documents: Variant = classic_bundle.get("documents")
	if not (documents is Dictionary):
		return names
	var assets: Variant = documents.get("assets", {})
	if not (assets is Dictionary):
		return names
	var catalog: Variant = assets.get("catalog", {})
	if not (catalog is Dictionary):
		return names
	var tilesets: Variant = catalog.get("tilesets", [])
	if not (tilesets is Array):
		return names
	for tileset_value: Variant in tilesets:
		if not (tileset_value is Dictionary):
			continue
		var tileset_name := str(tileset_value.get("id", ""))
		if tileset_name.is_empty() or _native_tileset(resources, tileset_name).is_empty():
			continue
		names[int(tileset_value.get("landlook", -1))] = tileset_name
	return names


func _native_tileset(resources: Object, tileset_name: String) -> Array:
	if resources == null or tileset_name.is_empty():
		return []
	var tiles_book: Variant = resources.get("tiles_book")
	if not (tiles_book is Dictionary):
		return []
	var tiles: Variant = tiles_book.get(tileset_name + ".json", [])
	return tiles if tiles is Array else []


func _scan_landlook_tiles(
	map_data: Array,
	source_tilesets: Dictionary,
	target_tiles: Array
) -> Dictionary:
	var matched_tiles := 0
	var missing_tile_ids: Dictionary = {}
	for column_value: Variant in map_data:
		if not (column_value is Array):
			continue
		for stack_value: Variant in column_value:
			if not (stack_value is Array):
				continue
			for tile_value: Variant in stack_value:
				if not (tile_value is Dictionary):
					continue
				if not source_tilesets.has(str(tile_value.get("tileset_name", ""))):
					continue
				matched_tiles += 1
				var tile_id := int(tile_value.get("id", -1))
				if tile_id < 0 or tile_id >= target_tiles.size():
					missing_tile_ids[tile_id] = true
	var missing_ids: Array = missing_tile_ids.keys()
	missing_ids.sort()
	return {
		"matchedTiles": matched_tiles,
		"missingTileIds": missing_ids,
	}


func _replace_landlook_tiles(
	map_data: Array,
	source_tilesets: Dictionary,
	target_tileset: String,
	target_tiles: Array
) -> int:
	var changed_tiles := 0
	for column_value: Variant in map_data:
		if not (column_value is Array):
			continue
		for stack_value: Variant in column_value:
			if stack_value is Array:
				changed_tiles += _replace_landlook_stack(
					stack_value,
					source_tilesets,
					target_tileset,
					target_tiles
				)
	return changed_tiles


func _replace_cached_landlook_tiles(
	map_name: String,
	source_tilesets: Dictionary,
	target_tileset: String,
	target_tiles: Array
) -> void:
	var palette: Variant = native_tile_stacks.get(map_name, {})
	if not (palette is Dictionary):
		return
	for entry_value: Variant in palette.values():
		if not (entry_value is Dictionary):
			continue
		var stack: Variant = entry_value.get("stack", [])
		if stack is Array:
			_replace_landlook_stack(stack, source_tilesets, target_tileset, target_tiles)


func _replace_landlook_stack(
	stack: Array,
	source_tilesets: Dictionary,
	target_tileset: String,
	target_tiles: Array
) -> int:
	var changed_tiles := 0
	for layer: int in range(stack.size()):
		var tile: Variant = stack[layer]
		if not (tile is Dictionary):
			continue
		var tileset_name := str(tile.get("tileset_name", ""))
		if not source_tilesets.has(tileset_name) or tileset_name == target_tileset:
			continue
		var tile_id := int(tile.get("id", -1))
		if tile_id < 0 or tile_id >= target_tiles.size():
			continue
		stack[layer] = target_tiles[tile_id]
		changed_tiles += 1
	return changed_tiles


func _set_current_position(map: Variant, x: int, y: int) -> void:
	if not (map is Object):
		return
	for property_name: String in ["focuscharacter", "owcharacter"]:
		var character: Variant = map.get(property_name)
		if character is Object and character.has_method("set_tile_position"):
			character.set_tile_position(Vector2(x, y))
	if map.has_method("explore_tiles_from_tilepos"):
		map.explore_tiles_from_tilepos(Vector2(x, y))


func _has_native_map(resources: Object, map_name: String) -> bool:
	return not _native_map_entry(resources, map_name).is_empty()


func _ensure_native_map(
	resources: Object,
	map_name: String,
	game_global: Object
) -> bool:
	if _has_native_map(resources, map_name):
		return true
	if (
		resources == null
		or game_global == null
		or not resources.has_method("ensure_campaign_map_resource")
	):
		return false
	var campaign_name := str(game_global.get("currentcampaign"))
	if campaign_name.is_empty():
		return false
	resources.call("ensure_campaign_map_resource", campaign_name, map_name)
	return _has_native_map(resources, map_name)


func _native_map_entry(resources: Object, map_name: String) -> Array:
	if resources == null or map_name.is_empty():
		return []
	var maps_book: Variant = resources.get("maps_book")
	if not (maps_book is Dictionary) or not maps_book.has(map_name):
		return []
	var map_entry: Variant = maps_book[map_name]
	return map_entry if map_entry is Array and map_entry.size() >= 9 else []


func _native_script_areas(resources: Object, map_name: String) -> Variant:
	var map_entry := _native_map_entry(resources, map_name)
	if map_entry.is_empty() or not (map_entry[1] is Dictionary):
		return null
	var script_areas: Variant = map_entry[1].get("ScriptRects")
	return script_areas if script_areas is Dictionary else null


func _current_map(game_global: Object, map_name: String) -> Variant:
	if game_global == null or str(game_global.get("currentmap_name")) != map_name:
		return null
	var map: Variant = game_global.get("map")
	return map if map is Object else null


func _has_native_cell(native_map: Variant, x: int, y: int) -> bool:
	return (
		native_map is Array
		and x >= 0
		and x < native_map.size()
		and native_map[x] is Array
		and y >= 0
		and y < native_map[x].size()
		and native_map[x][y] is Array
	)


static func _classic_map_tile_index(
	level_type: String,
	width: int,
	height: int,
	x: int,
	y: int
) -> int:
	return x * height + y if level_type == "land" else y * width + x


func _set_native_land_secret_state(
	map_entry: Array,
	current_map: Variant,
	position: Vector2i,
	revealed: bool
) -> void:
	var seen := 1 if revealed else 0
	if map_entry.size() > 1 and map_entry[1] is Dictionary:
		var metadata: Dictionary = map_entry[1]
		var secrets: Variant = metadata.get("Secrets", [])
		if not (secrets is Array):
			secrets = []
			metadata["Secrets"] = secrets
		var found := false
		for secret_value: Variant in secrets:
			if secret_value is Array and secret_value.size() >= 3 \
					and int(secret_value[0]) == position.x \
					and int(secret_value[1]) == position.y:
				secret_value[2] = seen
				found = true
				break
		if not found:
			secrets.append([position.x, position.y, seen, "", 0.0])
	if current_map == null:
		return
	var map_secrets: Variant = current_map.get("mapsecrets")
	if not (map_secrets is Dictionary):
		return
	if map_secrets.has(position) and map_secrets[position] is Array:
		map_secrets[position][0] = seen
	else:
		map_secrets[position] = [seen, "", 0.0]


func _native_tile_stack(
	map_name: String,
	map_record: Dictionary,
	native_map: Array,
	tile_value: int,
	resources: Object
) -> Dictionary:
	# Capture one native stack per Classic value before applying the first change.
	# Later mutations can then reuse a cell that has itself already been changed.
	if not native_tile_stacks.has(map_name):
		var stacks: Dictionary = {}
		var tiles: Array = map_record.get("tiles", [])
		var width := int(map_record.get("width", 0))
		for index: int in range(tiles.size()):
			var value := int(tiles[index])
			if stacks.has(value):
				continue
			var x := index % width
			var y := index / width
			if _has_native_cell(native_map, x, y):
				stacks[value] = {
					"sourceCell": Vector2i(x, y),
					"stack": native_map[x][y].duplicate(true),
				}
		native_tile_stacks[map_name] = stacks
	var stack: Dictionary = native_tile_stacks[map_name].get(tile_value, {})
	if not stack.is_empty() or not map_name.begins_with("mapd_"):
		return stack
	for tile_value_candidate: Variant in _native_tileset(resources, "ClassicDungeon"):
		if not (tile_value_candidate is Dictionary):
			continue
		if int(tile_value_candidate.get("classicDungeonField", 0)) & 0xffff \
				!= tile_value & 0xffff:
			continue
		stack = {
			"sourceCell": Vector2i(-1, -1),
			"stack": [tile_value_candidate],
		}
		native_tile_stacks[map_name][tile_value] = stack
		break
	return stack


func _area_matches_trigger(
	area_name: String,
	area: Dictionary,
	trigger_id: int,
	stable_id := ""
) -> bool:
	var prefix := "AP%d" % trigger_id
	if area_name == prefix or area_name.begins_with(prefix + "x"):
		return true
	var script_name := str(area.get("scriptToLoad", ""))
	return (
		script_name == prefix
		or script_name.begins_with(prefix + "x")
		or (not stable_id.is_empty() and script_name == stable_id)
	)


func _stable_trigger_id(level_type: String, level_index: int, trigger_id: int) -> String:
	var source := "Data DDD" if level_type == "dungeon" else "Data DD"
	return "%s:%d:%d" % [source, level_index, trigger_id]


func _payload_map_key(payload: Dictionary) -> String:
	return "%s:%d" % [
		str(payload.get("levelType", "")),
		int(payload.get("levelIndex", -1)),
	]


static func _clear_classic_short_bit(value: int, bit: int) -> int:
	var unsigned := value & 0xffff
	var cleared := unsigned & ~(1 << (15 - bit))
	return cleared - 0x10000 if cleared >= 0x8000 else cleared


static func _secret_error(message: String) -> Dictionary:
	return {
		"status": "error",
		"handled": true,
		"revealed": false,
		"message": message,
	}


func _record_replay_result(category: String, result: Dictionary, report: Dictionary) -> void:
	match str(result.get("status", "")):
		"error":
			report["errors"].append({
				"category": category,
				"message": str(result.get("message", "Classic map replay failed")),
			})
		"skipped":
			report["skipped"].append({
				"category": category,
				"message": str(result.get("message", "Classic map replay was skipped")),
			})
		_:
			var applied: Dictionary = report["applied"]
			applied[category] = int(applied.get(category, 0)) + 1


func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func _movement_error(message: String) -> Dictionary:
	return {
		"status": "error",
		"handled": true,
		"allowed": false,
		"message": message,
	}


func _skipped(message: String) -> Dictionary:
	return {"status": "skipped", "message": message}


func _merge_result(base: Dictionary, addition: Dictionary) -> Dictionary:
	for key: Variant in addition:
		base[key] = addition[key]
	return base
