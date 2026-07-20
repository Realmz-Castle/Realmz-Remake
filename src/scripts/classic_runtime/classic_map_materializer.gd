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
const LAND_OVERLAY_TILESET_NAME := "ClassicLandOverlay"
const LAND_OVERLAY_TILE_SIZE := 32
const LAND_OVERLAY_ATLAS_COLUMNS := 16
const DUNGEON_TILESET_NAME := "ClassicDungeon"
const DUNGEON_SOURCE_ATLAS := \
	"res://shared_assets/tiles/The Family Jewels.rsf_PICT_302.png"
const DUNGEON_SOURCE_TILE_SIZE := 16
const DUNGEON_TILE_SIZE := 32
const DUNGEON_ATLAS_COLUMNS := 16
const DUNGEON_SOURCE_X := 576
const DUNGEON_SOURCE_Y := 320
const DUNGEON_VISIBLE_BITS := 7
const DUNGEON_HIDDEN_MASK := 0x0080
const DUNGEON_REVEALED_SECRET_MASK := 0x0040
const DUNGEON_SECRET_DIRECTION_MASK := 0x0f00
const DUNGEON_ACTION_POINT_MASK := 0x1000
const DUNGEON_DOOR_MASK := 0x0006
const DUNGEON_NOTE_MASK := 0x0020
const DUNGEON_WALL_MASK := 0x0001

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

	var pending_maps: Array[Dictionary] = []
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
		pending_maps.append({
			"record": map_record,
			"name": map_name,
			"directory": map_directory,
		})

	var dungeon_tileset := _build_dungeon_tileset_plan(pending_maps, root)
	if str(dungeon_tileset.get("status", "skip")) == "error":
		return _fail(str(dungeon_tileset.get(
			"message",
			"Compiled dungeon tileset could not be generated"
		)))
	var land_overlay_tileset := _build_land_overlay_tileset_plan(bundle, pending_maps, root)
	if str(land_overlay_tileset.get("status", "skip")) == "error":
		return _fail(str(land_overlay_tileset.get(
			"message",
			"Classic special land tileset could not be generated"
		)))

	var plans: Array[Dictionary] = []
	for pending_map: Dictionary in pending_maps:
		var plan := _build_plan(
			bundle,
			root,
			pending_map["record"],
			pending_map["name"],
			pending_map["directory"],
			dungeon_tileset,
			land_overlay_tileset
		)
		if plan.is_empty():
			return {"status": "error", "message": last_error}
		plans.append(plan)

	if str(dungeon_tileset.get("status", "skip")) == "ok":
		var tileset_error := _write_generated_tileset(dungeon_tileset)
		if tileset_error != OK:
			return _fail(
				"Could not write native dungeon tileset: %s" % error_string(tileset_error)
			)
	if str(land_overlay_tileset.get("status", "skip")) == "ok":
		var overlay_error := _write_generated_tileset(land_overlay_tileset)
		if overlay_error != OK:
			return _fail(
				"Could not write native special land tileset: %s" % error_string(
					overlay_error
				)
			)

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
	map_directory: String,
	dungeon_tileset: Dictionary,
	land_overlay_tileset: Dictionary
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

	var tileset_result := _resolve_tileset(
		bundle,
		campaign_directory,
		map_record,
		dungeon_tileset
	)
	if str(tileset_result.get("status", "")) != "ok":
		return _plan_fail(str(tileset_result.get("message", "Compiled map tileset is unavailable")))
	var native_tiles: Array = []
	var overlay_tiles: Array = []
	var has_land_overlays := false
	var tile_capacity := int(tileset_result.get("tileCapacity", 0))
	var dungeon_lookup: Variant = tileset_result.get("tileLookup")
	for tile_index: int in range(tiles.size()):
		var classic_tile := int(tiles[tile_index])
		var native_tile := 0
		if dungeon_lookup is Dictionary:
			native_tile = int(dungeon_lookup.get(classic_tile & 0xffff, 0))
			if native_tile <= 0:
				return _plan_fail(
					"Compiled map %s dungeon field %d has no generated native tile" % [
						map_name,
						classic_tile,
					]
				)
		elif classic_tile < 0:
			var overlay_lookup: Variant = land_overlay_tileset.get("tileLookup", {})
			if not (overlay_lookup is Dictionary) or not overlay_lookup.has(classic_tile):
				return _plan_fail(
					"Compiled map %s special tile %d at cell %d has no generated native overlay" % [
						map_name,
						classic_tile,
						tile_index,
					]
				)
			native_tile = int(tileset_result["baseTile"])
			overlay_tiles.append(
				tile_capacity + int(overlay_lookup[classic_tile])
			)
			has_land_overlays = true
		else:
			native_tile = _normalize_atlas_tile(
				classic_tile,
				int(tileset_result["baseTile"])
			)
		if classic_tile >= 0 or dungeon_lookup is Dictionary:
			overlay_tiles.append(0)
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
	var layers: Array = [{"chunks": [{"data": native_tiles}]}]
	var tilesets: Array = [{
		"firstgid": 1,
		"source": "%s.json" % tileset_result["name"],
	}]
	if has_land_overlays:
		layers.append({"chunks": [{"data": overlay_tiles}]})
		tilesets.append({
			"firstgid": tile_capacity + 1,
			"source": "%s.json" % LAND_OVERLAY_TILESET_NAME,
		})
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
				"layers": layers,
				"tilesets": tilesets,
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
	map_record: Dictionary,
	dungeon_tileset: Dictionary
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
	elif mode == "dungeon-top-down":
		if str(dungeon_tileset.get("status", "")) != "ok":
			return {
				"status": "error",
				"message": "Compiled dungeon tileset plan is unavailable",
			}
		return {
			"status": "ok",
			"name": DUNGEON_TILESET_NAME,
			"baseTile": 1,
			"tileCapacity": int(dungeon_tileset.get("tileCapacity", 0)),
			"tileLookup": dungeon_tileset.get("tileLookup", {}),
		}
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


