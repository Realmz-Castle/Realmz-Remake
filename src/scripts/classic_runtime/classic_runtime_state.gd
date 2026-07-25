class_name ClassicRuntimeState
extends RefCounted

const MIN_DIFFICULTY := -2
const MAX_DIFFICULTY := 2
const VIEW_MAP := -1
const VIEW_3D := 1

var quest_flags: Dictionary = {}
var quest_values: Dictionary = {}
var tile_overrides: Dictionary = {}
var trigger_percent_overrides: Dictionary = {}
var action_point_overrides: Dictionary = {}
var thief_encounter_overrides: Dictionary = {}
var simple_encounter_overrides: Dictionary = {}
var complex_encounter_overrides: Dictionary = {}
var timed_encounter_overrides: Dictionary = {}
var shop_overrides: Dictionary = {}
var pending_timed_encounter_scans: Array[Dictionary] = []
var last_timed_encounter_day := -1
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
var random_encounters_enabled := true
var allies_suspended := false
var player_spellcasting_blocked := false
var monster_spellcasting_blocked := false
var spell_charging_flag := false
var saved_party_position: Dictionary = {}


func configure_from_bundle(bundle: ClassicCampaignBundle) -> void:
	quest_flags.clear()
	quest_values.clear()
	tile_overrides.clear()
	trigger_percent_overrides.clear()
	action_point_overrides.clear()
	thief_encounter_overrides.clear()
	simple_encounter_overrides.clear()
	complex_encounter_overrides.clear()
	timed_encounter_overrides.clear()
	shop_overrides.clear()
	pending_timed_encounter_scans.clear()
	last_timed_encounter_day = -1
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
	random_encounters_enabled = true
	allies_suspended = false
	player_spellcasting_blocked = false
	monster_spellcasting_blocked = false
	spell_charging_flag = false
	saved_party_position.clear()
	if not bundle.get_player_map(0).is_empty():
		set_map_owned(0)


func set_quest_flag(signed_quest_id: int) -> void:
	if signed_quest_id == 0:
		return
	set_quest_value(absi(signed_quest_id), 1 if signed_quest_id > 0 else 0)


func is_quest_set(quest_id: int) -> bool:
	return get_quest_value(absi(quest_id)) != 0


func set_quest_value(quest_id: int, value: int) -> void:
	var normalized_id := absi(quest_id)
	var normalized_value := clampi(value, -127, 127)
	quest_values[normalized_id] = normalized_value
	quest_flags[normalized_id] = normalized_value != 0


func adjust_quest_value(quest_id: int, change: int) -> int:
	var normalized_id := absi(quest_id)
	set_quest_value(normalized_id, get_quest_value(normalized_id) + change)
	return get_quest_value(normalized_id)


func get_quest_value(quest_id: int) -> int:
	var normalized_id := absi(quest_id)
	if quest_values.has(normalized_id):
		return int(quest_values[normalized_id])
	return 1 if bool(quest_flags.get(normalized_id, false)) else 0


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


func save_party_position() -> void:
	saved_party_position = {
		"levelType": level_type,
		"levelIndex": level_index,
		"x": x,
		"y": y,
	}


func restore_party_position() -> Dictionary:
	if saved_party_position.is_empty():
		return {}
	set_location(
		str(saved_party_position.get("levelType", level_type)),
		int(saved_party_position.get("levelIndex", level_index)),
		int(saved_party_position.get("x", x)),
		int(saved_party_position.get("y", y))
	)
	return saved_party_position.duplicate(true)


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


func persistent_map_mutations() -> Dictionary:
	return {
		"darkness": _keyed_integer_mutations(
			darkland_overrides,
			[],
			"darkness"
		),
		"landLooks": _keyed_integer_mutations(
			landlook_overrides,
			[],
			"landlook"
		),
		"randomRectangles": _keyed_dictionary_mutations(
			random_rectangle_overrides,
			["rectIndex"]
		),
		"actionPoints": _dictionary_values(action_point_overrides),
		"triggerPercents": _keyed_integer_mutations(
			trigger_percent_overrides,
			["triggerId"],
			"percent"
		),
		"tiles": _keyed_integer_mutations(
			tile_overrides,
			["x", "y"],
			"tileValue"
		),
	}


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


func set_shop_override(shop_id: int, shop: Dictionary) -> void:
	if shop_id < 0:
		return
	shop_overrides[str(shop_id)] = shop.duplicate(true)


func get_effective_shop(shop: Dictionary) -> Dictionary:
	var shop_id := int(shop.get("id", -1))
	var override: Variant = shop_overrides.get(str(shop_id), {})
	return override.duplicate(true) if override is Dictionary and not override.is_empty() \
		else shop.duplicate(true)


