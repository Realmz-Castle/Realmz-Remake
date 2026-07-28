class_name ClassicMapMaterializer
extends RefCounted

const MapBridgeScript = preload("res://scripts/classic_runtime/classic_map_bridge.gd")
const RandomRectangleScript = preload(
	"res://scripts/classic_runtime/classic_random_rectangle.gd"
)
const DistributionJsonScript = preload(
	"res://scripts/classic_runtime/classic_distribution_json.gd"
)
const QuickDrawImageDecoderScript = preload(
	"res://scripts/classic_runtime/classic_quickdraw_image_decoder.gd"
)
const REQUIRED_MAP_FILES := [
	"map_info.json",
	"map_scriptareas.json",
	"map_things.json",
]
const LAND_OVERLAY_TILESET_NAME := "ClassicLandOverlay"
const LAND_OVERLAY_TILE_SIZE := 32
const LAND_OVERLAY_ATLAS_COLUMNS := 16
const CUSTOM_LAND_TILE_SIZE := 32
const CUSTOM_LAND_COLUMNS := 20
const CUSTOM_LAND_ROWS := 10
const CUSTOM_LAND_TILE_COUNT := CUSTOM_LAND_COLUMNS * CUSTOM_LAND_ROWS
const STOCK_LANDLOOK_ATLASES := {
	0: "res://shared_assets/tiles/The Family Jewels.rsf_PICT_300.png",
	3: "res://shared_assets/tiles/The Family Jewels.rsf_PICT_303.png",
	4: "res://shared_assets/tiles/The Family Jewels.rsf_PICT_304.png",
	5: "res://shared_assets/tiles/The Family Jewels.rsf_PICT_305.png",
	9: "res://shared_assets/tiles/The Family Jewels.rsf_PICT_309.png",
	10: "res://shared_assets/tiles/The Family Jewels.rsf_PICT_310.png",
}
const STOCK_LANDLOOK_ENVIRONMENTS := {
	0: {"mapType": "Outdoor", "musicType": "Forest", "outdoorRiding": true},
	3: {"mapType": "Outdoor", "musicType": "Cave", "outdoorRiding": true},
	4: {"mapType": "Indoor", "musicType": "Indoor", "outdoorRiding": false},
	5: {"mapType": "Outdoor", "musicType": "Desert", "outdoorRiding": true},
	9: {"mapType": "Outdoor", "musicType": "Swamp", "outdoorRiding": true},
	10: {"mapType": "Outdoor", "musicType": "Snow", "outdoorRiding": true},
}
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
	var stock_land_tilesets := _build_stock_land_tileset_plans(bundle, pending_maps, root)
	if str(stock_land_tilesets.get("status", "skip")) == "error":
		return _fail(str(stock_land_tilesets.get(
			"message",
			"Classic stock land tileset could not be generated"
		)))
	var custom_land_tilesets := _build_custom_land_tileset_plans(bundle, pending_maps, root)
	if str(custom_land_tilesets.get("status", "skip")) == "error":
		return _fail(str(custom_land_tilesets.get(
			"message",
			"Classic custom land tileset could not be generated"
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
			land_overlay_tileset,
			stock_land_tilesets,
			custom_land_tilesets
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
	if str(stock_land_tilesets.get("status", "skip")) == "ok":
		var stock_plans: Dictionary = stock_land_tilesets.get("plans", {})
		var stock_ids: Array = stock_plans.keys()
		stock_ids.sort()
		for stock_id: Variant in stock_ids:
			var stock_error := _write_generated_tileset(stock_plans[stock_id])
			if stock_error != OK:
				return _fail(
					"Could not write Classic stock land tileset %s: %s" % [
						stock_id,
						error_string(stock_error),
					]
				)
	if str(custom_land_tilesets.get("status", "skip")) == "ok":
		var custom_plans: Dictionary = custom_land_tilesets.get("plans", {})
		var custom_ids: Array = custom_plans.keys()
		custom_ids.sort()
		for custom_id: Variant in custom_ids:
			var custom_error := _write_generated_tileset(custom_plans[custom_id])
			if custom_error != OK:
				return _fail(
					"Could not write native custom land tileset %s: %s" % [
						custom_id,
						error_string(custom_error),
					]
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
			var contents := DistributionJsonScript.stringify(plan["files"][file_name])
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
	land_overlay_tileset: Dictionary,
	stock_land_tilesets: Dictionary,
	custom_land_tilesets: Dictionary
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
		dungeon_tileset,
		stock_land_tilesets,
		custom_land_tilesets
	)
	if str(tileset_result.get("status", "")) != "ok":
		return _plan_fail(str(tileset_result.get("message", "Compiled map tileset is unavailable")))
	var native_tiles: Array = []
	var overlay_tiles: Array = []
	var has_land_overlays := false
	var level_type := str(map_record.get("levelType", ""))
	var tile_capacity := int(tileset_result.get("tileCapacity", 0))
	var dungeon_lookup: Variant = tileset_result.get("tileLookup")
	var map_bridge = MapBridgeScript.new()
	map_bridge.configure(bundle)
	var boat_plan := map_bridge.classic_boat_plan(map_record, str(tileset_result["name"]))
	if str(boat_plan.get("status", "")) == "error":
		return _plan_fail(str(boat_plan.get("message", "Classic boat placement is invalid")))
	var boat_terrain: Dictionary = boat_plan.get("terrainByCell", {})
	for y: int in range(height):
		for x: int in range(width):
			# Providence preserves Realmz's column-major land fields. Remake's map
			# loader consumes Tiled's row-major order; dungeon fields are already row-major.
			var source_index := y * width + x
			if level_type == "land":
				source_index = x * height + y
			var classic_tile := int(tiles[source_index])
			if boat_terrain.has(source_index):
				classic_tile = int(boat_terrain[source_index])
			var native_tile := 0
			var overlay_tile := 0
			var overlay_icon_id: Variant = MapBridgeScript.land_overlay_icon_id(classic_tile)
			if dungeon_lookup is Dictionary:
				native_tile = int(dungeon_lookup.get(classic_tile & 0xffff, 0))
				if native_tile <= 0:
					return _plan_fail(
						"Compiled map %s dungeon field %d has no generated native tile" % [
							map_name,
							classic_tile,
						]
					)
			elif overlay_icon_id != null:
				var overlay_lookup: Variant = land_overlay_tileset.get("tileLookup", {})
				native_tile = int(tileset_result["baseTile"])
				if overlay_lookup is Dictionary and overlay_lookup.has(int(overlay_icon_id)):
					overlay_tile = tile_capacity + int(overlay_lookup[int(overlay_icon_id)])
					has_land_overlays = true
			else:
				native_tile = _normalize_atlas_tile(
					classic_tile,
					int(tileset_result["baseTile"])
				)
			overlay_tiles.append(overlay_tile)
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

	var level_index := int(map_record.get("index", -1))
	var random_level: Dictionary = bundle.get_random_level(level_type, level_index)
	var environment := _map_environment(map_record)
	var script_areas := _script_areas(bundle, map_record, random_level)
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
				"map_type": environment["mapType"],
				"music_type": environment["musicType"],
				"outdoor_riding": environment["outdoorRiding"],
				"darkness_level": MapBridgeScript.native_darkness(
					bool(random_level.get("isDark", false))
				),
				"display_explored_only": int(bool(random_level.get("useLos", false))),
				"classic_boats": boat_plan.get("placements", {}),
			},
			"map_scriptareas.json": script_areas,
			"map_things.json": {
				"height": height,
				"width": width,
				"layers": layers,
				"tilesets": tilesets,
			},
		},
	}