func _build_land_overlay_tileset_plan(
	bundle: Object,
	pending_maps: Array[Dictionary],
	campaign_directory: String
) -> Dictionary:
	var raw_values: Dictionary = {}
	for pending_map: Dictionary in pending_maps:
		var map_record: Dictionary = pending_map["record"]
		if str(map_record.get("levelType", "")) != "land":
			continue
		var tiles: Variant = map_record.get("tiles")
		if not (tiles is Array):
			continue
		for tile_value: Variant in tiles:
			var raw_value := int(tile_value)
			if raw_value < 0:
				raw_values[raw_value] = true
	if raw_values.is_empty():
		return {"status": "skip"}

	var catalog: Variant = bundle.documents.get("assets", {}).get("catalog", {})
	var special_tiles: Variant = catalog.get("specialLandTiles", []) \
		if catalog is Dictionary else []
	var records_by_id: Dictionary = {}
	if special_tiles is Array:
		for record_value: Variant in special_tiles:
			if record_value is Dictionary:
				records_by_id[int(record_value.get("resourceId", 0))] = record_value

	var field_values: Array = raw_values.keys()
	field_values.sort()
	var images: Dictionary = {}
	var resource_ids: Dictionary = {}
	for field_value_variant: Variant in field_values:
		var field_value := int(field_value_variant)
		var resource_id := _special_land_resource_id(field_value)
		if not records_by_id.has(resource_id):
			return {
				"status": "error",
				"message": (
					"Compiled special land tile %d resolves to cicn %d, " +
					"but assets.catalog.specialLandTiles has no matching record"
				) % [field_value, resource_id],
			}
		var record: Dictionary = records_by_id[resource_id]
		var runtime_media: Variant = record.get("runtimeMedia")
		if not (runtime_media is Dictionary):
			return {
				"status": "error",
				"message": (
					"Classic special land tile %d (cicn %d) requires a decoded " +
					"32 x 32 runtimeMedia image"
				) % [field_value, resource_id],
			}
		var relative_path := str(runtime_media.get("path", ""))
		if not _is_safe_campaign_path(relative_path):
			return {
				"status": "error",
				"message": "Classic special land tile %d has an unsafe runtimeMedia path" % (
					field_value
				),
			}
		var image_path := campaign_directory.path_join(relative_path)
		if not FileAccess.file_exists(image_path):
			return {
				"status": "error",
				"message": "Classic special land tile %d is missing runtimeMedia %s" % [
					field_value,
					relative_path,
				],
			}
		var image := Image.load_from_file(image_path)
		if image == null or image.is_empty():
			return {
				"status": "error",
				"message": "Classic special land tile %d runtimeMedia is not a readable image" % (
					field_value
				),
			}
		if image.get_size() != Vector2i(LAND_OVERLAY_TILE_SIZE, LAND_OVERLAY_TILE_SIZE):
			return {
				"status": "error",
				"message": (
					"Classic special land tile %d runtimeMedia is %d x %d; " +
					"Remake requires the source-backed 32 x 32 overlay"
				) % [field_value, image.get_width(), image.get_height()],
			}
		image.convert(Image.FORMAT_RGBA8)
		images[field_value] = image
		resource_ids[field_value] = resource_id

	var columns := mini(LAND_OVERLAY_ATLAS_COLUMNS, field_values.size())
	var rows := ceili(float(field_values.size()) / float(columns))
	var atlas := Image.create(
		columns * LAND_OVERLAY_TILE_SIZE,
		rows * LAND_OVERLAY_TILE_SIZE,
		false,
		Image.FORMAT_RGBA8
	)
	atlas.fill(Color(0, 0, 0, 0))
	var lookup: Dictionary = {}
	var tiles: Array = []
	var templates: Dictionary = {}
	for tile_index: int in range(field_values.size()):
		var field_value := int(field_values[tile_index])
		var tile_name := "classic_land_overlay_%s" % str(field_value).replace("-", "neg_")
		var tile_image: Image = images[field_value]
		atlas.blit_rect(
			tile_image,
			Rect2i(Vector2i.ZERO, tile_image.get_size()),
			Vector2i(
				(tile_index % columns) * LAND_OVERLAY_TILE_SIZE,
				(tile_index / columns) * LAND_OVERLAY_TILE_SIZE
			)
		)
		lookup[field_value] = tile_index + 1
		tiles.append({
			"id": tile_index,
			"properties": [
				{"name": "name", "type": "string", "value": tile_name},
				{"name": "template", "type": "string", "value": tile_name},
			],
		})
		templates[tile_name] = _land_overlay_template(
			bundle,
			field_value,
			int(resource_ids[field_value])
		)

	return {
		"status": "ok",
		"name": LAND_OVERLAY_TILESET_NAME,
		"directory": campaign_directory.path_join("Tilesets").path_join(
			LAND_OVERLAY_TILESET_NAME
		),
		"image": atlas,
		"tileCapacity": field_values.size(),
		"tileLookup": lookup,
		"tileset": {
			"columns": columns,
			"image": "%s.png" % LAND_OVERLAY_TILESET_NAME,
			"imageheight": rows * LAND_OVERLAY_TILE_SIZE,
			"imagewidth": columns * LAND_OVERLAY_TILE_SIZE,
			"margin": 0,
			"name": LAND_OVERLAY_TILESET_NAME,
			"spacing": 0,
			"tilecount": field_values.size(),
			"tiledversion": "1.11.2",
			"tileheight": LAND_OVERLAY_TILE_SIZE,
			"tiles": tiles,
			"tilewidth": LAND_OVERLAY_TILE_SIZE,
			"type": "tileset",
			"version": "1.10",
		},
		"templates": templates,
	}