func alter_shop(
	shop: Dictionary,
	inflation_delta: int,
	item_id: int,
	quantity_delta: int
) -> Dictionary:
	var effective := get_effective_shop(shop)
	if effective.is_empty():
		return {}
	effective["inflation"] = int(effective.get("inflation", 0)) + inflation_delta
	var item_ids: Variant = effective.get("itemIds", [])
	var quantities: Variant = effective.get("quantities", [])
	if item_ids is Array and quantities is Array:
		for slot: int in range(min(item_ids.size(), quantities.size())):
			if int(item_ids[slot]) == item_id:
				quantities[slot] = maxi(0, int(quantities[slot]) + quantity_delta)
	effective["quantities"] = quantities
	set_shop_override(int(effective.get("id", -1)), effective)
	return effective


func set_timed_encounter_override(encounter_id: int, encounter: Dictionary) -> void:
	if encounter_id < 0:
		return
	timed_encounter_overrides[str(encounter_id)] = encounter.duplicate(true)


func get_effective_timed_encounter(encounter: Dictionary) -> Dictionary:
	var encounter_id := int(encounter.get("id", -1))
	var override: Variant = timed_encounter_overrides.get(str(encounter_id), {})
	return override.duplicate(true) if override is Dictionary and not override.is_empty() \
		else encounter.duplicate(true)


func enqueue_timed_encounter_day(scenario_day: int) -> bool:
	if scenario_day < 0 or scenario_day <= last_timed_encounter_day:
		return false
	for pending_scan: Dictionary in pending_timed_encounter_scans:
		if int(pending_scan.get("day", -1)) == scenario_day:
			return false
	pending_timed_encounter_scans.append({"day": scenario_day, "nextIndex": 0})
	return true


func pending_timed_encounter_scan() -> Dictionary:
	return pending_timed_encounter_scans[0].duplicate(true) \
		if not pending_timed_encounter_scans.is_empty() else {}


func set_pending_timed_encounter_index(next_index: int) -> void:
	if pending_timed_encounter_scans.is_empty():
		return
	pending_timed_encounter_scans[0]["nextIndex"] = maxi(0, next_index)


func finish_pending_timed_encounter_day() -> void:
	if pending_timed_encounter_scans.is_empty():
		return
	var completed: Dictionary = pending_timed_encounter_scans.pop_front()
	last_timed_encounter_day = maxi(
		last_timed_encounter_day,
		int(completed.get("day", -1))
	)


func set_map_owned(map_id: int) -> void:
	if map_id >= 0:
		owned_maps[str(map_id)] = true


func is_map_owned(map_id: int) -> bool:
	return bool(owned_maps.get(str(abs(map_id)), false))


func set_spellcasting_flags(
	player_blocked: bool,
	monster_blocked: bool,
	charging_flag: bool
) -> void:
	player_spellcasting_blocked = player_blocked
	monster_spellcasting_blocked = monster_blocked
	spell_charging_flag = charging_flag


