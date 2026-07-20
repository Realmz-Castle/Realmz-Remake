class_name ClassicRuntimeState
extends RefCounted

const MIN_DIFFICULTY := -2
const MAX_DIFFICULTY := 2
const VIEW_MAP := -1
const VIEW_3D := 1

var quest_flags: Dictionary = {}
var tile_overrides: Dictionary = {}
var trigger_percent_overrides: Dictionary = {}
var action_point_overrides: Dictionary = {}
var thief_encounter_overrides: Dictionary = {}
var simple_encounter_overrides: Dictionary = {}
var complex_encounter_overrides: Dictionary = {}
var timed_encounter_overrides: Dictionary = {}
var owned_maps: Dictionary = {}
var darkland_overrides: Dictionary = {}
var landlook_overrides: Dictionary = {}
var random_rectangle_overrides: Dictionary = {}
var difficulty := 0
var level_type := "land"
var level_index := 0
var x := 0
var y := 0
var heading := 0
var multi_view := false
var view_type := VIEW_3D
var compass_enabled := true
var priest_turning_enabled := true


func configure_from_bundle(bundle: ClassicCampaignBundle) -> void:
	quest_flags.clear()
	tile_overrides.clear()
	trigger_percent_overrides.clear()
	action_point_overrides.clear()
	thief_encounter_overrides.clear()
	simple_encounter_overrides.clear()
	complex_encounter_overrides.clear()
	timed_encounter_overrides.clear()
	owned_maps.clear()
	darkland_overrides.clear()
	landlook_overrides.clear()
	random_rectangle_overrides.clear()
	difficulty = 0
	var start := bundle.get_start()
	level_type = str(start.get("levelType", "land"))
	level_index = int(start.get("levelIndex", 0))
	x = int(start.get("x", 0))
	y = int(start.get("y", 0))
	heading = 0
	multi_view = false
	view_type = VIEW_3D
	compass_enabled = true
	priest_turning_enabled = true


func set_quest_flag(signed_quest_id: int) -> void:
	if signed_quest_id == 0:
		return
	quest_flags[abs(signed_quest_id)] = signed_quest_id > 0


func is_quest_set(quest_id: int) -> bool:
	return bool(quest_flags.get(abs(quest_id), false))


func set_difficulty(new_difficulty: int) -> void:
	difficulty = clampi(new_difficulty, MIN_DIFFICULTY, MAX_DIFFICULTY)


func set_position(new_level_index: int, new_x: int, new_y: int) -> void:
	if new_level_index >= 0:
		level_index = new_level_index
	if new_x >= 0:
		x = new_x
	if new_y >= 0:
		y = new_y


func set_location(new_level_type: String, new_level_index: int, new_x: int, new_y: int) -> void:
	if new_level_type in ["land", "dungeon"]:
		level_type = new_level_type
	set_position(new_level_index, new_x, new_y)


func set_heading(new_heading: int) -> void:
	heading = new_heading


func set_compass_enabled(enabled: bool) -> void:
	compass_enabled = enabled


func set_priest_turning_enabled(enabled: bool) -> void:
	priest_turning_enabled = enabled


func require_3d_view() -> void:
	multi_view = false
	view_type = VIEW_3D


func allow_full_map() -> void:
	multi_view = true


func set_dungeon_view(new_heading: int, new_multi_view: bool) -> void:
	set_heading(abs(new_heading))
	multi_view = new_multi_view
	if not multi_view:
		view_type = VIEW_3D


func set_darkland(level_kind: String, map_level: int, darkness: int) -> void:
	darkland_overrides[_map_key(level_kind, map_level)] = darkness


func get_darkland(level_kind: String, map_level: int, fallback: int) -> int:
	return int(darkland_overrides.get(_map_key(level_kind, map_level), fallback))


func set_landlook(level_kind: String, map_level: int, landlook: int) -> void:
	landlook_overrides[_map_key(level_kind, map_level)] = landlook


func get_landlook(level_kind: String, map_level: int, fallback: int) -> int:
	return int(landlook_overrides.get(_map_key(level_kind, map_level), fallback))