func _special_land_resource_id(field_value: int) -> int:
	# Realmz folds three 1000-wide land-field bands onto the same signed cicn IDs.
	var resource_id := field_value
	for _band: int in range(3):
		if resource_id > -1000:
			break
		resource_id += 1000
	return resource_id


func _land_overlay_template(bundle: Object, field_value: int, resource_id: int) -> Dictionary:
	var blocks_movement := false
	# Data Solids only governs the first negative land-field band.
	if field_value >= -998 and field_value <= -1:
		var tile_attributes: Variant = bundle.documents.get("maps", {}).get(
			"tileAttributes",
			[]
		)
		if tile_attributes is Array:
			for attribute_value: Variant in tile_attributes:
				if not (attribute_value is Dictionary):
					continue
				var attribute: Dictionary = attribute_value
				if (
					str(attribute.get("sourceKind", "")) == "data-solids"
					and int(attribute.get("tile", -1)) == abs(field_value)
				):
					blocks_movement = int(attribute.get("solidType", 0)) != 0
					break
	return {
		"time": 0,
		"wall": int(blocks_movement),
		"swall": int(blocks_movement),
		"blkproj": 0,
		"blkview": 0,
		"water": 0,
		"dock": 0,
		"sound": [],
		"classicLandField": field_value,
		"classicResourceId": resource_id,
	}


