class_name ClassicMapMaterializer
extends RefCounted

const MapBridgeScript = preload("res://scripts/classic_runtime/classic_map_bridge.gd")
const REQUIRED_MAP_FILES := [
	"map_info.json",
	"map_scriptareas.json",
	"map_scripts.gd",
	"map_things.json",
]
const MAP_SCRIPT_SOURCE := "static func _on_map_load(_map) -> void:\n\tpass\n"

var last_error := ""


func materialize(bundle: Object, campaign_directory: String) -> Dictionary:
	last_error = ""
	if bundle == null:
		return _fail("Classic campaign bundle is unavailable")
	var root := campaign_directory.strip_edges().replace("\\", "/").trim_suffix("/")
	if root.is_empty() or not DirAccess.dir_exists_absolute(root):
		return _fail("Classic campaign directory is unavailable")
	var maps_document: Variant = bundle.documents.get("maps", {})
	if not (maps_document is Dictionary):
		return _fail("Classic maps document is unavailable")
	var maps: Variant = maps_document.get("maps", [])
	if not (maps is Array) or maps.is_empty():
		return _fail("Classic maps document does not contain any maps")

	var plans: Array[Dictionary] = []
	var skipped: Array[String] = []
	for map_value: Variant in maps:
		if not (map_value is Dictionary):
			return _fail("Classic maps document contains a malformed map")
		var map_record: Dictionary = map_value
		var map_name := _native_map_name(map_record)
		if map_name.is_empty():
			return _fail("Compiled map has an invalid level identity")
		var map_directory := root.path_join("Maps").path_join(map_name)
		if _has_complete_native_map(map_directory):
			skipped.append(map_name)
			continue
		var plan := _build_plan(bundle, root, map_record, map_name, map_directory)
		if plan.is_empty():
			return {"status": "error", "message": last_error}
		plans.append(plan)

	for plan: Dictionary in plans:
		var map_directory: String = plan["directory"]
		var make_error := DirAccess.make_dir_recursive_absolute(map_directory)
		if make_error != OK:
			return _fail(
				"Could not create native map directory %s: %s" % [
					plan["name"],
					error_string(make_error),
				]
			)
		for file_name: String in REQUIRED_MAP_FILES:
			var contents := MAP_SCRIPT_SOURCE if file_name == "map_scripts.gd" \
				else JSON.stringify(plan["files"][file_name], "  ") + "\n"
			var file := FileAccess.open(map_directory.path_join(file_name), FileAccess.WRITE)
			if file == null:
				return _fail(
					"Could not write native map %s file %s" % [plan["name"], file_name]
				)
			file.store_string(contents)
			file.close()

	return {
		"status": "ok",
		"generatedMaps": plans.map(func(plan: Dictionary) -> String: return plan["name"]),
		"preservedMaps": skipped,
	}


func _build_plan(
	bundle: Object,
	campaign_directory: String,
	map_record: Dictionary,
	map_name: String,
	map_directory: String
) -> Dictionary:
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	if width <= 0 or height <= 0:
		return _plan_fail("Compiled map %s has invalid dimensions" % map_name)
	var tiles: Variant = map_record.get("tiles")
	if not (tiles is Array) or tiles.size() != width * height:
		return _plan_fail(
			"Compiled map %s needs %d tile values before Remake can generate it" % [
				map_name,
				width * height,
			]
		)

	var tileset_result := _resolve_tileset(bundle, campaign_directory, map_record)
	if str(tileset_result.get("status", "")) != "ok":
		return _plan_fail(str(tileset_result.get("message", "Compiled map tileset is unavailable")))
	var native_tiles: Array = []
	var tile_capacity := int(tileset_result.get("tileCapacity", 0))
	for tile_index: int in range(tiles.size()):
		var classic_tile := int(tiles[tile_index])
		if classic_tile < 0:
			return _plan_fail(
				"Compiled map %s uses special tile %d at cell %d; a decoded native overlay is required" % [
					map_name,
					classic_tile,
					tile_index,
				]
			)
		var native_tile := _normalize_atlas_tile(classic_tile, int(tileset_result["baseTile"]))
		if native_tile > tile_capacity:
			return _plan_fail(
				"Compiled map %s tile %d needs atlas slot %d, but %s provides only %d slots" % [
					map_name,
					classic_tile,
					native_tile,
					tileset_result["name"],
					tile_capacity,
				]
			)
		native_tiles.append(native_tile)

	var level_type := str(map_record.get("levelType", ""))
	var level_index := int(map_record.get("index", -1))
	var random_level: Dictionary = bundle.get_random_level(level_type, level_index)
	var script_areas := _script_areas(bundle, level_type, level_index, random_level)
	return {
		"name": map_name,
		"directory": map_directory,
		"files": {
			"map_info.json": {
				"name": map_name,
				"map_type": "Outdoor" if level_type == "land" else "Indoor",
				"music_type": "Forest" if level_type == "land" else "Indoor",
				"outdoor_riding": level_type == "land",
				"darkness_level": 0 if bool(random_level.get("isDark", false)) else 7,
				"display_explored_only": int(bool(random_level.get("useLos", false))),
			},
			"map_scriptareas.json": script_areas,
			"map_scripts.gd": MAP_SCRIPT_SOURCE,
			"map_things.json": {
				"height": height,
				"width": width,
				"layers": [{"chunks": [{"data": native_tiles}]}],
				"tilesets": [{
					"firstgid": 1,
					"source": "%s.json" % tileset_result["name"],
				}],
			},
		},
	}