func set_random_rectangle(
	level_kind: String,
	map_level: int,
	rect_index: int,
	rectangle: Dictionary
) -> void:
	var key := _random_rectangle_key(level_kind, map_level, rect_index)
	random_rectangle_overrides[key] = rectangle.duplicate(true)


func get_random_rectangle(
	level_kind: String,
	map_level: int,
	rect_index: int,
	fallback: Dictionary
) -> Dictionary:
	var rectangle: Variant = random_rectangle_overrides.get(
		_random_rectangle_key(level_kind, map_level, rect_index),
		fallback
	)
	return rectangle.duplicate(true) if rectangle is Dictionary else {}


func set_tile(level_kind: String, map_level: int, tile_x: int, tile_y: int, tile_value: int) -> void:
	tile_overrides[_tile_key(level_kind, map_level, tile_x, tile_y)] = tile_value


func get_tile(level_kind: String, map_level: int, tile_x: int, tile_y: int, fallback: int) -> int:
	return int(tile_overrides.get(_tile_key(level_kind, map_level, tile_x, tile_y), fallback))


func set_trigger_percent(level_kind: String, map_level: int, trigger_id: int, percent: int) -> void:
	trigger_percent_overrides[_trigger_key(level_kind, map_level, trigger_id)] = percent


func get_trigger_percent(
	level_kind: String,
	map_level: int,
	trigger_id: int,
	fallback: int
) -> int:
	return int(trigger_percent_overrides.get(
		_trigger_key(level_kind, map_level, trigger_id),
		fallback
	))


func set_action_point_override(trigger_id: String, action_point: Dictionary) -> void:
	action_point_overrides[trigger_id] = action_point.duplicate(true)


func get_action_point_override(trigger_id: String) -> Dictionary:
	var action_point: Variant = action_point_overrides.get(trigger_id, {})
	return action_point.duplicate(true) if action_point is Dictionary else {}


func get_effective_action_point(action_point: Dictionary) -> Dictionary:
	var trigger_id := str(action_point.get("id", ""))
	var effective := get_action_point_override(trigger_id)
	if effective.is_empty():
		effective = action_point.duplicate(true)
	var level_kind := str(effective.get("levelType", ""))
	var level_value: Variant = effective.get("levelIndex", -1)
	var record_value: Variant = effective.get("recordIndex", -1)
	var level := int(level_value) if level_value != null else -1
	var record_index := int(record_value) if record_value != null else -1
	if level_kind in ["land", "dungeon"] and level >= 0 and record_index >= 0:
		effective["percent"] = get_trigger_percent(
			level_kind,
			level,
			record_index,
			int(effective.get("percent", 0))
		)
		effective["active"] = (
			int(effective["percent"]) >= 1
			and effective.get("coordinate") is Dictionary
		)
	return effective


func get_effective_triggers_at(
	bundle: ClassicCampaignBundle,
	level_kind: String,
	map_level: int,
	tile_x: int,
	tile_y: int
) -> Array:
	var triggers: Array = []
	var included_ids: Dictionary = {}
	for trigger_value: Variant in bundle.get_triggers_at(
		level_kind,
		map_level,
		tile_x,
		tile_y
	):
		if not (trigger_value is Dictionary):
			continue
		var trigger := get_effective_action_point(trigger_value)
		if not _trigger_matches_location(
			trigger,
			level_kind,
			map_level,
			tile_x,
			tile_y
		):
			continue
		triggers.append(trigger)
		included_ids[str(trigger.get("id", ""))] = true
	for override_value: Variant in action_point_overrides.values():
		if not (override_value is Dictionary):
			continue
		var trigger_id := str(override_value.get("id", ""))
		var coordinate: Variant = override_value.get("coordinate")
		if included_ids.has(trigger_id) or not (coordinate is Dictionary):
			continue
		if _trigger_matches_location(
			override_value,
			level_kind,
			map_level,
			tile_x,
			tile_y
		):
			triggers.append(get_effective_action_point(override_value))
	return triggers


func _trigger_matches_location(
	trigger: Dictionary,
	level_kind: String,
	map_level: int,
	tile_x: int,
	tile_y: int
) -> bool:
	var coordinate: Variant = trigger.get("coordinate")
	return (
		coordinate is Dictionary
		and str(trigger.get("levelType", "")) == level_kind
		and int(trigger.get("levelIndex", -1)) == map_level
		and int(coordinate.get("x", -1)) == tile_x
		and int(coordinate.get("y", -1)) == tile_y
	)