func _write_generated_tileset(plan: Dictionary) -> Error:
	var directory := str(plan.get("directory", ""))
	var make_error := DirAccess.make_dir_recursive_absolute(directory)
	if make_error != OK:
		return make_error
	var image: Image = plan["image"]
	var image_error := image.save_png(directory.path_join("%s.png" % plan["name"]))
	if image_error != OK:
		return image_error
	for file_data: Dictionary in [
		{"name": "%s.json" % plan["name"], "value": plan["tileset"]},
		{"name": "tile_templates.json", "value": plan["templates"]},
	]:
		var file := FileAccess.open(directory.path_join(file_data["name"]), FileAccess.WRITE)
		if file == null:
			return FileAccess.get_open_error()
		file.store_string(JSON.stringify(file_data["value"], "  ") + "\n")
		file.close()
	return OK


func _build_dungeon_tileset_plan(
	pending_maps: Array[Dictionary],
	campaign_directory: String
) -> Dictionary:
	var fields: Dictionary = {}
	for pending_map: Dictionary in pending_maps:
		var map_record: Dictionary = pending_map["record"]
		if str(map_record.get("levelType", "")) != "dungeon":
			continue
		var tiles: Variant = map_record.get("tiles")
		var width := int(map_record.get("width", 0))
		var height := int(map_record.get("height", 0))
		if not (tiles is Array) or width <= 0 or height <= 0 or tiles.size() != width * height:
			return {
				"status": "error",
				"message": "Compiled map %s needs %d dungeon field values before Remake can generate it" % [
					pending_map["name"],
					maxi(0, width * height),
				],
			}
		for tile_value: Variant in tiles:
			var field := int(tile_value) & 0xffff
			if field & DUNGEON_SECRET_DIRECTION_MASK:
				# Runtime discovery sets this bit on the field. Generate that visual
				# state even when it is not present in the compiler's initial tile array.
				fields[field | DUNGEON_REVEALED_SECRET_MASK] = true
			fields[field] = true
	if fields.is_empty():
		return {"status": "skip"}

	# Data DL cells are bitfields. One tile per field value keeps the native atlas
	# compact while retaining combinations that share the same visible sprites.
	var source := Image.load_from_file(ProjectSettings.globalize_path(DUNGEON_SOURCE_ATLAS))
	if source == null or source.is_empty():
		return {
			"status": "error",
			"message": "Realmz PICT 302 dungeon atlas is unavailable",
		}
	source.convert(Image.FORMAT_RGBA8)
	var field_values: Array = fields.keys()
	field_values.sort()
	var columns := mini(DUNGEON_ATLAS_COLUMNS, field_values.size())
	var rows := ceili(float(field_values.size()) / float(columns))
	var atlas := Image.create(
		columns * DUNGEON_TILE_SIZE,
		rows * DUNGEON_TILE_SIZE,
		false,
		Image.FORMAT_RGBA8
	)
	atlas.fill(Color(0, 0, 0, 0))
	var lookup: Dictionary = {}
	var tiles: Array = []
	var templates: Dictionary = {}
	for tile_index: int in range(field_values.size()):
		var field := int(field_values[tile_index])
		var tile_name := "classic_dungeon_%04x" % field
		var tile_image := _render_dungeon_tile(source, field)
		atlas.blit_rect(
			tile_image,
			Rect2i(Vector2i.ZERO, tile_image.get_size()),
			Vector2i(
				(tile_index % columns) * DUNGEON_TILE_SIZE,
				(tile_index / columns) * DUNGEON_TILE_SIZE
			)
		)
		lookup[field] = tile_index + 1
		tiles.append({
			"id": tile_index,
			"properties": [
				{"name": "name", "type": "string", "value": tile_name},
				{"name": "template", "type": "string", "value": tile_name},
			],
		})
		templates[tile_name] = _dungeon_tile_template(field)

	return {
		"status": "ok",
		"name": DUNGEON_TILESET_NAME,
		"directory": campaign_directory.path_join("Tilesets").path_join(
			DUNGEON_TILESET_NAME
		),
		"image": atlas,
		"tileCapacity": field_values.size(),
		"tileLookup": lookup,
		"tileset": {
			"columns": columns,
			"image": "%s.png" % DUNGEON_TILESET_NAME,
			"imageheight": rows * DUNGEON_TILE_SIZE,
			"imagewidth": columns * DUNGEON_TILE_SIZE,
			"margin": 0,
			"name": DUNGEON_TILESET_NAME,
			"spacing": 0,
			"tilecount": field_values.size(),
			"tiledversion": "1.11.2",
			"tileheight": DUNGEON_TILE_SIZE,
			"tiles": tiles,
			"tilewidth": DUNGEON_TILE_SIZE,
			"type": "tileset",
			"version": "1.10",
		},
		"templates": templates,
	}