func _script_areas(
	bundle: Object,
	level_type: String,
	level_index: int,
	random_level: Dictionary
) -> Dictionary:
	var areas: Dictionary = {}
	var triggers: Variant = bundle.documents.get("scripts", {}).get("triggers", [])
	if triggers is Array:
		for trigger_value: Variant in triggers:
			if not (trigger_value is Dictionary):
				continue
			var trigger: Dictionary = trigger_value
			if (
				not bool(trigger.get("active", false))
				or str(trigger.get("levelType", "")) != level_type
				or int(trigger.get("levelIndex", -1)) != level_index
			):
				continue
			var coordinate: Variant = trigger.get("coordinate")
			if not (coordinate is Dictionary):
				continue
			var x := int(coordinate.get("x", -1))
			var y := int(coordinate.get("y", -1))
			if x < 0 or y < 0:
				continue
			var record_index := int(trigger.get("recordIndex", -1))
			areas["AP%dx%dy%d" % [record_index, x, y]] = {
				"scriptRectangle": [[x, y], [x, y]],
				"scriptToLoad": str(trigger.get("id", "")),
				"chance": clampf(float(trigger.get("percent", 100)) / 100.0, 0.0, 1.0),
			}

	var rectangles: Variant = random_level.get("rects", [])
	if rectangles is Array:
		for rectangle_value: Variant in rectangles:
			if not (rectangle_value is Dictionary):
				continue
			var rectangle: Dictionary = rectangle_value
			var rect_index := int(rectangle.get("rectIndex", -1))
			if rect_index < 0:
				continue
			var prefix := "LRR" if level_type == "land" else "DRR"
			var battle_range: Variant = rectangle.get("battleRange", [])
			var area := {
				"scriptRectangle": [
					[int(rectangle.get("left", 0)), int(rectangle.get("top", 0))],
					[int(rectangle.get("right", 0)), int(rectangle.get("bottom", 0))],
				],
				"chance": maxf(0.0, float(rectangle.get("percent", 0)) / 10000.0),
				"scriptToLoad": [],
			}
			if battle_range is Array and battle_range.size() >= 2:
				area["RR_Battle"] = {
					"battle_range": [int(battle_range[0]), int(battle_range[1])],
					"option_chance": int(rectangle.get("option", 0)),
					"sfx_id": int(rectangle.get("sound", 0)),
					"text": _message_text(bundle, int(rectangle.get("text", 0))),
				}
			areas["%s%d.%d" % [prefix, level_index, rect_index]] = area
	return {"ScriptRects": areas, "Paths": [], "Secrets": []}