func set_thief_encounter_override(encounter_id: int, encounter: Dictionary) -> void:
	# Classic only writes a changed CT record when the linked Data TD2 id is nonzero.
	if encounter_id <= 0:
		return
	thief_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)


func get_effective_thief_encounter(encounter: Dictionary) -> Dictionary:
	var encounter_id := int(encounter.get("id", -1))
	var override: Variant = thief_encounter_overrides.get(str(encounter_id), {})
	return override.duplicate(true) if override is Dictionary and not override.is_empty() \
		else encounter.duplicate(true)


func set_simple_encounter_override(encounter_id: int, encounter: Dictionary) -> void:
	if encounter_id < 0:
		return
	simple_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)


func get_effective_simple_encounter(encounter: Dictionary) -> Dictionary:
	var encounter_id := int(encounter.get("id", -1))
	var override: Variant = simple_encounter_overrides.get(str(encounter_id), {})
	return override.duplicate(true) if override is Dictionary and not override.is_empty() \
		else encounter.duplicate(true)


func set_complex_encounter_override(encounter_id: int, encounter: Dictionary) -> void:
	if encounter_id < 0:
		return
	complex_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)


func get_effective_complex_encounter(encounter: Dictionary) -> Dictionary:
	var encounter_id := int(encounter.get("id", -1))
	var override: Variant = complex_encounter_overrides.get(str(encounter_id), {})
	return override.duplicate(true) if override is Dictionary and not override.is_empty() \
		else encounter.duplicate(true)


func set_timed_encounter_override(encounter_id: int, encounter: Dictionary) -> void:
	if encounter_id < 0:
		return
	timed_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)


func get_effective_timed_encounter(encounter: Dictionary) -> Dictionary:
	var encounter_id := int(encounter.get("id", -1))
	var override: Variant = timed_encounter_overrides.get(str(encounter_id), {})
	return override.duplicate(true) if override is Dictionary and not override.is_empty() \
		else encounter.duplicate(true)


func set_map_owned(map_id: int) -> void:
	if map_id >= 0:
		owned_maps[str(map_id)] = true


func is_map_owned(map_id: int) -> bool:
	return bool(owned_maps.get(str(abs(map_id)), false))


func snapshot() -> Dictionary:
	return {
		"questFlags": quest_flags.duplicate(true),
		"tileOverrides": tile_overrides.duplicate(true),
		"triggerPercentOverrides": trigger_percent_overrides.duplicate(true),
		"actionPointOverrides": action_point_overrides.duplicate(true),
		"thiefEncounterOverrides": thief_encounter_overrides.duplicate(true),
		"simpleEncounterOverrides": simple_encounter_overrides.duplicate(true),
		"complexEncounterOverrides": complex_encounter_overrides.duplicate(true),
		"timedEncounterOverrides": timed_encounter_overrides.duplicate(true),
		"ownedMaps": owned_maps.duplicate(true),
		"darklandOverrides": darkland_overrides.duplicate(true),
		"landlookOverrides": landlook_overrides.duplicate(true),
		"randomRectangleOverrides": random_rectangle_overrides.duplicate(true),
		"difficulty": difficulty,
		"priestTurningEnabled": priest_turning_enabled,
		"position": {
			"levelType": level_type,
			"levelIndex": level_index,
			"x": x,
			"y": y,
			"heading": heading,
			"multiView": multi_view,
			"viewType": view_type,
			"compassEnabled": compass_enabled,
		},
	}


