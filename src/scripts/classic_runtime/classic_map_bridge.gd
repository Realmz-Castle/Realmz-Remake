class_name ClassicMapBridge
extends RefCounted

var classic_bundle: Object
var native_tile_stacks: Dictionary = {}


func configure(bundle: Object) -> void:
	classic_bundle = bundle
	native_tile_stacks.clear()


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
			var landlook_map := _native_map_entry(
				resources,
				native_map_name(
					str(landlook.get("levelType", "")),
					int(landlook.get("levelIndex", -1))
				)
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
	if not _has_native_map(resources, map_name):
		return _error("Classic map %s has no loaded native map resource" % map_name)
	if game_global == null:
		return _error("Realmz map state is unavailable")

	var x := int(payload.get("x", -1))
	var y := int(payload.get("y", -1))
	if x < 0 or y < 0:
		return _error("Classic map transition has invalid coordinates")

	var changed_map := str(game_global.get("currentmap_name")) != map_name
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


func set_darkness(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var map_name := native_map_name(
		str(payload.get("levelType", "")),
		int(payload.get("levelIndex", -1))
	)
	var map_entry := _native_map_entry(resources, map_name)
	if map_entry.is_empty():
		return _error("Classic map %s has no loaded native map resource" % map_name)

	# Remake uses 0 for full darkness and 7 for an unobscured map.
	var native_darkness := 0 if bool(payload.get("dark", false)) else 7
	map_entry[6] = native_darkness
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null:
		current_map.set("darkness_level", native_darkness)
		if current_map.has_method("queue_redraw"):
			current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"nativeDarkness": native_darkness,
	}


func set_land_look(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var result := set_darkness(payload, game_global, resources)
	if str(result.get("status", "")) == "error":
		return result
	result["landlook"] = int(payload.get("landlook", 0))
	result["tilesetChanged"] = false
	return result


func set_tile(payload: Dictionary, game_global: Object, resources: Object) -> Dictionary:
	var level_type := str(payload.get("levelType", ""))
	var level_index := int(payload.get("levelIndex", -1))
	var map_name := native_map_name(level_type, level_index)
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
	var native_tile: Dictionary = _native_tile_stack(map_name, map_record, native_map, tile_value)
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
	# Classic stores random-area probability as occurrences in 10,000.
	area["chance"] = float(rectangle.get("percent", 0)) / 10000.0
	area["scriptRectangle"] = [
		[int(rectangle.get("left", 0)), int(rectangle.get("top", 0))],
		[int(rectangle.get("right", 0)), int(rectangle.get("bottom", 0))],
	]
	var battle_range: Variant = rectangle.get("battleRange", [])
	if battle_range is Array and battle_range.size() >= 2:
		var battle: Variant = area.get("RR_Battle", {})
		if battle is Dictionary:
			battle["battle_range"] = [int(battle_range[0]), int(battle_range[1])]
	var current_map: Variant = _current_map(game_global, map_name)
	if current_map != null and current_map.has_method("queue_redraw"):
		current_map.queue_redraw()
	return {
		"nativeMapName": map_name,
		"updatedArea": area_name,
	}


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


func _native_tile_stack(
	map_name: String,
	map_record: Dictionary,
	native_map: Array,
	tile_value: int
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
	return native_tile_stacks[map_name].get(tile_value, {})


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


func _skipped(message: String) -> Dictionary:
	return {"status": "skipped", "message": message}