func _resolve_tileset(
	bundle: Object,
	campaign_directory: String,
	map_record: Dictionary
) -> Dictionary:
	var render: Variant = map_record.get("render", {})
	if not (render is Dictionary):
		return {"status": "error", "message": "Compiled map is missing render metadata"}
	var mode := str(render.get("mode", ""))
	var tileset_name := ""
	var base_tile := 1
	var tileset_path := ""
	if mode == "outdoor-landlook":
		var landlook := int(render.get("landlook", -1))
		tileset_name = str(MapBridgeScript.STOCK_LANDLOOK_TILESETS.get(landlook, ""))
		base_tile = _catalog_base_tile(bundle, str(render.get("tilesetId", "")), 156)
		if tileset_name.is_empty():
			tileset_name = str(render.get("tilesetId", "")).strip_edges()
			if not _is_safe_component(tileset_name):
				return {
					"status": "error",
					"message": "Classic landlook %d has no safe native tileset identity" % landlook,
				}
			var tileset_directory := campaign_directory.path_join("Tilesets").path_join(
				tileset_name
			)
			for file_name: String in [
				"%s.json" % tileset_name,
				"%s.png" % tileset_name,
				"tile_templates.json",
			]:
				if not FileAccess.file_exists(tileset_directory.path_join(file_name)):
					return {
						"status": "error",
						"message": (
							"Classic tileset %s requires decoded native file " +
							"Tilesets/%s/%s"
						) % [tileset_name, tileset_name, file_name],
					}
			tileset_path = tileset_directory.path_join("%s.json" % tileset_name)
	else:
		return {
			"status": "error",
			"message": "Compiled map render mode '%s' is not materialized yet" % mode,
		}

	if tileset_path.is_empty():
		tileset_path = "res://shared_assets/tiles/%s/%s.json" % [tileset_name, tileset_name]
	if not FileAccess.file_exists(tileset_path):
		return {
			"status": "error",
			"message": "Native tileset %s is unavailable" % tileset_name,
		}
	var tileset_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(tileset_path))
	if not (tileset_value is Dictionary) or int(tileset_value.get("tilecount", 0)) <= 0:
		return {
			"status": "error",
			"message": "Native tileset %s has invalid tile metadata" % tileset_name,
		}
	return {
		"status": "ok",
		"name": tileset_name,
		"baseTile": base_tile,
		"tileCapacity": int(tileset_value["tilecount"]),
	}


func _catalog_base_tile(bundle: Object, tileset_id: String, fallback: int) -> int:
	var catalog: Variant = bundle.documents.get("assets", {}).get("catalog", {})
	if not (catalog is Dictionary):
		return fallback
	var tilesets: Variant = catalog.get("tilesets", [])
	if not (tilesets is Array):
		return fallback
	for tileset_value: Variant in tilesets:
		if (
			tileset_value is Dictionary
			and str(tileset_value.get("id", "")) == tileset_id
		):
			return int(tileset_value.get("baseTile", fallback))
	return fallback


func _normalize_atlas_tile(value: int, base_tile: int) -> int:
	# Classic combines high-bit flags and 1000-offsets with a one-based tile ID.
	# Remake's Tiled input uses that normalized ID directly as its GID.
	var tile := value
	var fallback_tile := base_tile if base_tile > 0 else 1
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
	return maxi(1, tile)


func _clear_classic_short_bit(value: int, bit: int) -> int:
	var unsigned := value & 0xffff
	var cleared := unsigned & ~(1 << (15 - bit))
	return cleared - 0x10000 if cleared >= 0x8000 else cleared


func _native_map_name(map_record: Dictionary) -> String:
	var level_index := int(map_record.get("index", -1))
	if level_index < 0:
		return ""
	match str(map_record.get("levelType", "")):
		"land":
			return "map_%d" % level_index
		"dungeon":
			return "mapd_%d" % level_index
	return ""


func _is_safe_component(value: String) -> bool:
	return (
		not value.is_empty()
		and value not in [".", ".."]
		and not value.contains("/")
		and not value.contains("\\")
		and not value.contains(":")
	)


func _has_complete_native_map(map_directory: String) -> bool:
	for file_name: String in REQUIRED_MAP_FILES:
		if not FileAccess.file_exists(map_directory.path_join(file_name)):
			return false
	return true


func _message_text(bundle: Object, message_id: int) -> String:
	if message_id == 0:
		return ""
	var message: Dictionary = bundle.get_message(message_id)
	return str(message.get("text", ""))


func _plan_fail(message: String) -> Dictionary:
	last_error = message
	return {}


func _fail(message: String) -> Dictionary:
	last_error = message
	return {"status": "error", "message": message}