func restore(saved_state: Dictionary) -> void:
	quest_flags.clear()
	tile_overrides.clear()
	trigger_percent_overrides.clear()
	action_point_overrides.clear()
	thief_encounter_overrides.clear()
	simple_encounter_overrides.clear()
	complex_encounter_overrides.clear()
	timed_encounter_overrides.clear()
	owned_maps.clear()
	darkland_overrides.clear()
	landlook_overrides.clear()
	random_rectangle_overrides.clear()
	var saved_flags: Variant = saved_state.get("questFlags", {})
	if saved_flags is Dictionary:
		for quest_id: Variant in saved_flags:
			quest_flags[int(quest_id)] = bool(saved_flags[quest_id])
	_restore_dictionary(saved_state.get("tileOverrides", {}), tile_overrides)
	_restore_dictionary(saved_state.get("triggerPercentOverrides", {}), trigger_percent_overrides)
	var saved_action_points: Variant = saved_state.get("actionPointOverrides", {})
	if saved_action_points is Dictionary:
		for trigger_id: Variant in saved_action_points:
			var action_point: Variant = saved_action_points[trigger_id]
			if action_point is Dictionary:
				action_point_overrides[str(trigger_id)] = action_point.duplicate(true)
	var saved_thief_encounters: Variant = saved_state.get("thiefEncounterOverrides", {})
	if saved_thief_encounters is Dictionary:
		for encounter_id: Variant in saved_thief_encounters:
			var encounter: Variant = saved_thief_encounters[encounter_id]
			if encounter is Dictionary:
				thief_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)
	var saved_simple_encounters: Variant = saved_state.get("simpleEncounterOverrides", {})
	if saved_simple_encounters is Dictionary:
		for encounter_id: Variant in saved_simple_encounters:
			var encounter: Variant = saved_simple_encounters[encounter_id]
			if encounter is Dictionary:
				simple_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)
	var saved_complex_encounters: Variant = saved_state.get("complexEncounterOverrides", {})
	if saved_complex_encounters is Dictionary:
		for encounter_id: Variant in saved_complex_encounters:
			var encounter: Variant = saved_complex_encounters[encounter_id]
			if encounter is Dictionary:
				complex_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)
	var saved_timed_encounters: Variant = saved_state.get("timedEncounterOverrides", {})
	if saved_timed_encounters is Dictionary:
		for encounter_id: Variant in saved_timed_encounters:
			var encounter: Variant = saved_timed_encounters[encounter_id]
			if encounter is Dictionary:
				timed_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)
	var saved_maps: Variant = saved_state.get("ownedMaps", {})
	if saved_maps is Dictionary:
		for map_id: Variant in saved_maps:
			owned_maps[str(map_id)] = bool(saved_maps[map_id])
	_restore_dictionary(saved_state.get("darklandOverrides", {}), darkland_overrides)
	_restore_dictionary(saved_state.get("landlookOverrides", {}), landlook_overrides)
	var saved_random_rectangles: Variant = saved_state.get("randomRectangleOverrides", {})
	if saved_random_rectangles is Dictionary:
		for rectangle_key: Variant in saved_random_rectangles:
			var rectangle: Variant = saved_random_rectangles[rectangle_key]
			if rectangle is Dictionary:
				random_rectangle_overrides[str(rectangle_key)] = rectangle.duplicate(true)
	set_difficulty(int(saved_state.get("difficulty", 0)))
	priest_turning_enabled = bool(saved_state.get("priestTurningEnabled", true))
	var position: Variant = saved_state.get("position", {})
	if position is Dictionary:
		level_type = str(position.get("levelType", "land"))
		level_index = int(position.get("levelIndex", 0))
		x = int(position.get("x", 0))
		y = int(position.get("y", 0))
		heading = int(position.get("heading", 0))
		multi_view = bool(position.get("multiView", false))
		view_type = int(position.get("viewType", VIEW_3D))
		compass_enabled = bool(position.get("compassEnabled", true))


func _restore_dictionary(saved_value: Variant, target: Dictionary) -> void:
	if not (saved_value is Dictionary):
		return
	for key: Variant in saved_value:
		target[str(key)] = int(saved_value[key])


func _tile_key(level_kind: String, map_level: int, tile_x: int, tile_y: int) -> String:
	return "%s:%d:%d:%d" % [level_kind, map_level, tile_x, tile_y]


func _trigger_key(level_kind: String, map_level: int, trigger_id: int) -> String:
	return "%s:%d:%d" % [level_kind, map_level, trigger_id]


func _map_key(level_kind: String, map_level: int) -> String:
	return "%s:%d" % [level_kind, map_level]


func _random_rectangle_key(level_kind: String, map_level: int, rect_index: int) -> String:
	return "%s:%d:%d" % [level_kind, map_level, rect_index]