func snapshot() -> Dictionary:
	return {
		"questFlags": quest_flags.duplicate(true),
		"questValues": quest_values.duplicate(true),
		"tileOverrides": tile_overrides.duplicate(true),
		"triggerPercentOverrides": trigger_percent_overrides.duplicate(true),
		"actionPointOverrides": action_point_overrides.duplicate(true),
		"thiefEncounterOverrides": thief_encounter_overrides.duplicate(true),
		"simpleEncounterOverrides": simple_encounter_overrides.duplicate(true),
		"complexEncounterOverrides": complex_encounter_overrides.duplicate(true),
		"timedEncounterOverrides": timed_encounter_overrides.duplicate(true),
		"shopOverrides": shop_overrides.duplicate(true),
		"pendingTimedEncounterScans": pending_timed_encounter_scans.duplicate(true),
		"lastTimedEncounterDay": last_timed_encounter_day,
		"ownedMaps": owned_maps.duplicate(true),
		"darklandOverrides": darkland_overrides.duplicate(true),
		"landlookOverrides": landlook_overrides.duplicate(true),
		"randomRectangleOverrides": random_rectangle_overrides.duplicate(true),
		"difficulty": difficulty,
		"priestTurningEnabled": priest_turning_enabled,
		"randomEncountersEnabled": random_encounters_enabled,
		"alliesSuspended": allies_suspended,
		"playerSpellcastingBlocked": player_spellcasting_blocked,
		"monsterSpellcastingBlocked": monster_spellcasting_blocked,
		"spellChargingFlag": spell_charging_flag,
		"savedPartyPosition": saved_party_position.duplicate(true),
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
	var owns_initial_map := is_map_owned(0)
	quest_flags.clear()
	quest_values.clear()
	tile_overrides.clear()
	trigger_percent_overrides.clear()
	action_point_overrides.clear()
	thief_encounter_overrides.clear()
	simple_encounter_overrides.clear()
	complex_encounter_overrides.clear()
	timed_encounter_overrides.clear()
	shop_overrides.clear()
	pending_timed_encounter_scans.clear()
	last_timed_encounter_day = -1
	owned_maps.clear()
	if owns_initial_map:
		owned_maps["0"] = true
	darkland_overrides.clear()
	landlook_overrides.clear()
	random_rectangle_overrides.clear()
	var saved_flags: Variant = saved_state.get("questFlags", {})
	if saved_flags is Dictionary:
		for quest_id: Variant in saved_flags:
			var flag_is_set := bool(saved_flags[quest_id])
			quest_flags[int(quest_id)] = flag_is_set
			quest_values[int(quest_id)] = 1 if flag_is_set else 0
	var saved_values: Variant = saved_state.get("questValues", {})
	if saved_values is Dictionary:
		for quest_id: Variant in saved_values:
			set_quest_value(int(quest_id), int(saved_values[quest_id]))
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
	var saved_shops: Variant = saved_state.get("shopOverrides", {})
	if saved_shops is Dictionary:
		for shop_id: Variant in saved_shops:
			var shop: Variant = saved_shops[shop_id]
			if shop is Dictionary:
				shop_overrides[str(shop_id)] = shop.duplicate(true)
	var saved_timed_scans: Variant = saved_state.get("pendingTimedEncounterScans", [])
	if saved_timed_scans is Array:
		for scan_value: Variant in saved_timed_scans:
			if not (scan_value is Dictionary):
				continue
			var scan_day := int(scan_value.get("day", -1))
			var next_index := int(scan_value.get("nextIndex", -1))
			if scan_day >= 0 and next_index >= 0:
				pending_timed_encounter_scans.append({
					"day": scan_day,
					"nextIndex": next_index,
				})
	last_timed_encounter_day = int(saved_state.get("lastTimedEncounterDay", -1))
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
	random_encounters_enabled = bool(saved_state.get("randomEncountersEnabled", true))
	allies_suspended = bool(saved_state.get("alliesSuspended", false))
	player_spellcasting_blocked = bool(
		saved_state.get("playerSpellcastingBlocked", false)
	)
	monster_spellcasting_blocked = bool(
		saved_state.get("monsterSpellcastingBlocked", false)
	)
	spell_charging_flag = bool(saved_state.get("spellChargingFlag", false))
	saved_party_position.clear()
	var saved_position: Variant = saved_state.get("savedPartyPosition", {})
	if saved_position is Dictionary:
		saved_party_position = saved_position.duplicate(true)
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


func _keyed_integer_mutations(
	source: Dictionary,
	index_fields: Array,
	value_field: String
) -> Array:
	var mutations: Array = []
	for key: Variant in _sorted_keys(source):
		var mutation := _map_mutation_key(str(key), index_fields)
		if mutation.is_empty():
			continue
		mutation[value_field] = int(source[key])
		mutations.append(mutation)
	return mutations


func _keyed_dictionary_mutations(source: Dictionary, index_fields: Array) -> Array:
	var mutations: Array = []
	for key: Variant in _sorted_keys(source):
		var value: Variant = source[key]
		if not (value is Dictionary):
			continue
		var mutation := _map_mutation_key(str(key), index_fields)
		if mutation.is_empty():
			continue
		for field: Variant in value:
			mutation[field] = value[field]
		mutations.append(mutation.duplicate(true))
	return mutations


func _dictionary_values(source: Dictionary) -> Array:
	var values: Array = []
	for key: Variant in _sorted_keys(source):
		var value: Variant = source[key]
		if value is Dictionary:
			values.append(value.duplicate(true))
	return values


func _map_mutation_key(key: String, index_fields: Array) -> Dictionary:
	var parts := key.split(":")
	if parts.size() != index_fields.size() + 2:
		return {}
	var mutation := {
		"levelType": parts[0],
		"levelIndex": int(parts[1]),
	}
	for index: int in range(index_fields.size()):
		mutation[str(index_fields[index])] = int(parts[index + 2])
	return mutation


func _sorted_keys(source: Dictionary) -> Array:
	var keys := source.keys()
	keys.sort()
	return keys


func _tile_key(level_kind: String, map_level: int, tile_x: int, tile_y: int) -> String:
	return "%s:%d:%d:%d" % [level_kind, map_level, tile_x, tile_y]


func _trigger_key(level_kind: String, map_level: int, trigger_id: int) -> String:
	return "%s:%d:%d" % [level_kind, map_level, trigger_id]


func _map_key(level_kind: String, map_level: int) -> String:
	return "%s:%d" % [level_kind, map_level]


func _random_rectangle_key(level_kind: String, map_level: int, rect_index: int) -> String:
	return "%s:%d:%d" % [level_kind, map_level, rect_index]