func _map_environment(map_record: Dictionary) -> Dictionary:
	if str(map_record.get("levelType", "")) == "dungeon":
		return {"mapType": "Indoor", "musicType": "Dungeon", "outdoorRiding": false}
	var render: Variant = map_record.get("render", {})
	var landlook := int(render.get("landlook", -1)) if render is Dictionary else -1
	return STOCK_LANDLOOK_ENVIRONMENTS.get(
		landlook,
		{"mapType": "Outdoor", "musicType": "Forest", "outdoorRiding": true}
	).duplicate()


func _script_areas(
	bundle: Object,
	map_record: Dictionary,
	random_level: Dictionary
) -> Dictionary:
	var level_type := str(map_record.get("levelType", ""))
	var level_index := int(map_record.get("index", -1))
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
			var area := RandomRectangleScript.project_area(
				level_type,
				level_index,
				rectangle,
				_message_text(bundle, int(rectangle.get("text", 0)))
			)
			areas["%s%d.%d" % [prefix, level_index, rect_index]] = area
	return {
		"ScriptRects": areas,
		"Paths": [],
		"Secrets": _land_secrets(map_record),
	}


func _land_secrets(map_record: Dictionary) -> Array:
	if str(map_record.get("levelType", "")) != "land":
		return []
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var tiles: Variant = map_record.get("tiles", [])
	if width <= 0 or height <= 0 or not (tiles is Array):
		return []
	var secrets: Array = []
	for tile_index: int in range(tiles.size()):
		var state := MapBridgeScript.land_secret_state(int(tiles[tile_index]))
		if state == MapBridgeScript.LAND_SECRET_NONE:
			continue
		# Providence preserves Realmz land fields in column-major order.
		var x := int(tile_index / height)
		var y := tile_index % height
		secrets.append([
			x,
			y,
			1 if state == MapBridgeScript.LAND_SECRET_REVEALED else 0,
			"",
			0.0,
		])
	return secrets