func _render_dungeon_tile(source: Image, field: int) -> Image:
	# Realmz layers tiny sprites 0 through 6 over tiny[15]. Bit 0x80 suppresses
	# the whole overhead cell outside the editor.
	var base_rect := Rect2i(
		DUNGEON_SOURCE_X + 3 * DUNGEON_SOURCE_TILE_SIZE,
		DUNGEON_SOURCE_Y + 3 * DUNGEON_SOURCE_TILE_SIZE,
		DUNGEON_SOURCE_TILE_SIZE,
		DUNGEON_SOURCE_TILE_SIZE
	)
	var tile := source.get_region(base_rect)
	tile.convert(Image.FORMAT_RGBA8)
	if not (field & DUNGEON_HIDDEN_MASK):
		for sprite_index: int in range(DUNGEON_VISIBLE_BITS):
			if not (field & (1 << sprite_index)):
				continue
			var sprite_rect := Rect2i(
				DUNGEON_SOURCE_X + (sprite_index % 4) * DUNGEON_SOURCE_TILE_SIZE,
				DUNGEON_SOURCE_Y + (sprite_index / 4) * DUNGEON_SOURCE_TILE_SIZE,
				DUNGEON_SOURCE_TILE_SIZE,
				DUNGEON_SOURCE_TILE_SIZE
			)
			var sprite := source.get_region(sprite_rect)
			for y: int in range(DUNGEON_SOURCE_TILE_SIZE):
				for x: int in range(DUNGEON_SOURCE_TILE_SIZE):
					var color := sprite.get_pixel(x, y)
					if color.r <= 0.96 or color.g <= 0.96 or color.b <= 0.96:
						tile.set_pixel(x, y, color)
	tile.resize(DUNGEON_TILE_SIZE, DUNGEON_TILE_SIZE, Image.INTERPOLATE_NEAREST)
	return tile


func _dungeon_tile_template(field: int) -> Dictionary:
	# Classic's hard-wall check admits doors, note cells, and Action Point cells.
	var passable_override := field & (
		DUNGEON_DOOR_MASK | DUNGEON_NOTE_MASK | DUNGEON_ACTION_POINT_MASK
	)
	var blocks_movement := bool(field & DUNGEON_WALL_MASK) and not bool(passable_override)
	return {
		"time": 999 if blocks_movement else 5,
		"wall": int(blocks_movement),
		"swall": int(blocks_movement),
		"blkproj": int(blocks_movement),
		"blkview": int(blocks_movement),
		"water": 0,
		"dock": 0,
		"sound": [],
		"classicDungeonField": field - 0x10000 if field >= 0x8000 else field,
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


func _is_safe_campaign_path(value: String) -> bool:
	var normalized := value.strip_edges().replace("\\", "/")
	if normalized.is_empty() or normalized.is_absolute_path() or normalized.contains(":"):
		return false
	for component: String in normalized.split("/"):
		if component.is_empty() or component in [".", ".."]:
			return false
	return true


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