func _resolve_tileset(
	bundle: Object,
	campaign_directory: String,
	map_record: Dictionary,
	dungeon_tileset: Dictionary,
	stock_land_tilesets: Dictionary,
	custom_land_tilesets: Dictionary
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
		var tileset_id := str(render.get("tilesetId", "")).strip_edges()
		var stock_plans: Variant = stock_land_tilesets.get("plans", {})
		if stock_plans is Dictionary and stock_plans.has(tileset_id):
			var stock_plan: Dictionary = stock_plans[tileset_id]
			return {
				"status": "ok",
				"name": tileset_id,
				"baseTile": int(stock_plan.get("baseTile", 1)),
				"tileCapacity": int(stock_plan.get("tileCapacity", 0)),
			}
		tileset_name = str(MapBridgeScript.STOCK_LANDLOOK_TILESETS.get(landlook, ""))
		base_tile = _catalog_base_tile(bundle, tileset_id, 156)
		if tileset_name.is_empty():
			tileset_name = tileset_id
			if not _is_safe_component(tileset_name):
				return {
					"status": "error",
					"message": "Classic landlook %d has no safe native tileset identity" % landlook,
				}
			var generated_plans: Variant = custom_land_tilesets.get("plans", {})
			if generated_plans is Dictionary and generated_plans.has(tileset_name):
				var generated_plan: Dictionary = generated_plans[tileset_name]
				return {
					"status": "ok",
					"name": tileset_name,
					"baseTile": int(generated_plan.get("baseTile", base_tile)),
					"tileCapacity": int(generated_plan.get("tileCapacity", 0)),
				}
			var tileset_directory := campaign_directory.path_join("Tilesets").path_join(
				tileset_name
			)
			if not _has_complete_native_tileset(tileset_directory, tileset_name):
				return {
					"status": "error",
					"message": "Classic tileset %s has no generated or native tileset" % (
						tileset_name
					),
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


func _runtime_landlook_targets(bundle: Object) -> Array[int]:
	var targets: Dictionary = {}
	var documents: Variant = bundle.get("documents")
	if not (documents is Dictionary):
		return []
	var scripts: Variant = documents.get("scripts", {})
	if scripts is Dictionary:
		var triggers: Variant = scripts.get("triggers", [])
		if triggers is Array:
			for trigger_value: Variant in triggers:
				if not (trigger_value is Dictionary):
					continue
				var trigger: Dictionary = trigger_value
				if not bool(trigger.get("active", false)) \
						or not _producer_marks_callable(trigger):
					continue
				_collect_landlook_targets(bundle, trigger.get("actions", []), targets)
	var encounters: Variant = documents.get("encounters", {})
	if encounters is Dictionary:
		for collection_name: String in ["simpleEncounters", "complexEncounters"]:
			var records: Variant = encounters.get(collection_name, [])
			if not (records is Array):
				continue
			for record_value: Variant in records:
				if not (record_value is Dictionary):
					continue
				var record: Dictionary = record_value
				if not _producer_marks_callable(record):
					continue
				_collect_landlook_targets(bundle, record.get("actions", []), targets)
	var result: Array[int] = []
	for landlook_value: Variant in targets.keys():
		result.append(int(landlook_value))
	result.sort()
	return result


func _collect_landlook_targets(
	bundle: Object,
	actions_value: Variant,
	targets: Dictionary
) -> void:
	if not (actions_value is Array):
		return
	for action_value: Variant in actions_value:
		if not (action_value is Dictionary):
			continue
		var action: Dictionary = action_value
		if absi(int(action.get("rawCode", action.get("code", 0)))) != 57:
			continue
		var extra_code_id := int(action.get("id", -1))
		var extra_code: Variant = bundle.get_extra_code(extra_code_id)
		if not (extra_code is Dictionary):
			continue
		var values: Variant = extra_code.get("values", [])
		if not (values is Array) or values.is_empty():
			continue
		targets[int(values[0])] = true


func _producer_marks_callable(record: Dictionary) -> bool:
	if record.has("callable"):
		return bool(record["callable"])
	if record.has("authored"):
		return bool(record["authored"])
	return true


func _build_stock_land_tileset_plans(
	bundle: Object,
	pending_maps: Array[Dictionary],
	campaign_directory: String
) -> Dictionary:
	var required: Dictionary = {}
	for pending_map: Dictionary in pending_maps:
		var map_record: Dictionary = pending_map["record"]
		if str(map_record.get("levelType", "")) != "land":
			continue
		var render: Variant = map_record.get("render", {})
		if not (render is Dictionary):
			continue
		var landlook := int(render.get("landlook", -1))
		if not STOCK_LANDLOOK_ATLASES.has(landlook):
			continue
		var tileset_id := str(render.get("tilesetId", "")).strip_edges()
		if not _is_safe_component(tileset_id):
			return {
				"status": "error",
				"message": "Classic landlook %d has no safe tileset identity" % landlook,
			}
		required[tileset_id] = landlook
	for landlook: int in _runtime_landlook_targets(bundle):
		if STOCK_LANDLOOK_ATLASES.has(landlook):
			required["landlook-%d" % landlook] = landlook
	if required.is_empty():
		return {"status": "skip", "plans": {}}

	var catalog: Variant = bundle.documents.get("assets", {}).get("catalog", {})
	var catalog_tilesets: Variant = catalog.get("tilesets", []) if catalog is Dictionary else []
	var assets_by_id: Dictionary = {}
	if catalog_tilesets is Array:
		for asset_value: Variant in catalog_tilesets:
			if asset_value is Dictionary:
				assets_by_id[str(asset_value.get("id", ""))] = asset_value

	var plans: Dictionary = {}
	var tileset_ids: Array = required.keys()
	tileset_ids.sort()
	for tileset_id_value: Variant in tileset_ids:
		var tileset_id := str(tileset_id_value)
		var landlook := int(required[tileset_id])
		var asset: Dictionary = assets_by_id.get(tileset_id, {})
		if asset.is_empty():
			if tileset_id != "landlook-%d" % landlook:
				return {
					"status": "error",
					"message": "Classic stock tileset %s is missing from the asset catalog" % (
						tileset_id
					),
				}
			asset = _stock_landlook_asset(tileset_id, landlook)
		var plan := _build_stock_land_tileset_plan(
			bundle,
			asset,
			tileset_id,
			landlook,
			campaign_directory
		)
		if str(plan.get("status", "error")) != "ok":
			return plan
		plans[tileset_id] = plan
	return {"status": "ok", "plans": plans}


func _stock_landlook_asset(tileset_id: String, landlook: int) -> Dictionary:
	return {
		"id": tileset_id,
		"landlook": landlook,
		"pictId": 300 + landlook,
		"custom": false,
		"columns": CUSTOM_LAND_COLUMNS,
		"rows": CUSTOM_LAND_ROWS,
		"tileWidth": CUSTOM_LAND_TILE_SIZE,
		"tileHeight": CUSTOM_LAND_TILE_SIZE,
	}


func _build_stock_land_tileset_plan(
	bundle: Object,
	asset: Dictionary,
	tileset_id: String,
	landlook: int,
	campaign_directory: String
) -> Dictionary:
	if int(asset.get("landlook", -1)) != landlook \
			or int(asset.get("pictId", -1)) != 300 + landlook \
			or bool(asset.get("custom", true)):
		return {
			"status": "error",
			"message": "Classic stock tileset %s has inconsistent catalog identity" % tileset_id,
		}
	if (
		int(asset.get("columns", 0)) != CUSTOM_LAND_COLUMNS
		or int(asset.get("rows", 0)) != CUSTOM_LAND_ROWS
		or int(asset.get("tileWidth", 0)) != CUSTOM_LAND_TILE_SIZE
		or int(asset.get("tileHeight", 0)) != CUSTOM_LAND_TILE_SIZE
	):
		return {
			"status": "error",
			"message": "Classic tileset %s does not declare the stock 20 x 10 tile grid" % (
				tileset_id
			),
		}
	var source_path := str(STOCK_LANDLOOK_ATLASES.get(landlook, ""))
	var source := _load_bundled_image(source_path)
	var expected_size := Vector2i(
		CUSTOM_LAND_COLUMNS * CUSTOM_LAND_TILE_SIZE,
		CUSTOM_LAND_ROWS * CUSTOM_LAND_TILE_SIZE
	)
	if source == null or source.is_empty() or source.get_size() != expected_size:
		return {
			"status": "error",
			"message": "Realmz PICT %d stock atlas is unavailable or malformed" % (300 + landlook),
		}
	source.convert(Image.FORMAT_RGBA8)

	var records_by_tile: Dictionary = {}
	var attributes: Variant = bundle.documents.get("maps", {}).get("tileAttributes", [])
	if attributes is Array:
		for record_value: Variant in attributes:
			if not (record_value is Dictionary):
				continue
			var record: Dictionary = record_value
			if record.get("landlook") == null or int(record.get("landlook", -1)) != landlook:
				continue
			var tile_id := int(record.get("tile", -1))
			if tile_id >= 0 and tile_id <= CUSTOM_LAND_TILE_COUNT:
				records_by_tile[tile_id] = record
	for tile_id: int in range(1, CUSTOM_LAND_TILE_COUNT + 1):
		if not records_by_tile.has(tile_id):
			return {
				"status": "error",
				"message": "Classic landlook %d is missing tile behavior %d" % [
					landlook,
					tile_id,
				],
			}
	var base_tile_value: Variant = asset.get("baseTile")
	var base_tile := int(base_tile_value) if base_tile_value != null else 0
	if base_tile <= 0 and records_by_tile.has(0):
		base_tile = int(records_by_tile[0].get("baseTile", 0))
	if base_tile < 0 or base_tile > CUSTOM_LAND_TILE_COUNT:
		return {
			"status": "error",
			"message": "Classic landlook %d has invalid base tile %d" % [landlook, base_tile],
		}

	var tiles: Array = []
	var templates: Dictionary = {}
	for tile_id: int in range(1, CUSTOM_LAND_TILE_COUNT + 1):
		var tile_name := "classic_landlook_%d_%03d" % [landlook, tile_id]
		tiles.append({
			"id": tile_id - 1,
			"properties": [
				{"name": "name", "type": "string", "value": tile_name},
				{"name": "template", "type": "string", "value": tile_name},
				{
					"name": "expansion",
					"type": "object",
					"value": _classic_combat_expansion(records_by_tile[tile_id], tile_id),
				},
			],
		})
		templates[tile_name] = _stock_land_tile_template(records_by_tile[tile_id], landlook)
	return {
		"status": "ok",
		"name": tileset_id,
		"directory": campaign_directory.path_join("Tilesets").path_join(tileset_id),
		"image": source,
		"baseTile": base_tile,
		"tileCapacity": CUSTOM_LAND_TILE_COUNT,
		"tileset": {
			"columns": CUSTOM_LAND_COLUMNS,
			"image": "%s.png" % tileset_id,
			"imageheight": CUSTOM_LAND_ROWS * CUSTOM_LAND_TILE_SIZE,
			"imagewidth": CUSTOM_LAND_COLUMNS * CUSTOM_LAND_TILE_SIZE,
			"margin": 0,
			"name": tileset_id,
			"spacing": 0,
			"tilecount": CUSTOM_LAND_TILE_COUNT,
			"tiledversion": "1.11.2",
			"tileheight": CUSTOM_LAND_TILE_SIZE,
			"tiles": tiles,
			"tilewidth": CUSTOM_LAND_TILE_SIZE,
			"type": "tileset",
			"version": "1.10",
		},
		"templates": templates,
	}


func _stock_land_tile_template(record: Dictionary, landlook: int) -> Dictionary:
	var solid := int(record.get("solidType", 0))
	var need_boat := int(record.get("boatRequirement", 0))
	var blocks_movement := solid != 0 and need_boat != 2
	var blocks_sight := bool(record.get("blocksLos", false))
	return {
		"time": int(record.get("movementCost", 0)),
		"wall": int(blocks_movement),
		"swall": int(blocks_movement),
		"blkproj": int(blocks_sight),
		"blkview": int(blocks_sight),
		"water": int(need_boat == 2),
		"dock": int(bool(record.get("shore", false)) or need_boat == 1),
		"sound": [],
		"classicLandlook": landlook,
		"classicTileId": int(record.get("tile", 0)),
		"classicSoundId": int(record.get("movementSoundId", 0)),
		"classicSolid": solid,
		"classicShore": int(bool(record.get("shore", false))),
		"classicNeedBoat": need_boat,
		"classicPath": int(bool(record.get("pathFlag", false))),
		"classicLos": int(blocks_sight),
		"classicFlyFloat": int(bool(record.get("flyFloatRequired", false))),
		"classicForest": int(record.get("forestType", 0)),
		"classicClearLandId": int(record.get("clearLandId", 0)),
		"classicCombatBuild": record.get("combatBuild", []),
		"classicBaseScale": int(record.get("baseScale", 1)),
	}


func _classic_combat_expansion(record: Dictionary, fallback_tile_id: int) -> Array:
	var fallback: Array = []
	fallback.resize(9)
	fallback.fill(fallback_tile_id - 1)
	var combat_build: Variant = record.get("combatBuild", [])
	if not (combat_build is Array) or combat_build.size() != 3:
		return fallback
	var expansion: Array = []
	for source_row: Variant in combat_build:
		if not (source_row is Array) or source_row.size() != 3:
			return fallback
		for source_tile: Variant in source_row:
			var classic_tile_id := int(source_tile)
			if classic_tile_id < 1 or classic_tile_id > CUSTOM_LAND_TILE_COUNT:
				return fallback
			# Classic build tables contain one-based land tile identities. Native
			# tileset expansion arrays address their zero-based atlas slots.
			expansion.append(classic_tile_id - 1)
	return expansion


func _build_custom_land_tileset_plans(
	bundle: Object,
	pending_maps: Array[Dictionary],
	campaign_directory: String
) -> Dictionary:
	var required: Dictionary = {}
	for pending_map: Dictionary in pending_maps:
		var map_record: Dictionary = pending_map["record"]
		if str(map_record.get("levelType", "")) != "land":
			continue
		var render: Variant = map_record.get("render", {})
		if not (render is Dictionary):
			continue
		var landlook := int(render.get("landlook", -1))
		if MapBridgeScript.STOCK_LANDLOOK_TILESETS.has(landlook):
			continue
		var tileset_id := str(render.get("tilesetId", "")).strip_edges()
		if not _is_safe_component(tileset_id):
			return {
				"status": "error",
				"message": "Classic landlook %d has no safe native tileset identity" % landlook,
			}
		if required.has(tileset_id) and int(required[tileset_id]) != landlook:
			return {
				"status": "error",
				"message": "Classic tileset %s is assigned to more than one landlook" % (
					tileset_id
				),
			}
		required[tileset_id] = landlook
	for landlook: int in _runtime_landlook_targets(bundle):
		if MapBridgeScript.STOCK_LANDLOOK_TILESETS.has(landlook):
			continue
		required["landlook-%d" % landlook] = landlook
	if required.is_empty():
		return {"status": "skip", "plans": {}}

	var catalog: Variant = bundle.documents.get("assets", {}).get("catalog", {})
	var catalog_tilesets: Variant = catalog.get("tilesets", []) if catalog is Dictionary else []
	var assets_by_id: Dictionary = {}
	if catalog_tilesets is Array:
		for asset_value: Variant in catalog_tilesets:
			if asset_value is Dictionary:
				assets_by_id[str(asset_value.get("id", ""))] = asset_value
	var custom_landlooks: Variant = bundle.documents.get("maps", {}).get(
		"customLandlooks",
		[]
	)
	var metadata_by_landlook: Dictionary = {}
	if custom_landlooks is Array:
		for metadata_value: Variant in custom_landlooks:
			if metadata_value is Dictionary:
				metadata_by_landlook[int(metadata_value.get("landlook", -1))] = metadata_value

	var plans: Dictionary = {}
	var tileset_ids: Array = required.keys()
	tileset_ids.sort()
	for tileset_id_value: Variant in tileset_ids:
		var tileset_id := str(tileset_id_value)
		var landlook := int(required[tileset_id])
		if not assets_by_id.has(tileset_id):
			return {
				"status": "error",
				"message": "Classic custom tileset %s is missing from the asset catalog" % (
					tileset_id
				),
			}
		var asset: Dictionary = assets_by_id[tileset_id]
		var native_directory := campaign_directory.path_join("Tilesets").path_join(
			tileset_id
		)
		if (
			not asset.has("runtimeMedia")
			and _has_complete_native_tileset(native_directory, tileset_id)
		):
			continue
		if not metadata_by_landlook.has(landlook):
			return {
				"status": "error",
				"message": "Classic landlook %d has no compiled behavior table" % landlook,
			}
		var plan := _build_custom_land_tileset_plan(
			asset,
			metadata_by_landlook[landlook],
			tileset_id,
			landlook,
			campaign_directory
		)
		if str(plan.get("status", "error")) != "ok":
			return plan
		plans[tileset_id] = plan
	return {"status": "ok", "plans": plans}


func _build_custom_land_tileset_plan(
	asset: Dictionary,
	metadata: Dictionary,
	tileset_id: String,
	landlook: int,
	campaign_directory: String
) -> Dictionary:
	if (
		int(asset.get("columns", 0)) != CUSTOM_LAND_COLUMNS
		or int(asset.get("rows", 0)) != CUSTOM_LAND_ROWS
		or int(asset.get("tileWidth", 0)) != CUSTOM_LAND_TILE_SIZE
		or int(asset.get("tileHeight", 0)) != CUSTOM_LAND_TILE_SIZE
	):
		return {
			"status": "error",
			"message": (
				"Classic tileset %s must declare the source-backed 20 x 10 grid " +
				"of 32 x 32 tiles"
			) % tileset_id,
		}
	var image_result := _load_runtime_image(
		asset,
		campaign_directory,
		"Classic tileset %s" % tileset_id,
		Vector2i(
			CUSTOM_LAND_COLUMNS * CUSTOM_LAND_TILE_SIZE,
			CUSTOM_LAND_ROWS * CUSTOM_LAND_TILE_SIZE
		)
	)
	if str(image_result.get("status", "error")) != "ok":
		return image_result
	var records: Variant = metadata.get("records", [])
	if not (records is Array):
		return {
			"status": "error",
			"message": "Classic landlook %d has no readable behavior records" % landlook,
		}
	var records_by_tile: Dictionary = {}
	for record_value: Variant in records:
		if not (record_value is Dictionary):
			continue
		var tile_id := int(record_value.get("tile", -1))
		if tile_id < 1 or tile_id > CUSTOM_LAND_TILE_COUNT:
			continue
		if records_by_tile.has(tile_id):
			return {
				"status": "error",
				"message": "Classic landlook %d repeats behavior record %d" % [
					landlook,
					tile_id,
				],
			}
		records_by_tile[tile_id] = record_value
	for tile_id: int in range(1, CUSTOM_LAND_TILE_COUNT + 1):
		if not records_by_tile.has(tile_id):
			return {
				"status": "error",
				"message": "Classic landlook %d is missing behavior record %d" % [
					landlook,
					tile_id,
				],
			}
	var base_tile := int(metadata.get("baseTile", 0))
	if base_tile < 0 or base_tile > CUSTOM_LAND_TILE_COUNT:
		return {
			"status": "error",
			"message": "Classic landlook %d has invalid base tile %d" % [landlook, base_tile],
		}

	var tiles: Array = []
	var templates: Dictionary = {}
	var base_scale := int(metadata.get("baseScale", 0))
	for tile_id: int in range(1, CUSTOM_LAND_TILE_COUNT + 1):
		var tile_name := "classic_landlook_%d_%03d" % [landlook, tile_id]
		tiles.append({
			"id": tile_id - 1,
			"properties": [
				{"name": "name", "type": "string", "value": tile_name},
				{"name": "template", "type": "string", "value": tile_name},
				{
					"name": "expansion",
					"type": "object",
					"value": _classic_combat_expansion(records_by_tile[tile_id], tile_id),
				},
			],
		})
		templates[tile_name] = _custom_land_tile_template(
			records_by_tile[tile_id],
			landlook,
			base_scale
		)
	return {
		"status": "ok",
		"name": tileset_id,
		"directory": campaign_directory.path_join("Tilesets").path_join(tileset_id),
		"image": image_result["image"],
		"baseTile": base_tile,
		"tileCapacity": CUSTOM_LAND_TILE_COUNT,
		"tileset": {
			"columns": CUSTOM_LAND_COLUMNS,
			"image": "%s.png" % tileset_id,
			"imageheight": CUSTOM_LAND_ROWS * CUSTOM_LAND_TILE_SIZE,
			"imagewidth": CUSTOM_LAND_COLUMNS * CUSTOM_LAND_TILE_SIZE,
			"margin": 0,
			"name": tileset_id,
			"spacing": 0,
			"tilecount": CUSTOM_LAND_TILE_COUNT,
			"tiledversion": "1.11.2",
			"tileheight": CUSTOM_LAND_TILE_SIZE,
			"tiles": tiles,
			"tilewidth": CUSTOM_LAND_TILE_SIZE,
			"type": "tileset",
			"version": "1.10",
		},
		"templates": templates,
	}


func _custom_land_tile_template(
	record: Dictionary,
	landlook: int,
	base_scale: int
) -> Dictionary:
	var solid := int(record.get("solid", 0))
	var need_boat := int(record.get("needBoat", 0))
	var shore := int(record.get("shore", 0))
	# Classic permits a boat to enter needBoat=2 terrain even when its solid flag is set.
	var blocks_movement := solid != 0 and need_boat != 2
	var blocks_sight := int(record.get("los", 0)) != 0
	return {
		"time": int(record.get("time", 0)),
		"wall": int(blocks_movement),
		"swall": int(blocks_movement),
		"blkproj": int(blocks_sight),
		"blkview": int(blocks_sight),
		"water": int(need_boat == 2),
		"dock": int(shore != 0 or need_boat == 1),
		# Native templates expect filenames, so retain the Classic resource ID as metadata.
		"sound": [],
		"classicLandlook": landlook,
		"classicTileId": int(record.get("tile", 0)),
		"classicSoundId": int(record.get("sound", 0)),
		"classicSolid": solid,
		"classicShore": shore,
		"classicNeedBoat": need_boat,
		"classicPath": int(record.get("isPath", 0)),
		"classicLos": int(record.get("los", 0)),
		"classicFlyFloat": int(record.get("flyFloat", 0)),
		"classicForest": int(record.get("forest", 0)),
		"classicClearLandId": int(record.get("clearLandId", 0)),
		"classicCombatBuild": record.get("combatBuild", []),
		"classicBaseScale": base_scale,
	}


func _load_runtime_image(
	record: Dictionary,
	campaign_directory: String,
	subject: String,
	expected_size: Vector2i
) -> Dictionary:
	var runtime_media: Variant = record.get("runtimeMedia")
	if not (runtime_media is Dictionary):
		return _load_classic_resource_image(record, campaign_directory, subject, expected_size)
	var relative_path := str(runtime_media.get("path", ""))
	if not _is_safe_campaign_path(relative_path):
		return {
			"status": "error",
			"message": "%s has an unsafe runtimeMedia path" % subject,
		}
	var image_path := campaign_directory.path_join(relative_path)
	if not FileAccess.file_exists(image_path):
		return {
			"status": "error",
			"message": "%s is missing runtimeMedia %s" % [subject, relative_path],
		}
	var image := Image.load_from_file(image_path)
	if image == null or image.is_empty():
		return {
			"status": "error",
			"message": "%s runtimeMedia is not a readable image" % subject,
		}
	if image.get_size() != expected_size:
		return {
			"status": "error",
			"message": (
				"%s runtimeMedia is %d x %d; Remake requires the source-backed " +
				"%d x %d image"
			) % [
				subject,
				image.get_width(),
				image.get_height(),
				expected_size.x,
				expected_size.y,
			],
		}
	image.convert(Image.FORMAT_RGBA8)
	return {"status": "ok", "image": image}


func _load_classic_resource_image(
	record: Dictionary,
	campaign_directory: String,
	subject: String,
	expected_size: Vector2i
) -> Dictionary:
	if str(record.get("payloadEncoding", "")) != "classic-resource-data":
		return {
			"status": "error",
			"message": "%s requires a decoded %d x %d runtimeMedia image" % [
				subject,
				expected_size.x,
				expected_size.y,
			],
		}
	var relative_path := str(record.get("payloadPath", ""))
	if not _is_safe_campaign_path(relative_path):
		return {"status": "error", "message": "%s has an unsafe Classic payload path" % subject}
	var payload_path := campaign_directory.path_join(relative_path)
	if not FileAccess.file_exists(payload_path):
		return {"status": "error", "message": "%s is missing Classic payload %s" % [subject, relative_path]}
	var resource_type := str(record.get("resourceType", ""))
	if resource_type.is_empty() and record.has("pictId"):
		resource_type = "PICT"
	var decoded: Dictionary = QuickDrawImageDecoderScript.decode(
		resource_type,
		FileAccess.get_file_as_bytes(payload_path)
	)
	if str(decoded.get("status", "error")) != "ok":
		return {
			"status": "error",
			"message": "%s could not decode %s: %s" % [
				subject,
				resource_type,
				str(decoded.get("message", "unsupported Classic image payload")),
			],
		}
	var image: Image = decoded["image"]
	if image.get_size() != expected_size:
		return {
			"status": "error",
			"message": (
				"%s decoded Classic payload is %d x %d; Remake requires %d x %d"
			) % [
				subject,
				image.get_width(),
				image.get_height(),
				expected_size.x,
				expected_size.y,
			],
		}
	return {"status": "ok", "image": image, "decodedFormat": decoded.get("format", "")}


func _build_land_overlay_tileset_plan(
	bundle: Object,
	pending_maps: Array[Dictionary],
	campaign_directory: String
) -> Dictionary:
	var requested_resource_ids: Dictionary = {}
	for pending_map: Dictionary in pending_maps:
		var map_record: Dictionary = pending_map["record"]
		if str(map_record.get("levelType", "")) != "land":
			continue
		var tiles: Variant = map_record.get("tiles")
		if not (tiles is Array):
			continue
		for tile_value: Variant in tiles:
			var resource_id: Variant = MapBridgeScript.land_overlay_icon_id(int(tile_value))
			if resource_id != null:
				requested_resource_ids[int(resource_id)] = true
	if requested_resource_ids.is_empty():
		return {"status": "skip"}

	var catalog: Variant = bundle.documents.get("assets", {}).get("catalog", {})
	var special_tiles: Variant = catalog.get("specialLandTiles", []) \
		if catalog is Dictionary else []
	var records_by_id: Dictionary = {}
	if special_tiles is Array:
		for record_value: Variant in special_tiles:
			if record_value is Dictionary:
				records_by_id[int(record_value.get("resourceId", 0))] = record_value

	var resource_id_values: Array = requested_resource_ids.keys()
	resource_id_values.sort()
	var images: Dictionary = {}
	var missing_resource_ids: Array[int] = []
	for resource_id_value: Variant in resource_id_values:
		var resource_id := int(resource_id_value)
		if not records_by_id.has(resource_id):
			missing_resource_ids.append(resource_id)
			continue
		var record: Dictionary = records_by_id[resource_id]
		var image_result := _load_runtime_image(
			record,
			campaign_directory,
			"Classic special land tile cicn %d" % resource_id,
			Vector2i(LAND_OVERLAY_TILE_SIZE, LAND_OVERLAY_TILE_SIZE)
		)
		if str(image_result.get("status", "error")) != "ok":
			return image_result
		images[resource_id] = image_result["image"]
	if images.is_empty():
		return {
			"status": "skip",
			"missingResourceIds": missing_resource_ids,
			"tileLookup": {},
		}

	var resolved_resource_ids: Array = images.keys()
	resolved_resource_ids.sort()
	var columns := mini(LAND_OVERLAY_ATLAS_COLUMNS, resolved_resource_ids.size())
	var rows := ceili(float(resolved_resource_ids.size()) / float(columns))
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
	for tile_index: int in range(resolved_resource_ids.size()):
		var resource_id := int(resolved_resource_ids[tile_index])
		var tile_name := "classic_land_overlay_%s" % str(resource_id).replace("-", "neg_")
		var tile_image: Image = images[resource_id]
		atlas.blit_rect(
			tile_image,
			Rect2i(Vector2i.ZERO, tile_image.get_size()),
			Vector2i(
				(tile_index % columns) * LAND_OVERLAY_TILE_SIZE,
				(tile_index / columns) * LAND_OVERLAY_TILE_SIZE
			)
		)
		lookup[resource_id] = tile_index + 1
		tiles.append({
			"id": tile_index,
			"properties": [
				{"name": "name", "type": "string", "value": tile_name},
				{"name": "template", "type": "string", "value": tile_name},
			],
		})
		templates[tile_name] = _land_overlay_template(
			bundle,
			resource_id,
			resource_id
		)

	return {
		"status": "ok",
		"name": LAND_OVERLAY_TILESET_NAME,
		"directory": campaign_directory.path_join("Tilesets").path_join(
			LAND_OVERLAY_TILESET_NAME
		),
		"image": atlas,
		"tileCapacity": resolved_resource_ids.size(),
		"tileLookup": lookup,
		"missingResourceIds": missing_resource_ids,
		"tileset": {
			"columns": columns,
			"image": "%s.png" % LAND_OVERLAY_TILESET_NAME,
			"imageheight": rows * LAND_OVERLAY_TILE_SIZE,
			"imagewidth": columns * LAND_OVERLAY_TILE_SIZE,
			"margin": 0,
			"name": LAND_OVERLAY_TILESET_NAME,
			"spacing": 0,
			"tilecount": resolved_resource_ids.size(),
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
	var resource_id: Variant = MapBridgeScript.land_overlay_icon_id(field_value)
	return int(resource_id) if resource_id != null else 0


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
		file.store_string(DistributionJsonScript.stringify(file_data["value"]))
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
			var runtime_fields: Array[int] = [field]
			if field & DUNGEON_SECRET_DIRECTION_MASK:
				# Runtime discovery sets this bit on the field. Generate that visual
				# state even when it is not present in the compiler's initial tile array.
				runtime_fields.append(field | DUNGEON_REVEALED_SECRET_MASK)
			for runtime_field: int in runtime_fields:
				fields[runtime_field] = true
				if runtime_field & DUNGEON_HIDDEN_MASK:
					# threed.c clears bit 8 around the party before plotting the
					# overhead view, so that revealed state needs an atlas entry too.
					fields[runtime_field & ~DUNGEON_HIDDEN_MASK] = true
	if fields.is_empty():
		return {"status": "skip"}

	# Data DL cells are bitfields. One tile per field value keeps the native atlas
	# compact while retaining combinations that share the same visible sprites.
	var source := _load_bundled_image(DUNGEON_SOURCE_ATLAS)
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


func _load_bundled_image(resource_path: String) -> Image:
	var texture := ResourceLoader.load(resource_path) as Texture2D
	if texture == null:
		return null
	return texture.get_image()


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
		# Classic threed.c charges one indoor timeclick for each successful step.
		"time": 999 if blocks_movement else 1,
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
	# Remake's Tiled input uses the normalized one-based tile ID directly as its GID.
	return MapBridgeScript.normalize_land_tile(value, base_tile)


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


func _has_complete_native_tileset(tileset_directory: String, tileset_name: String) -> bool:
	for file_name: String in [
		"%s.json" % tileset_name,
		"%s.png" % tileset_name,
		"tile_templates.json",
	]:
		if not FileAccess.file_exists(tileset_directory.path_join(file_name)):
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
